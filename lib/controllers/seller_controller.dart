import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../models/order_model.dart' as order_model;
import '../services/database_service.dart';

class SellerController extends ChangeNotifier {
  // Use a concrete implementation or dependency injection in real app
  late final DatabaseService _databaseService = FirestoreService();

  List<Product> _sellerProducts = [];
  List<Auction> _sellerAuctions = [];
  List<order_model.Order> _sellerOrders = [];
  Map<String, dynamic> _sellerStats = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get sellerProducts => _sellerProducts;
  List<Auction> get sellerAuctions => _sellerAuctions;
  List<order_model.Order> get sellerOrders => _sellerOrders;
  Map<String, dynamic> get sellerStats => _sellerStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Fetch seller's products
  Future<void> fetchSellerProducts(String sellerId) async {
    try {
      _setLoading(true);
      _setError(null);

      _sellerProducts = await _databaseService.getProducts(sellerId: sellerId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Fetch seller's auctions
  Future<void> fetchSellerAuctions(String sellerId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Filter auctions by sellerId - this might need custom implementation
      final allAuctions = await _databaseService.getAuctions();
      _sellerAuctions =
          allAuctions.where((auction) => auction.sellerId == sellerId).toList();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Fetch seller's orders
  Future<void> fetchSellerOrders(String sellerId) async {
    try {
      _setLoading(true);
      _setError(null);

      _sellerOrders = await _databaseService.getSellerOrders(sellerId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  } // Fetch seller statistics

  Future<void> fetchSellerStats(String sellerId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Calculate stats from existing data or fetch from database
      final totalProducts = _sellerProducts.length;
      final totalAuctions = _sellerAuctions.length;
      final totalOrders = _sellerOrders.length;
      final totalRevenue = _sellerOrders
          .where((order) => order.status == OrderStatus.delivered)
          .fold(0.0, (sum, order) => sum + order.totalAmount);
      _sellerStats = {
        'totalProducts': totalProducts,
        'totalAuctions': totalAuctions,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'activeAuctions':
            _sellerAuctions.where((auction) => auction.isActive).length,
        'pendingOrders': _sellerOrders
            .where((order) => order.status == OrderStatus.pending)
            .length,
      };

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Create new product
  Future<bool> createProduct({
    required String title,
    required String description,
    required double pricing,
    required String category,
    required String unit,
    required int quantity,
    required List<String> imageUrls,
    required String sellerId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final product = Product(
        id: '', // Will be set by database
        title: title,
        description: description,
        pricing: pricing,
        category: category,
        unit: unit,
        quantity: quantity,
        imageUrls: imageUrls,
        sellerId: sellerId,
        status: ProductStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createProduct(product);
      await fetchSellerProducts(sellerId); // Refresh products
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  } // Update product

  Future<bool> updateProduct(Product product) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.updateProduct(product);
      await fetchSellerProducts(product.sellerId); // Refresh products
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId, String sellerId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.deleteProduct(productId);
      await fetchSellerProducts(sellerId); // Refresh products
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(
      String orderId, OrderStatus status, String sellerId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Get the existing order and update it
      final existingOrder = await _databaseService.getOrder(orderId);
      if (existingOrder != null) {
        final updatedOrder = order_model.Order(
          id: existingOrder.id,
          userId: existingOrder.userId,
          items: existingOrder.items,
          totalAmount: existingOrder.totalAmount,
          status: status,
          shippingAddress: existingOrder.shippingAddress,
          deliveryDate: existingOrder.deliveryDate,
          paymentMethod: existingOrder.paymentMethod,
          createdAt: existingOrder.createdAt,
          updatedAt: DateTime.now(),
        );
        await _databaseService.updateOrder(updatedOrder);
      }

      await fetchSellerOrders(sellerId); // Refresh orders
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Initialize seller data
  Future<void> initializeSellerData(String sellerId) async {
    await Future.wait([
      fetchSellerProducts(sellerId),
      fetchSellerAuctions(sellerId),
      fetchSellerOrders(sellerId),
    ]);
    await fetchSellerStats(sellerId);
  }
}
