class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main app routes
  static const String home = '/home';
  static const String profile = '/profile';

  // Product routes
  static const String products = '/products';
  static const String productDetail = '/product-detail';
  static const String categoryProducts = '/category-products';

  // Cart and Order routes
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String payment = '/payment';

  // Auction routes
  static const String auctions = '/auctions';
  static const String auctionDetail = '/auction-detail';
  static const String auctionPayment = '/auction-payment';

  // Seller routes
  static const String sellerHome = '/seller-home';
  static const String sellerProfile = '/seller-profile';
  static const String productListing = '/product-listing';
  static const String auctionListing = '/auction-listing';
  static const String listedProducts = '/listed-products';
  static const String listedAuctions = '/listed-auctions';
  static const String sellerOrders = '/seller-orders';
  static const String sellerOrderDetail = '/seller-order-detail';
  static const String sellerNotifications = '/seller-notifications';
}
