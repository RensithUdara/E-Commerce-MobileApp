import '../models/models.dart';
import '../services/services.dart';

class AuctionController {
  final DatabaseService _databaseService = FirestoreService();

  List<Auction> _auctions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Auction> get auctions => _auctions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _errorMessage = error;
  }

  Future<void> fetchAuctions({AuctionStatus? status}) async {
    try {
      _setLoading(true);
      _setError(null);

      _auctions = await _databaseService.getAuctions(status: status);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<Auction?> getAuction(String auctionId) async {
    try {
      return await _databaseService.getAuction(auctionId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> createAuction({
    required String productId,
    required String title,
    required String description,
    required double startingPrice,
    required String sellerId,
    required DateTime endTime,
    required List<String> imageUrls,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final auction = Auction(
        id: '', // Will be set by database
        productId: productId,
        title: title,
        description: description,
        startingPrice: startingPrice,
        currentBid: startingPrice,
        sellerId: sellerId,
        startTime: DateTime.now(),
        endTime: endTime,
        imageUrls: imageUrls,
        status: AuctionStatus.active,
        bids: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createAuction(auction);
      await fetchAuctions(); // Refresh auctions
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> placeBid({
    required String auctionId,
    required String userId,
    required double bidAmount,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final auction = await _databaseService.getAuction(auctionId);
      if (auction == null) {
        _setError('Auction not found');
        _setLoading(false);
        return false;
      }

      if (!auction.isActive) {
        _setError('Auction is not active');
        _setLoading(false);
        return false;
      }

      if (bidAmount <= auction.currentBid) {
        _setError('Bid must be higher than current bid');
        _setLoading(false);
        return false;
      }

      final bid = Bid(
        id: '${auctionId}_${userId}_${DateTime.now().millisecondsSinceEpoch}',
        auctionId: auctionId,
        userId: userId,
        amount: bidAmount,
        timestamp: DateTime.now(),
      );

      await _databaseService.placeBid(auctionId, bid);
      await fetchAuctions(); // Refresh auctions
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> endAuction(String auctionId) async {
    try {
      _setLoading(true);
      _setError(null);

      final auction = await _databaseService.getAuction(auctionId);
      if (auction != null) {
        final updatedAuction = Auction(
          id: auction.id,
          productId: auction.productId,
          title: auction.title,
          description: auction.description,
          startingPrice: auction.startingPrice,
          currentBid: auction.currentBid,
          sellerId: auction.sellerId,
          startTime: auction.startTime,
          endTime: auction.endTime,
          imageUrls: auction.imageUrls,
          status: AuctionStatus.ended,
          bids: auction.bids,
          winnerId: auction.bids.isNotEmpty
              ? auction.bids
                  .reduce((a, b) => a.amount > b.amount ? a : b)
                  .userId
              : null,
          createdAt: auction.createdAt,
          updatedAt: DateTime.now(),
        );

        await _databaseService.updateAuction(updatedAuction);
        await fetchAuctions(); // Refresh auctions
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  List<Auction> getActiveAuctions() {
    return _auctions.where((auction) => auction.isActive).toList();
  }

  List<Auction> getEndedAuctions() {
    return _auctions
        .where((auction) => auction.status == AuctionStatus.ended)
        .toList();
  }

  List<Auction> getUserBidAuctions(String userId) {
    return _auctions
        .where((auction) => auction.bids.any((bid) => bid.userId == userId))
        .toList();
  }

  Bid? getHighestBid(String auctionId) {
    final auction = _auctions.firstWhere(
      (a) => a.id == auctionId,
      orElse: () => Auction(
        id: '',
        productId: '',
        title: '',
        description: '',
        startingPrice: 0,
        currentBid: 0,
        sellerId: '',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        imageUrls: [],
        status: AuctionStatus.active,
        bids: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (auction.id.isEmpty || auction.bids.isEmpty) return null;

    return auction.bids.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  void clearError() {
    _setError(null);
  }
}
