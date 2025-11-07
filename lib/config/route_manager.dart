import 'package:flutter/material.dart';

import '../Seller/seller_home_page.dart';
import '../home_screen.dart';
import '../screens/auth_screens/forgot_password_screen.dart';
import '../screens/auth_screens/signup_screen.dart';
import '../views/auth/login_view.dart';
import '../views/auth/splash_view_mvc.dart';
import '../views/product/product_list_view.dart';
import '../views/seller/product_listing_view.dart';
import '../views/seller/seller_products_view.dart';
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
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.sellerHome:
        return MaterialPageRoute(
          builder: (_) => const SellerHomePage(),
          settings: settings,
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
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
