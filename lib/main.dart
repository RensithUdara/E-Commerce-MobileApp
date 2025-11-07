import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/route_manager.dart';
import 'config/routes.dart';
import 'controllers/controllers.dart';
import 'screens/firebase_options/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
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
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => ProductController()),
          ChangeNotifierProvider(create: (_) => CartController()),
          ChangeNotifierProvider(create: (_) => OrderController()),
          ChangeNotifierProvider(create: (_) => AuctionController()),
          ChangeNotifierProvider(create: (_) => SellerController()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    // Handle initialization failure with a basic error app
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize app: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Function to sign in anonymously (can be called from elsewhere if needed)
Future<void> signInAnonymously() async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    print('Signed in anonymously with UID: ${userCredential.user?.uid}');
  } on FirebaseAuthException catch (e) {
    print('Failed to sign in anonymously: ${e.message}');
    rethrow; // Optionally rethrow to handle this error elsewhere
  } catch (e) {
    print('Unexpected error during anonymous sign-in: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GemHub Mobile App',
      theme: ThemeData.light(useMaterial3: true),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
}
