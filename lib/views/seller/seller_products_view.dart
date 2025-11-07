import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../product/product_card_view.dart';
import 'product_listing_view.dart';

class SellerProductsView extends StatefulWidget {
  const SellerProductsView({super.key});

  @override
  State<SellerProductsView> createState() => _SellerProductsViewState();
}

class _SellerProductsViewState extends State<SellerProductsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _sellerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      _sellerId = authController.currentUser?.id;
      if (_sellerId != null) {
        _loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    final productController =
        Provider.of<ProductController>(context, listen: false);
    productController.fetchProducts(sellerId: _sellerId);
  }

  void _onProductTap(Product product) {
    _showProductOptionsBottomSheet(product);
  }

  void _showProductOptionsBottomSheet(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Product'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditProduct(product);
              },
            ),
            ListTile(
              leading: Icon(
                product.status == ProductStatus.active
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              title: Text(
                product.status == ProductStatus.active
                    ? 'Deactivate Product'
                    : 'Activate Product',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleProductStatus(product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Product'),
              onTap: () {
                Navigator.pop(context);
                _shareProduct(product);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Product',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteProduct(product);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProduct(Product product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListingView(product: product),
      ),
    );

    if (result == true) {
      _loadProducts(); // Refresh the list
    }
  }

  void _toggleProductStatus(Product product) async {
    final productController =
        Provider.of<ProductController>(context, listen: false);

    final newStatus = product.status == ProductStatus.active
        ? ProductStatus.inactive
        : ProductStatus.active;

    final updatedProduct = Product(
      id: product.id,
      title: product.title,
      description: product.description,
      pricing: product.pricing,
      category: product.category,
      unit: product.unit,
      quantity: product.quantity,
      imageUrls: product.imageUrls,
      sellerId: product.sellerId,
      status: newStatus,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
      rating: product.rating,
      reviewCount: product.reviewCount,
    );

    final success = await productController.updateProduct(updatedProduct);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Product ${newStatus == ProductStatus.active ? 'activated' : 'deactivated'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productController.errorMessage ??
                'Failed to update product status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareProduct(Product product) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(Product product) async {
    final productController =
        Provider.of<ProductController>(context, listen: false);

    final success = await productController.deleteProduct(product.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                productController.errorMessage ?? 'Failed to delete product'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade600,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade600,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Inactive'),
            Tab(text: 'Out of Stock'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ProductController>(
        builder: (context, productController, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildProductGrid(productController, null),
              _buildProductGrid(productController, ProductStatus.active),
              _buildProductGrid(productController, ProductStatus.inactive),
              _buildProductGrid(productController, ProductStatus.outOfStock),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductListingView(),
            ),
          );

          if (result == true) {
            _loadProducts(); // Refresh the list
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildProductGrid(
      ProductController productController, ProductStatus? statusFilter) {
    if (productController.isLoading) {
      return Center(child: LoadingWidget.circular(size: 40));
    }

    if (productController.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productController.errorMessage!,
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    List<Product> filteredProducts = productController.products;
    if (statusFilter != null) {
      filteredProducts = productController.products
          .where((product) => product.status == statusFilter)
          .toList();
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              statusFilter == null
                  ? 'No products yet'
                  : 'No ${_getStatusText(statusFilter)} products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusFilter == null
                  ? 'Start by adding your first product'
                  : 'No products found with this status',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListingView(),
                  ),
                );

                if (result == true) {
                  _loadProducts();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadProducts(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return Stack(
            children: [
              ProductCardView(
                product: product,
                onTap: () => _onProductTap(product),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(product.status).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(product.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getStatusText(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return 'Active';
      case ProductStatus.inactive:
        return 'Inactive';
      case ProductStatus.outOfStock:
        return 'Out of Stock';
      case ProductStatus.deleted:
        return 'Deleted';
    }
  }

  Color _getStatusColor(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return Colors.green;
      case ProductStatus.inactive:
        return Colors.grey;
      case ProductStatus.outOfStock:
        return Colors.red;
      case ProductStatus.deleted:
        return Colors.black;
    }
  }
}
