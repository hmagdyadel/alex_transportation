import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure preferences manager for sensitive credentials and biometric settings.
class SecurePrefs {
  static late FlutterSecureStorage _storage;

  /// Initialize before usage (typically in main() bootstrap)
  static Future<void> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(resetOnError: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  /// Write string to secure storage
  static Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('[SecurePrefs] Error setting string: $e');
    }
  }

  /// Read string from secure storage
  static Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('[SecurePrefs] Error getting string: $e');
      return null;
    }
  }

  /// Write bool to secure storage
  static Future<void> setBool(String key, bool value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      debugPrint('[SecurePrefs] Error setting bool: $e');
    }
  }

  /// Read bool from secure storage
  static Future<bool> getBool(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value?.toLowerCase() == 'true';
    } catch (e) {
      debugPrint('[SecurePrefs] Error getting bool: $e');
      return false;
    }
  }

  /// Remove key from secure storage
  static Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('[SecurePrefs] Error removing key: $e');
    }
  }

  /// Clear all secure storage
  static Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('[SecurePrefs] Error clearing storage: $e');
    }
  }

  // ==================== BIOMETRIC METHODS ====================

  /// Check if biometric login is enabled by the user
  static Future<bool> isBiometricEnabled() async {
    return await getBool('biometric_enabled');
  }

  /// Enable biometric login
  static Future<void> enableBiometric() async {
    await setBool('biometric_enabled', true);
  }

  /// Disable biometric login
  static Future<void> disableBiometric() async {
    await setBool('biometric_enabled', false);
  }

  /// Save biometric login credentials
  static Future<void> saveBiometricCredentials({
    required String isl,
    required String password,
    required String role,
    required String name,
  }) async {
    await setString('biometric_isl', isl);
    await setString('biometric_password', password);
    await setString('biometric_role', role);
    await setString('biometric_name', name);
    await enableBiometric();
    await setString('biometric_action', 'enabled');
    debugPrint(
      '[SecurePrefs] ✅ Biometric credentials securely saved for ISL: $isl',
    );
  }

  /// Get stored biometric login credentials
  static Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final isl = await getString('biometric_isl');
      final password = await getString('biometric_password');
      final role = await getString('biometric_role') ?? 'employee';
      final name = await getString('biometric_name') ?? 'Bank Employee';

      if (isl == null || password == null) {
        debugPrint('[SecurePrefs] ⚠️ Biometric credentials not found');
        return null;
      }

      return {'isl': isl, 'password': password, 'role': role, 'name': name};
    } catch (e) {
      debugPrint('[SecurePrefs] Error getting biometric credentials: $e');
      return null;
    }
  }

  /// Clear stored biometric credentials
  static Future<void> clearBiometricCredentials() async {
    await remove('biometric_isl');
    await remove('biometric_password');
    await remove('biometric_role');
    await remove('biometric_name');
    await disableBiometric();
    await setString('biometric_action', 'disabled');
    debugPrint('[SecurePrefs] 🗑️ Biometric credentials cleared');
  }

  /// Records user decision on prompt ('enabled', 'skipped')
  static Future<void> setBiometricAction(String action) async {
    await setString('biometric_action', action);
  }

  /// Gets user decision on prompt ('enabled', 'skipped', or null)
  static Future<String?> getBiometricAction() async {
    return await getString('biometric_action');
  }
}
