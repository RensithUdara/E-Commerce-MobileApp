import 'routes.dart';

class RouteManager {
  static final Map<String, dynamic> _routeData = {};

  // Navigation methods
  static void navigateTo(String routeName, {Map<String, dynamic>? arguments}) {
    _routeData[routeName] = arguments ?? {};
    // This will be implemented with actual Flutter navigation later
    print('Navigating to: $routeName with arguments: $arguments');
  }

  static void navigateAndReplace(String routeName,
      {Map<String, dynamic>? arguments}) {
    _routeData[routeName] = arguments ?? {};
    // This will be implemented with actual Flutter navigation later
    print('Navigate and replace to: $routeName with arguments: $arguments');
  }

  static void navigateAndClearStack(String routeName,
      {Map<String, dynamic>? arguments}) {
    _routeData[routeName] = arguments ?? {};
    // This will be implemented with actual Flutter navigation later
    print('Navigate and clear stack to: $routeName with arguments: $arguments');
  }

  static void goBack() {
    // This will be implemented with actual Flutter navigation later
    print('Going back');
  }

  // Route data management
  static Map<String, dynamic>? getRouteData(String routeName) {
    return _routeData[routeName];
  }

  static void clearRouteData(String routeName) {
    _routeData.remove(routeName);
  }

  // Route validation
  static bool isValidRoute(String routeName) {
    return _getValidRoutes().contains(routeName);
  }

  static List<String> _getValidRoutes() {
    return [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
      AppRoutes.home,
      AppRoutes.profile,
      AppRoutes.products,
      AppRoutes.productDetail,
      AppRoutes.categoryProducts,
      AppRoutes.cart,
      AppRoutes.checkout,
      AppRoutes.orderHistory,
      AppRoutes.orderDetail,
      AppRoutes.payment,
      AppRoutes.auctions,
      AppRoutes.auctionDetail,
      AppRoutes.auctionPayment,
      AppRoutes.sellerHome,
      AppRoutes.sellerProfile,
      AppRoutes.productListing,
      AppRoutes.auctionListing,
      AppRoutes.listedProducts,
      AppRoutes.listedAuctions,
      AppRoutes.sellerOrders,
      AppRoutes.sellerOrderDetail,
      AppRoutes.sellerNotifications,
    ];
  }

  // Deep link handling
  static String? handleDeepLink(String url) {
    // Parse deep links and return appropriate route
    if (url.startsWith('/product/')) {
      return AppRoutes.productDetail;
    } else if (url.startsWith('/auction/')) {
      return AppRoutes.auctionDetail;
    } else if (url.startsWith('/category/')) {
      return AppRoutes.categoryProducts;
    }
    return AppRoutes.home;
  }
}
