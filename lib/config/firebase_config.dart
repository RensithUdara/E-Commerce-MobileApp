import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> configureFirebaseAuth() async {
    // Configure Firebase Auth settings for development
    if (kDebugMode) {
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );
    }
  }

  static Future<void> configureAppCheck() async {
    await FirebaseAppCheck.instance.activate(
      // For Android
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,

      // For iOS
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,

      // For web - you'll need to get a reCAPTCHA site key from Firebase Console
      webProvider: kDebugMode
          ? ReCaptchaV3Provider('debug')
          : ReCaptchaV3Provider('your-production-recaptcha-site-key'),
    );
  }

  static Future<void> initializeAll() async {
    await configureAppCheck();
    await configureFirebaseAuth();
  }
}
