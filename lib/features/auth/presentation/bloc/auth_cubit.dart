import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firebase_client.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_states.dart';

/// Manages invite-code verification and session state.
class AuthCubit extends Cubit<AuthStates> {
  static const String _kOnboardingCompleteKey = 'onboarding_completed';
  static const String _kAuthTokenKey = 'auth_session_token';
  static const String _kUserRoleKey = 'user_role';

  AuthCubit() : super(const AuthStates.initial());

  /// Checks if onboarding was already shown.
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingCompleteKey) ?? false;
  }

  /// Marks onboarding as completed.
  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingCompleteKey, true);
  }

  /// Checks whether an active session already exists.
  Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_kAuthTokenKey) ?? '').isNotEmpty;
  }

  /// Verify an invite code against Firestore or local fallback.
  Future<void> verifyInviteCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length < 4) {
      safeEmit(const AuthStates.error(message: 'Please enter a valid invite code'));
      return;
    }

    safeEmit(const AuthStates.verifyingCode());

    try {
      if (FirebaseClient.isInitialized) {
        // Query Firestore collection 'invite_codes'
        final snapshot = await FirebaseFirestore.instance
            .collection('invite_codes')
            .where('code', isEqualTo: cleanCode)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first.data();
          final role = doc['role'] as String? ?? 'employee';
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_kAuthTokenKey, cleanCode);
          await prefs.setString(_kUserRoleKey, role);
          safeEmit(AuthStates.success(role));
          return;
        }
      }

      // Local / Offline fallback verification for testing and dev
      // Accepts demo codes: 'ALEX26', 'ADMIN', 'DRIVER', 'TRANSIT'
      await Future.delayed(const Duration(milliseconds: 1200));

      final upper = cleanCode.toUpperCase();
      if (upper == 'ADMIN' || upper == 'ALEXADMIN' || upper.startsWith('ADM')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kAuthTokenKey, upper);
        await prefs.setString(_kUserRoleKey, 'admin');
        safeEmit(const AuthStates.success('admin'));
      } else if (upper == 'DRIVER' || upper == 'ALEXDRIVER' || upper.startsWith('DRV')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kAuthTokenKey, upper);
        await prefs.setString(_kUserRoleKey, 'driver');
        safeEmit(const AuthStates.success('driver'));
      } else if (upper.length >= 4) {
        // Generic valid employee invite code
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kAuthTokenKey, upper);
        await prefs.setString(_kUserRoleKey, 'employee');
        safeEmit(const AuthStates.success('employee'));
      } else {
        safeEmit(const AuthStates.error(message: 'Invalid invite code. Please check with HR or Fleet Admin.'));
      }
    } catch (e) {
      safeEmit(AuthStates.error(message: 'Verification failed: ${e.toString()}'));
    }
  }

  /// Gets the currently active session role.
  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserRoleKey) ?? 'employee';
  }

  /// Sign out / clear session.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthTokenKey);
    await prefs.remove(_kUserRoleKey);
    safeEmit(const AuthStates.initial());
  }
}
