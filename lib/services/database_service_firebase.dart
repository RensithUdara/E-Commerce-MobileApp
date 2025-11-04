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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _products => _firestore.collection('products');
  CollectionReference get _carts => _firestore.collection('carts');
  CollectionReference get _orders => _firestore.collection('orders');
  CollectionReference get _auctions => _firestore.collection('auctions');
  CollectionReference get _categories => _firestore.collection('categories');
  CollectionReference get _banners => _firestore.collection('banners');

  // User operations
  @override
  Future<void> createUser(User user) async {
    try {
      await _users.doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  @override
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await _users.doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _users.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Product operations
  @override
  Future<void> createProduct(Product product) async {
    try {
      if (product.id.isEmpty) {
        await _products.add(product.toMap());
      } else {
        await _products.doc(product.id).set(product.toMap());
      }
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _products.doc(productId).get();
      if (doc.exists) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  @override
  Future<List<Product>> getProducts(
      {String? category, String? sellerId}) async {
    try {
      Query query = _products;

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      await _products.doc(product.id).update(product.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _products.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Cart operations
  @override
  Future<void> createCart(Cart cart) async {
    try {
      await _carts.doc(cart.id).set(cart.toMap());
    } catch (e) {
      throw Exception('Failed to create cart: $e');
    }
  }

  @override
  Future<Cart?> getCart(String userId) async {
    try {
      final doc = await _carts.doc(userId).get();
      if (doc.exists) {
        return Cart.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  @override
  Future<void> updateCart(Cart cart) async {
    try {
      await _carts.doc(cart.id).update(cart.toMap());
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  @override
  Future<void> deleteCart(String userId) async {
    try {
      await _carts.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete cart: $e');
    }
  }

  // Order operations
  @override
  Future<void> createOrder(order_model.Order order) async {
    try {
      if (order.id.isEmpty) {
        await _orders.add(order.toMap());
      } else {
        await _orders.doc(order.id).set(order.toMap());
      }
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<order_model.Order?> getOrder(String orderId) async {
    try {
      final doc = await _orders.doc(orderId).get();
      if (doc.exists) {
        return order_model.Order.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Future<List<order_model.Order>> getUserOrders(String userId) async {
    try {
      final snapshot = await _orders
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => order_model.Order.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  @override
  Future<List<order_model.Order>> getSellerOrders(String sellerId) async {
    try {
      // For seller orders, we need to query based on order items
      // This is a simplified implementation
      final snapshot =
          await _orders.orderBy('createdAt', descending: true).get();

      return snapshot.docs
          .map((doc) => order_model.Order.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get seller orders: $e');
    }
  }

  @override
  Future<void> updateOrder(order_model.Order order) async {
    try {
      await _orders.doc(order.id).update(order.toMap());
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // Auction operations
  @override
  Future<void> createAuction(Auction auction) async {
    try {
      if (auction.id.isEmpty) {
        await _auctions.add(auction.toMap());
      } else {
        await _auctions.doc(auction.id).set(auction.toMap());
      }
    } catch (e) {
      throw Exception('Failed to create auction: $e');
    }
  }

  @override
  Future<Auction?> getAuction(String auctionId) async {
    try {
      final doc = await _auctions.doc(auctionId).get();
      if (doc.exists) {
        return Auction.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get auction: $e');
    }
  }

  @override
  Future<List<Auction>> getAuctions({AuctionStatus? status}) async {
    try {
      Query query = _auctions.orderBy('createdAt', descending: true);

      if (status != null) {
        query =
            query.where('status', isEqualTo: status.toString().split('.').last);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              Auction.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get auctions: $e');
    }
  }

  @override
  Future<void> updateAuction(Auction auction) async {
    try {
      await _auctions.doc(auction.id).update(auction.toMap());
    } catch (e) {
      throw Exception('Failed to update auction: $e');
    }
  }

  @override
  Future<void> placeBid(String auctionId, Bid bid) async {
    try {
      final auctionDoc = await _auctions.doc(auctionId).get();
      if (!auctionDoc.exists) {
        throw Exception('Auction not found');
      }

      final auction = Auction.fromMap(
          auctionDoc.data() as Map<String, dynamic>, auctionDoc.id);
      final updatedBids = List<Bid>.from(auction.bids)..add(bid);

      final updatedAuction = Auction(
        id: auction.id,
        productId: auction.productId,
        title: auction.title,
        description: auction.description,
        startingPrice: auction.startingPrice,
        currentBid: bid.amount,
        sellerId: auction.sellerId,
        startTime: auction.startTime,
        endTime: auction.endTime,
        imageUrls: auction.imageUrls,
        status: auction.status,
        bids: updatedBids,
        winnerId: auction.winnerId,
        createdAt: auction.createdAt,
        updatedAt: DateTime.now(),
      );

      await _auctions.doc(auctionId).update(updatedAuction.toMap());
    } catch (e) {
      throw Exception('Failed to place bid: $e');
    }
  }

  // Category operations
  @override
  Future<List<Category>> getCategories() async {
    try {
      final snapshot =
          await _categories.where('isActive', isEqualTo: true).get();
      return snapshot.docs
          .map((doc) =>
              Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<void> createCategory(Category category) async {
    try {
      if (category.id.isEmpty) {
        await _categories.add(category.toMap());
      } else {
        await _categories.doc(category.id).set(category.toMap());
      }
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      await _categories.doc(category.id).update(category.toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Banner operations
  @override
  Future<List<Banner>> getBanners() async {
    try {
      final now = DateTime.now();
      final snapshot = await _banners.where('isActive', isEqualTo: true).get();

      return snapshot.docs
          .map((doc) =>
              Banner.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((banner) => banner.isCurrentlyActive)
          .toList();
    } catch (e) {
      throw Exception('Failed to get banners: $e');
    }
  }

  @override
  Future<void> createBanner(Banner banner) async {
    try {
      if (banner.id.isEmpty) {
        await _banners.add(banner.toMap());
      } else {
        await _banners.doc(banner.id).set(banner.toMap());
      }
    } catch (e) {
      throw Exception('Failed to create banner: $e');
    }
  }
}
