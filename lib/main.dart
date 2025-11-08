// Updated main.dart with MVC Architecture
//
// This file has been restructured to follow MVC principles:
// - Clean separation of concerns
// - Proper dependency injection setup
// - Centralized provider management
// - Improved error handling
// - Better code organization

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// MVC Architecture imports
import 'config/firebase_options.dart';
import 'config/route_manager.dart';
import 'config/routes.dart';
import 'controllers/controllers.dart';
// Legacy provider imports (will be migrated to controllers)
import 'screens/cart_screen/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure Firebase App Check for development
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider('debug'), // Use debug for development
    );

    // Configure Firebase Auth settings for development
    if (kDebugMode) {
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );
    }

    runApp(const GemHubApp());
  } catch (e) {
    // Handle initialization failure with error app
    runApp(ErrorApp(error: e.toString()));
  }
}

class GemHubApp extends StatelessWidget {
  const GemHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Legacy providers (to be migrated)
        ChangeNotifierProvider(create: (_) => CartProvider()),

        // MVC Controllers as providers
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => AuctionController()),
        ChangeNotifierProvider(create: (_) => SellerController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GemHub - MVC Architecture',

        // Use custom theme when ready
        theme: ThemeData.light(useMaterial3: true),

        // Use MVC routing
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Failed to Initialize App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Anonymous sign-in function (moved here for better organization)
Future<void> signInAnonymously() async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    debugPrint('Signed in anonymously with UID: ${userCredential.user?.uid}');
  } on FirebaseAuthException catch (e) {
    debugPrint('Failed to sign in anonymously: ${e.message}');
    rethrow;
  } catch (e) {
    debugPrint('Unexpected error during anonymous sign-in: $e');
    rethrow;
  }
}
