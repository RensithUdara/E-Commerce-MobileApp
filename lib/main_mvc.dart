// Updated main.dart with MVC Architecture
// 
// This file has been restructured to follow MVC principles:
// - Clean separation of concerns
// - Proper dependency injection setup
// - Centralized provider management
// - Improved error handling
// - Better code organization

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// MVC Architecture imports
import 'controllers/controllers.dart';
import 'config/config.dart';
import 'mvc_structure.dart'; // Documentation file
import 'screens/firebase_options/firebase_options.dart';
import 'splash_screen.dart';

// Legacy provider imports (will be migrated to controllers)
import 'screens/cart_screen/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
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
        
        // MVC Controllers as providers (when implementing state management)
        // Provider(create: (_) => AuthController()),
        // Provider(create: (_) => ProductController()),
        // Provider(create: (_) => CartController()),
        // Provider(create: (_) => OrderController()),
        // Provider(create: (_) => AuctionController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GemHub - MVC Architecture',
        
        // Use custom theme when ready
        theme: ThemeData.light(useMaterial3: true),
        
        // Initial route
        home: const SplashScreen(),
        
        // Route management will be implemented here
        // onGenerateRoute: RouteManager.generateRoute,
        // onUnknownRoute: RouteManager.unknownRoute,
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

/*
 * MVC Architecture Implementation Notes:
 * 
 * 1. MODELS (lib/models/):
 *    - User, Product, Cart, Order, Auction models are created
 *    - Each model has proper serialization methods
 *    - Enums for status management
 * 
 * 2. VIEWS (lib/views/):
 *    - Screens organized by feature (auth, home, product, etc.)
 *    - Pure UI components without business logic
 * 
 * 3. CONTROLLERS (lib/controllers/):
 *    - AuthController: Manages authentication state and operations
 *    - ProductController: Handles product CRUD operations
 *    - CartController: Manages cart state and operations
 *    - OrderController: Handles order management
 *    - AuctionController: Manages auction operations
 * 
 * 4. SERVICES (lib/services/):
 *    - AuthService: Firebase authentication interface
 *    - DatabaseService: Firestore operations interface
 *    - Abstracted for easy testing and potential service switching
 * 
 * 5. UTILITIES (lib/utils/):
 *    - Constants: App-wide constants and configuration
 *    - Validators: Input validation functions
 * 
 * 6. WIDGETS (lib/widgets/):
 *    - Reusable UI components
 *    - Common widget configurations
 * 
 * 7. CONFIG (lib/config/):
 *    - Routes: Navigation route definitions
 *    - RouteManager: Navigation logic
 *    - Theme: App styling (ready for implementation)
 * 
 * Next Steps for Full Implementation:
 * 1. Implement Firebase integration in services
 * 2. Add state management to controllers
 * 3. Create view components using controllers
 * 4. Implement proper routing system
 * 5. Add theme management
 * 6. Migrate existing screens to new structure
 */