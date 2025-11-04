import '../models/models.dart';
import '../services/services.dart';

class ProductController {
  final DatabaseService _databaseService = FirestoreService();
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;

  List<Product> get products => _filteredProducts.isNotEmpty ? _filteredProducts : _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _errorMessage = error;
  }

  Future<void> fetchProducts({String? category, String? sellerId}) async {
    try {
      _setLoading(true);
      _setError(null);

      _products = await _databaseService.getProducts(category: category, sellerId: sellerId);
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      return await _databaseService.getProduct(productId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<bool> createProduct(Product product) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.createProduct(product);
      await fetchProducts(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.updateProduct(product);
      await fetchProducts(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _databaseService.deleteProduct(productId);
      await fetchProducts(); // Refresh the list
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void sortProducts(ProductSortOption sortOption) {
    switch (sortOption) {
      case ProductSortOption.priceLowToHigh:
        _products.sort((a, b) => a.pricing.compareTo(b.pricing));
        break;
      case ProductSortOption.priceHighToLow:
        _products.sort((a, b) => b.pricing.compareTo(a.pricing));
        break;
      case ProductSortOption.nameAscending:
        _products.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ProductSortOption.nameDescending:
        _products.sort((a, b) => b.title.compareTo(a.title));
        break;
      case ProductSortOption.newest:
        _products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ProductSortOption.oldest:
        _products.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      bool matchesSearch = _searchQuery.isEmpty || 
          product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesCategory = _selectedCategory == null || 
          product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
  }

  void clearError() {
    _setError(null);
  }
}

enum ProductSortOption {
  priceLowToHigh,
  priceHighToLow,
  nameAscending,
  nameDescending,
  newest,
  oldest,
}