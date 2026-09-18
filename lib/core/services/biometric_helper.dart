import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Helper wrapper around [LocalAuthentication] for device biometrics.
class BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometrics (or device authentication) is supported on device
  static Future<bool> isBiometricSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported || canCheck;
    } catch (e) {
      debugPrint('[BiometricHelper] Error checking biometric support: $e');
      return false;
    }
  }

  /// Get available biometrics (face, fingerprint, iris, etc.)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('[BiometricHelper] Error fetching available biometrics: $e');
      return [];
    }
  }

  /// Authenticate user with biometrics OR fallback to device PIN/Passcode
  static Future<bool> authenticate({String? localizedReason}) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason ?? 'Please authenticate to access AlexBank Transit',
        biometricOnly: false, // Allows fallback to device PIN/Passcode if biometrics fail
        persistAcrossBackgrounding: true, // Retains auth prompt state during brief backgrounding
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('[BiometricHelper] Biometric auth error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BiometricHelper] Unexpected biometric error: $e');
      return false;
    }
  }

  /// Helper: return user-friendly label for current platform biometric capability
  static Future<String> getPreferredBiometricLabel() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) return 'Face ID';
    if (biometrics.contains(BiometricType.fingerprint)) return 'Fingerprint';
    return 'Biometrics';
  }
}
