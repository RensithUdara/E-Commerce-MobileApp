class CartItem {
  final String id;
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  factory CartItem.fromMap(Map<String, dynamic> data, String id) {
    return CartItem(
      id: id,
      productId: data['productId'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? title,
    String? imageUrl,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  factory Cart.fromMap(Map<String, dynamic> data, String id) {
    return Cart(
      id: id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((itemData) => CartItem.fromMap(itemData, itemData['id'] ?? ''))
              .toList() ??
          [],
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}