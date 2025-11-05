import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';

class OrderController extends ChangeNotifier {
  final DatabaseService _databaseService = FirestoreService();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _errorMessage = error;
  }

  Future<void> fetchUserOrders(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      _orders = await _databaseService.getUserOrders(userId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> fetchSellerOrders(String sellerId) async {
    try {
      _setLoading(true);
      _setError(null);

      _orders = await _databaseService.getSellerOrders(sellerId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<Order?> getOrder(String orderId) async {
    try {
      return await _databaseService.getOrder(orderId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> createOrder({
    required String userId,
    required List<CartItem> cartItems,
    required String shippingAddress,
    required PaymentMethod paymentMethod,
    String? deliveryDate,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final orderItems = cartItems
          .map((cartItem) => OrderItem(
                productId: cartItem.productId,
                title: cartItem.title,
                imageUrl: cartItem.imageUrl,
                price: cartItem.price,
                quantity: cartItem.quantity,
              ))
          .toList();

      final totalAmount = cartItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      final order = Order(
        id: '', // Will be set by database
        userId: userId,
        items: orderItems,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        shippingAddress: shippingAddress,
        deliveryDate: deliveryDate,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createOrder(order);
      await fetchUserOrders(userId); // Refresh orders
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      _setLoading(true);
      _setError(null);

      final order = await _databaseService.getOrder(orderId);
      if (order != null) {
        final updatedOrder = order.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        await _databaseService.updateOrder(updatedOrder);

        // Update local list
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }

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

  Future<bool> updateDeliveryDate(String orderId, String deliveryDate) async {
    try {
      _setLoading(true);
      _setError(null);

      final order = await _databaseService.getOrder(orderId);
      if (order != null) {
        final updatedOrder = order.copyWith(
          deliveryDate: deliveryDate,
          updatedAt: DateTime.now(),
        );
        await _databaseService.updateOrder(updatedOrder);

        // Update local list
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }

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

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<Order> getRecentOrders({int limit = 10}) {
    final sortedOrders = List<Order>.from(_orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders.take(limit).toList();
  }

  double getTotalOrderValue() {
    return _orders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
  }

  void clearError() {
    _setError(null);
  }
}
