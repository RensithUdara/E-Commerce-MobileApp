import 'package:flutter/material.dart';

// MVC Views imports
import '../views/auth/forgot_password_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/signup_view.dart';
import '../views/auth/splash_view_mvc.dart';
import '../views/buyer/cart/cart_view.dart';
import '../views/buyer/cart/checkout_view.dart';
import '../views/buyer/home/home_view.dart';
import '../views/buyer/order/order_detail_view.dart';
import '../views/buyer/order/order_history_view.dart';
import '../views/buyer/product/product_list_view.dart';
import '../views/buyer/profile/buyer_profile_view.dart';
import '../views/seller/dashboard/seller_home_view.dart';
import '../views/seller/products/product_listing_view.dart';
import '../views/seller/products/seller_products_view.dart';
import 'routes.dart';

class RouteManager {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashViewMVC(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreenMVC(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreenMVC(),
          settings: settings,
        );

      case AppRoutes.sellerHome:
        return MaterialPageRoute(
          builder: (_) => const SellerHomeView(),
          settings: settings,
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpViewMVC(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordViewMVC(),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const BuyerProfileView(),
          settings: settings,
        );

      case AppRoutes.products:
        return MaterialPageRoute(
          builder: (_) => ProductListView(),
          settings: settings,
        );

      case AppRoutes.productListing:
        return MaterialPageRoute(
          builder: (_) => ProductListingView(),
          settings: settings,
        );

      case AppRoutes.listedProducts:
        return MaterialPageRoute(
          builder: (_) => SellerProductsView(),
          settings: settings,
        );

      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (_) => const CartView(),
          settings: settings,
        );

      case AppRoutes.checkout:
        return MaterialPageRoute(
          builder: (_) => const CheckoutView(),
          settings: settings,
        );

      case AppRoutes.orderHistory:
        return MaterialPageRoute(
          builder: (_) => const OrderHistoryView(),
          settings: settings,
        );

      case AppRoutes.orderDetail:
        final orderId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => OrderDetailView(orderId: orderId ?? ''),
          settings: settings,
        );

      case AppRoutes.sellerProfile:
        return MaterialPageRoute(
          builder: (_) => const SellerProfileView(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text('Route not found!'),
            ),
          ),
          settings: settings,
        );
    }
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
