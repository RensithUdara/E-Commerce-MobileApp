class Product {
  final String id;
  final String title;
  final String description;
  final double pricing;
  final String category;
  final String unit;
  final int quantity;
  final List<String> imageUrls;
  final String sellerId;
  final ProductStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;
  final int? reviewCount;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.pricing,
    required this.category,
    required this.unit,
    required this.quantity,
    required this.imageUrls,
    required this.sellerId,
    this.status = ProductStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.reviewCount,
  });

  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      pricing: (data['pricing'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      unit: data['unit'] ?? '',
      quantity: data['quantity'] ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] ?? [data['imageUrl'] ?? '']),
      sellerId: data['sellerId'] ?? '',
      status: ProductStatus.values.firstWhere(
        (status) => status.toString().split('.').last == (data['status'] ?? 'active'),
        orElse: () => ProductStatus.active,
      ),
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : DateTime.now(),
      rating: (data['rating'] as num?)?.toDouble(),
      reviewCount: data['reviewCount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'pricing': pricing,
      'category': category,
      'unit': unit,
      'quantity': quantity,
      'imageUrls': imageUrls,
      'sellerId': sellerId,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? pricing,
    String? category,
    String? unit,
    int? quantity,
    List<String>? imageUrls,
    String? sellerId,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pricing: pricing ?? this.pricing,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
}

enum ProductStatus {
  active,
  inactive,
  outOfStock,
  deleted,
}