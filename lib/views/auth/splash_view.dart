import '../../../controllers/controllers.dart';
import '../../../config/routes.dart';

class SplashView {
  static void navigateToNextScreen(Function(String) navigate) {
    // Simple navigation logic without Flutter dependencies for now
    Future.delayed(const Duration(seconds: 2), () {
      navigate(AppRoutes.login);
    });
  }
  
  static Map<String, dynamic> getViewData() {
    return {
      'title': 'GemHub',
      'logoPath': 'assets/images/logo_new.png',
      'animationDuration': 1000, // milliseconds
    };
  }
}