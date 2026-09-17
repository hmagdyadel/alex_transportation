import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:alex_transportation/firebase_options.dart';

/// Wraps Firebase initialization.
abstract final class FirebaseClient {
  static bool _initialized = false;

  /// Whether Firebase has been successfully initialized.
  static bool get isInitialized => _initialized;

  /// Attempts to initialize Firebase. Returns `true` on success.
  static Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        debugPrint('[FirebaseClient] ✓ Firebase already initialized (hot restart)');
        return true;
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      debugPrint('[FirebaseClient] ✓ Firebase initialized');
      return true;
    } catch (e) {
      debugPrint('[FirebaseClient] ✕ Firebase init failed: $e');
      debugPrint(
        '[FirebaseClient] Running in fallback mode without active Firebase connection.',
      );
      return false;
    }
  }
}
