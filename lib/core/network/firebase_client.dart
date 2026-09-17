import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase initialization.
///
/// Phase 0: stubbed — the call is here but won't succeed without
/// `google-services.json` (Android) / `GoogleService-Info.plist` (iOS).
/// [main.dart] catches the failure gracefully so the app still runs.
abstract final class FirebaseClient {
  static bool _initialized = false;

  /// Whether Firebase has been successfully initialized.
  static bool get isInitialized => _initialized;

  /// Attempts to initialize Firebase. Returns `true` on success.
  ///
  /// Catches and logs errors so the app can still boot for local
  /// development without Firebase config files.
  static Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      await Firebase.initializeApp();
      _initialized = true;
      debugPrint('[FirebaseClient] ✓ Firebase initialized');
      return true;
    } catch (e) {
      debugPrint('[FirebaseClient] ✕ Firebase init failed: $e');
      debugPrint(
        '[FirebaseClient] The app will run in offline/stub mode. '
        'Provide google-services.json / GoogleService-Info.plist to enable Firebase.',
      );
      return false;
    }
  }
}
