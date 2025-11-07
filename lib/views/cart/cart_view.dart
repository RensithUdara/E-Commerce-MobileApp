import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/models.dart';
import '../../widgets/common/loading_widget.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      final cartController =
          Provider.of<CartController>(context, listen: false);

      if (authController.currentUser != null) {
        cartController.fetchCart(authController.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: Consumer<CartController>(
          builder: (context, cartController, child) {
            if (cartController.isLoading) {
              return Center(child: LoadingWidget.circular(size: 40));
            }

            if (cartController.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${cartController.errorMessage}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final authController =
                            Provider.of<AuthController>(context, listen: false);
                        if (authController.currentUser != null) {
                          cartController
                              .fetchCart(authController.currentUser!.id);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (cartController.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.products),
                      child: const Text('Continue Shopping'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartController.items.length,
                    itemBuilder: (context, index) {
                      final item = cartController.items[index];
                      return _buildCartItem(context, item, cartController);
                    },
                  ),
                ),
                _buildCartSummary(context, cartController),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, CartItem item, CartController cartController) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Remove Item'),
                  content: Text(
                      'Are you sure you want to remove "${item.title}" from your cart?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Remove'),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (_) {
        final authController =
            Provider.of<AuthController>(context, listen: false);
        if (authController.currentUser != null) {
          cartController.removeFromCart(
              authController.currentUser!.id, item.productId);
        }
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: item.quantity > 1
                              ? () {
                                  final authController =
                                      Provider.of<AuthController>(context,
                                          listen: false);
                                  if (authController.currentUser != null) {
                                    cartController.updateQuantity(
                                      authController.currentUser!.id,
                                      item.productId,
                                      item.quantity - 1,
                                    );
                                  }
                                }
                              : null,
                        ),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () {
                            final authController = Provider.of<AuthController>(
                                context,
                                listen: false);
                            if (authController.currentUser != null) {
                              cartController.updateQuantity(
                                authController.currentUser!.id,
                                item.productId,
                                item.quantity + 1,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary(
      BuildContext context, CartController cartController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items (${cartController.totalItems})',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Rs. ${cartController.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rs. ${cartController.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: cartController.isEmpty
                  ? null
                  : () {
                      Navigator.pushNamed(context, AppRoutes.checkout);
                    },
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
