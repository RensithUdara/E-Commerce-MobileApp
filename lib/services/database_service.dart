import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart' hide Order;
import '../models/order_model.dart' as order_model;

abstract class DatabaseService {
  // User operations
  Future<void> createUser(User user);
  Future<User?> getUser(String userId);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String userId);

  // Product operations
  Future<void> createProduct(Product product);
  Future<Product?> getProduct(String productId);
  Future<List<Product>> getProducts({String? category, String? sellerId});
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String productId);

  // Cart operations
  Future<void> createCart(Cart cart);
  Future<Cart?> getCart(String userId);
  Future<void> updateCart(Cart cart);
  Future<void> deleteCart(String userId);

  // Order operations
  Future<void> createOrder(order_model.Order order);
  Future<order_model.Order?> getOrder(String orderId);
  Future<List<order_model.Order>> getUserOrders(String userId);
  Future<List<order_model.Order>> getSellerOrders(String sellerId);
  Future<void> updateOrder(order_model.Order order);

  // Auction operations
  Future<void> createAuction(Auction auction);
  Future<Auction?> getAuction(String auctionId);
  Future<List<Auction>> getAuctions({AuctionStatus? status});
  Future<void> updateAuction(Auction auction);
  Future<void> placeBid(String auctionId, Bid bid);

  // Category operations
  Future<List<Category>> getCategories();
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);

  // Banner operations
  Future<List<Banner>> getBanners();
  Future<void> createBanner(Banner banner);
}

class FirestoreService implements DatabaseService {
  // This will be implemented with actual Firestore imports later

  @override
  Future<void> createUser(User user) async {
    throw UnimplementedError();
  }

  @override
  Future<User?> getUser(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUser(User user) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> createProduct(Product product) async {
    throw UnimplementedError();
  }

  @override
  Future<Product?> getProduct(String productId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> getProducts(
      {String? category, String? sellerId}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateProduct(Product product) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProduct(String productId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> createCart(Cart cart) async {
    throw UnimplementedError();
  }

  @override
  Future<Cart?> getCart(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCart(Cart cart) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCart(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> createOrder(Order order) async {
    throw UnimplementedError();
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Order>> getUserOrders(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Order>> getSellerOrders(String sellerId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateOrder(Order order) async {
    throw UnimplementedError();
  }

  @override
  Future<void> createAuction(Auction auction) async {
    throw UnimplementedError();
  }

  @override
  Future<Auction?> getAuction(String auctionId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Auction>> getAuctions({AuctionStatus? status}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateAuction(Auction auction) async {
    throw UnimplementedError();
  }

  @override
  Future<void> placeBid(String auctionId, Bid bid) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> getCategories() async {
    throw UnimplementedError();
  }

  @override
  Future<void> createCategory(Category category) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCategory(Category category) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Banner>> getBanners() async {
    throw UnimplementedError();
  }

  @override
  Future<void> createBanner(Banner banner) async {
    throw UnimplementedError();
  }
}
