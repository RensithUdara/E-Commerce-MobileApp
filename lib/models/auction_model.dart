class Auction {
  final String id;
  final String productId;
  final String title;
  final String description;
  final double startingPrice;
  final double currentBid;
  final String sellerId;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> imageUrls;
  final AuctionStatus status;
  final List<Bid> bids;
  final String? winnerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Auction({
    required this.id,
    required this.productId,
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.currentBid,
    required this.sellerId,
    required this.startTime,
    required this.endTime,
    required this.imageUrls,
    required this.status,
    required this.bids,
    this.winnerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Auction.fromMap(Map<String, dynamic> data, String id) {
    return Auction(
      id: id,
      productId: data['productId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startingPrice: (data['startingPrice'] as num?)?.toDouble() ?? 0.0,
      currentBid: (data['currentBid'] as num?)?.toDouble() ?? 0.0,
      sellerId: data['sellerId'] ?? '',
      startTime: data['startTime'] != null
          ? DateTime.parse(data['startTime'])
          : DateTime.now(),
      endTime: data['endTime'] != null
          ? DateTime.parse(data['endTime'])
          : DateTime.now(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      status: AuctionStatus.values.firstWhere(
        (status) =>
            status.toString().split('.').last == (data['status'] ?? 'active'),
        orElse: () => AuctionStatus.active,
      ),
      bids: (data['bids'] as List<dynamic>?)
              ?.map((bidData) => Bid.fromMap(bidData))
              .toList() ??
          [],
      winnerId: data['winnerId'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'description': description,
      'startingPrice': startingPrice,
      'currentBid': currentBid,
      'sellerId': sellerId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'imageUrls': imageUrls,
      'status': status.toString().split('.').last,
      'bids': bids.map((bid) => bid.toMap()).toList(),
      'winnerId': winnerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isActive =>
      status == AuctionStatus.active && DateTime.now().isBefore(endTime);
  bool get hasEnded => DateTime.now().isAfter(endTime);
  Duration get timeRemaining =>
      hasEnded ? Duration.zero : endTime.difference(DateTime.now());

  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
}

class Bid {
  final String id;
  final String auctionId;
  final String userId;
  final double amount;
  final DateTime timestamp;

  Bid({
    required this.id,
    required this.auctionId,
    required this.userId,
    required this.amount,
    required this.timestamp,
  });

  factory Bid.fromMap(Map<String, dynamic> data) {
    return Bid(
      id: data['id'] ?? '',
      auctionId: data['auctionId'] ?? '',
      userId: data['userId'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auctionId': auctionId,
      'userId': userId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum AuctionStatus {
  active,
  ended,
  cancelled,
}
