import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class SplashViewMVC extends StatefulWidget {
  const SplashViewMVC({super.key});

  @override
  State<SplashViewMVC> createState() => _SplashViewMVCState();
}

class _SplashViewMVCState extends State<SplashViewMVC>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthState();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  void _checkAuthState() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authController =
          Provider.of<AuthController>(context, listen: false);
      await authController.checkAuthState();

      if (mounted) {
        _navigateToNextScreen(authController.currentUser);
      }
    }
  }

  void _navigateToNextScreen(User? user) {
    if (user != null) {
      // User is logged in, navigate based on role
      switch (user.role) {
        case UserRole.customer:
          Navigator.pushReplacementNamed(context, AppRoutes.home);
          break;
        case UserRole.seller:
          if (user.isActive) {
            Navigator.pushReplacementNamed(context, AppRoutes.sellerHome);
          } else {
            // Seller account is inactive, sign out and go to login
            Provider.of<AuthController>(context, listen: false).signOut();
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
          break;
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, AppRoutes.home);
          break;
      }
    } else {
      // User is not logged in, navigate to login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animations
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.diamond,
                        size: 60,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'GemHub',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Discover Premium Gems',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade600,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
