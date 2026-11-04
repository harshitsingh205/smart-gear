import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'services/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely initialize Firebase according to platform (Web vs Native Android/iOS)
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: FirebaseConfig.apiKey,
          authDomain: FirebaseConfig.authDomain,
          projectId: FirebaseConfig.projectId,
          storageBucket: FirebaseConfig.storageBucket,
          messagingSenderId: FirebaseConfig.messagingSenderId,
          appId: FirebaseConfig.appId,
          measurementId: FirebaseConfig.measurementId,
        ),
      );
    } else {
      // On Android/iOS, initialize from google-services.json with fallback
      try {
        await Firebase.initializeApp();
      } catch (_) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: FirebaseConfig.androidApiKey,
            authDomain: FirebaseConfig.authDomain,
            projectId: FirebaseConfig.projectId,
            storageBucket: FirebaseConfig.storageBucket,
            messagingSenderId: FirebaseConfig.messagingSenderId,
            appId: FirebaseConfig.androidAppId,
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  // Ensure app ALWAYS launches regardless of network/Firebase state
  runApp(const SmartGearApp());
}
