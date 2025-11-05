import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';

class CartController extends ChangeNotifier {
  final DatabaseService _databaseService = FirestoreService();

  Cart? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  Cart? get cart => _cart;
  List<CartItem> get items => _cart?.items ?? [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalAmount => _cart?.totalAmount ?? 0.0;
  int get totalItems => _cart?.totalItems ?? 0;
  bool get isEmpty => items.isEmpty;

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _errorMessage = error;
  }

  Future<void> fetchCart(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      _cart = await _databaseService.getCart(userId);

      // Create empty cart if none exists
      if (_cart == null) {
        _cart = Cart(
          id: userId, // Using userId as cart id for simplicity
          userId: userId,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _databaseService.createCart(_cart!);
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> addToCart(Product product, {int quantity = 1}) async {
    if (_cart == null) return false;

    try {
      _setError(null);

      final existingItemIndex = _cart!.items.indexWhere(
        (item) => item.productId == product.id,
      );

      if (existingItemIndex != -1) {
        // Update existing item quantity
        final existingItem = _cart!.items[existingItemIndex];
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
        _cart!.items[existingItemIndex] = updatedItem;
      } else {
        // Add new item
        final newItem = CartItem(
          id: '${_cart!.id}_${product.id}',
          productId: product.id,
          title: product.title,
          imageUrl: product.primaryImageUrl,
          price: product.pricing,
          quantity: quantity,
        );
        _cart!.items.add(newItem);
      }

      await _databaseService.updateCart(_cart!);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> removeFromCart(String productId) async {
    if (_cart == null) return false;

    try {
      _setError(null);

      _cart!.items.removeWhere((item) => item.productId == productId);
      await _databaseService.updateCart(_cart!);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateQuantity(String productId, int quantity) async {
    if (_cart == null) return false;

    try {
      _setError(null);

      if (quantity <= 0) {
        return await removeFromCart(productId);
      }

      final itemIndex = _cart!.items.indexWhere(
        (item) => item.productId == productId,
      );

      if (itemIndex != -1) {
        final updatedItem =
            _cart!.items[itemIndex].copyWith(quantity: quantity);
        _cart!.items[itemIndex] = updatedItem;
        await _databaseService.updateCart(_cart!);
        return true;
      }

      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> incrementQuantity(String productId) async {
    if (_cart == null) return false;

    final item = _cart!.items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        id: '',
        productId: '',
        title: '',
        imageUrl: '',
        price: 0,
        quantity: 0,
      ),
    );

    if (item.id.isNotEmpty) {
      return await updateQuantity(productId, item.quantity + 1);
    }
    return false;
  }

  Future<bool> decrementQuantity(String productId) async {
    if (_cart == null) return false;

    final item = _cart!.items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        id: '',
        productId: '',
        title: '',
        imageUrl: '',
        price: 0,
        quantity: 0,
      ),
    );

    if (item.id.isNotEmpty) {
      return await updateQuantity(productId, item.quantity - 1);
    }
    return false;
  }

  Future<bool> clearCart() async {
    if (_cart == null) return false;

    try {
      _setError(null);

      _cart!.items.clear();
      await _databaseService.updateCart(_cart!);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  CartItem? getCartItem(String productId) {
    if (_cart == null) return null;

    try {
      return _cart!.items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  bool isInCart(String productId) {
    return getCartItem(productId) != null;
  }

  void clearError() {
    _setError(null);
  }
}
