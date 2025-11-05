import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../widgets/common/loading_widget.dart';
import 'product_card_view.dart';
import 'product_detail_view.dart';

class ProductListView extends StatefulWidget {
  final String? category;
  final String? sellerId;
  final bool showSearchBar;
  final bool showFilters;

  const ProductListView({
    super.key,
    this.category,
    this.sellerId,
    this.showSearchBar = true,
    this.showFilters = true,
  });

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    final productController =
        Provider.of<ProductController>(context, listen: false);
    productController.fetchProducts(
      category: widget.category,
      sellerId: widget.sellerId,
    );
  }

  void _onSearchChanged(String query) {
    final productController =
        Provider.of<ProductController>(context, listen: false);
    productController.searchProducts(query);
  }

  void _onCategoryFilter(String? category) {
    final productController =
        Provider.of<ProductController>(context, listen: false);
    productController.filterByCategory(category);
  }

  void _onSortSelected(ProductSortOption sortOption) {
    final productController =
        Provider.of<ProductController>(context, listen: false);
    productController.sortProducts(sortOption);
  }

  void _onProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailView(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Consumer<ProductController>(
        builder: (context, productController, child) {
          return Column(
            children: [
              if (widget.showSearchBar) _buildSearchBar(productController),
              if (widget.showFilters) _buildFiltersBar(productController),
              Expanded(
                child: _buildProductList(productController),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.category != null
            ? '${widget.category} Products'
            : widget.sellerId != null
                ? 'My Products'
                : 'Products',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        Consumer<ProductController>(
          builder: (context, productController, child) {
            return PopupMenuButton<ProductSortOption>(
              icon: const Icon(Icons.sort),
              onSelected: _onSortSelected,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: ProductSortOption.newest,
                  child: Row(
                    children: [
                      Icon(Icons.new_releases, size: 20),
                      SizedBox(width: 8),
                      Text('Newest First'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ProductSortOption.oldest,
                  child: Row(
                    children: [
                      Icon(Icons.history, size: 20),
                      SizedBox(width: 8),
                      Text('Oldest First'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ProductSortOption.priceLowToHigh,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, size: 20),
                      SizedBox(width: 8),
                      Text('Price: Low to High'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ProductSortOption.priceHighToLow,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_downward, size: 20),
                      SizedBox(width: 8),
                      Text('Price: High to Low'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ProductSortOption.nameAscending,
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha, size: 20),
                      SizedBox(width: 8),
                      Text('Name: A to Z'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: ProductSortOption.nameDescending,
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha, size: 20),
                      SizedBox(width: 8),
                      Text('Name: Z to A'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar(ProductController productController) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildFiltersBar(ProductController productController) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All Categories',
                    isSelected: productController.selectedCategory == null,
                    onTap: () => _onCategoryFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Gemstones',
                    isSelected:
                        productController.selectedCategory == 'Gemstones',
                    onTap: () => _onCategoryFilter('Gemstones'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Jewelry',
                    isSelected: productController.selectedCategory == 'Jewelry',
                    onTap: () => _onCategoryFilter('Jewelry'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Raw Stones',
                    isSelected:
                        productController.selectedCategory == 'Raw Stones',
                    onTap: () => _onCategoryFilter('Raw Stones'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Accessories',
                    isSelected:
                        productController.selectedCategory == 'Accessories',
                    onTap: () => _onCategoryFilter('Accessories'),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: productController.selectedCategory != null
                  ? Colors.blue.shade600
                  : Colors.grey.shade600,
            ),
            onPressed: () => productController.clearFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProductList(ProductController productController) {
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

    if (productController.products.isEmpty) {
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
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productController.searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'No products available in this category',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            if (productController.searchQuery.isNotEmpty ||
                productController.selectedCategory != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  productController.clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadProducts(),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: productController.products.length,
        itemBuilder: (context, index) {
          final product = productController.products[index];
          return ProductCardView(
            product: product,
            onTap: () => _onProductTap(product),
          );
        },
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Only show FAB for sellers on their products page
        if (authController.currentUser?.role == UserRole.seller &&
            widget.sellerId == authController.currentUser?.id) {
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.productListing);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            backgroundColor: Colors.blue.shade600,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
