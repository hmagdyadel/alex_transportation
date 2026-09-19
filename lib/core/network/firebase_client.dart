import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:alex_transportation/firebase_options.dart';

/// Wraps Firebase initialization with resilient connection state tracking.
abstract final class FirebaseClient {
  static bool _initialized = false;

  /// Whether Firebase has been successfully initialized.
  static bool get isInitialized => _initialized;

  /// Whether the current Firebase configuration uses placeholder/dummy keys.
  static bool get isUsingPlaceholderKeys => _placeholderKeys;
  static bool _placeholderKeys = false;

  /// Attempts to initialize Firebase. Returns `true` on success.
  static Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      // Detect placeholder keys before attempting initialization
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.apiKey.contains('DUMMY') ||
          options.appId.contains('abcdef')) {
        _placeholderKeys = true;
        debugPrint('[FirebaseClient] ⚠ Placeholder Firebase keys detected.');
      }

      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        debugPrint(
          '[FirebaseClient] ✓ Firebase already initialized (hot restart)',
        );
        return true;
      }
      await Firebase.initializeApp(options: options);
      _initialized = true;
      debugPrint('[FirebaseClient] ✓ Firebase initialized');
      return true;
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        _initialized = true;
        debugPrint(
          '[FirebaseClient] ✓ Firebase already initialized ([DEFAULT] reused)',
        );
        return true;
      }
      debugPrint('[FirebaseClient] ✕ Firebase init failed: $e');
      debugPrint(
        '[FirebaseClient] Running in fallback mode without active Firebase connection.',
      );
      return false;
    }
  }
}
