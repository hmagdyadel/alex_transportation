import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/services/biometric_helper.dart';
import 'package:alex_transportation/core/services/secure_prefs.dart';
import 'package:alex_transportation/features/auth/data/models/user_account_model.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_states.dart';

/// Manages ISL + Password authentication, User Registration, Session State, and Biometrics.
class AuthCubit extends Cubit<AuthStates> {
  static const String _kOnboardingCompleteKey = 'onboarding_completed';
  static const String _kAuthTokenKey = 'auth_session_token';
  static const String _kUserRoleKey = 'user_role';
  static const String _kUserIslKey = 'user_isl';
  static const String _kUserNameKey = 'user_name';
  static const String _kIsAdminKey = 'is_admin_account';
  static const String _kRegisteredAccountsKey = 'registered_accounts_json';

  String _currentRole = 'employee';
  String _currentIsl = '10492';
  String _currentUserName = 'Ahmed Hassan';
  bool _isAdminAccount = false;

  // Stored temporarily in memory for biometric setup bottom sheet
  String? _lastIsl;
  String? _lastPassword;
  String? _lastRole;
  String? _lastName;

  final List<UserAccountModel> _accounts = [
    const UserAccountModel(
      isl: 'ADM-9001',
      name: 'Haitham Adel',
      department: 'Operations & IT',
      role: 'admin',
      password: 'alex123',
    ),
    const UserAccountModel(
      isl: 'ADM-9002',
      name: 'Mona Kamel',
      department: 'Fleet Security & Logistics',
      role: 'admin',
      password: 'alex123',
    ),
    const UserAccountModel(
      isl: 'DRV-2001',
      name: 'Captain Mahmoud Sayed',
      department: 'Transit Fleet Services',
      role: 'driver',
      password: 'alex123',
    ),
    const UserAccountModel(
      isl: 'DRV-2002',
      name: 'Captain Tarek Fawzy',
      department: 'Transit Fleet Services',
      role: 'driver',
      password: 'alex123',
    ),
    const UserAccountModel(
      isl: '10492',
      name: 'Ahmed Hassan',
      department: 'Retail Banking',
      role: 'employee',
      password: 'alex123',
    ),
    const UserAccountModel(
      isl: 'EMP-1001',
      name: 'Sara Youssef',
      department: 'Risk Management',
      role: 'employee',
      password: 'alex123',
    ),
  ];

  AuthCubit() : super(const AuthStates.initial()) {
    _loadPersistedAccounts();
  }

  String get currentRole => _currentRole;
  String get currentIsl => _currentIsl;
  String get currentUserName => _currentUserName;
  bool get isAdmin => _isAdminAccount || _currentRole == 'admin';

  String? get lastIsl => _lastIsl;
  String? get lastPassword => _lastPassword;
  String? get lastRole => _lastRole;
  String? get lastName => _lastName;

  List<UserAccountModel> get adminAccounts =>
      _accounts.where((a) => a.role == 'admin').toList();

  /// Loads custom registered accounts persisted in SharedPreferences
  Future<void> _loadPersistedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kRegisteredAccountsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        for (final item in decoded) {
          final account = UserAccountModel.fromJson(item as Map<String, dynamic>);
          if (!_accounts.any((a) => a.isl.toUpperCase() == account.isl.toUpperCase())) {
            _accounts.insert(0, account);
          }
        }
      }
    } catch (_) {
      // Keep defaults if parsing fails
    }
  }

  /// Persists custom registered accounts to SharedPreferences
  Future<void> _persistAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Save all non-default accounts
      final customAccounts = _accounts
          .where((a) => a.isl != 'ADM-9001' && a.isl != 'ADM-9002' &&
              a.isl != 'DRV-2001' && a.isl != 'DRV-2002' &&
              a.isl != '10492' && a.isl != 'EMP-1001')
          .map((a) => a.toJson())
          .toList();
      await prefs.setString(_kRegisteredAccountsKey, jsonEncode(customAccounts));
    } catch (_) {}
  }

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
    final token = prefs.getString(_kAuthTokenKey) ?? '';
    if (token.isNotEmpty) {
      _currentRole = prefs.getString(_kUserRoleKey) ?? 'employee';
      _currentIsl = prefs.getString(_kUserIslKey) ?? token;
      _currentUserName = prefs.getString(_kUserNameKey) ?? 'Bank Employee';
      _isAdminAccount = prefs.getBool(_kIsAdminKey) ?? (_currentRole == 'admin');
      return true;
    }
    return false;
  }

  /// Register a new employee/driver/admin account for first-time users.
  Future<void> registerAccount({
    required String isl,
    required String name,
    required String department,
    required String role,
    required String password,
  }) async {
    final cleanIsl = isl.trim().toUpperCase();
    final cleanName = name.trim();
    final cleanDept = department.trim();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      safeEmit(const AuthStates.error(message: 'Please enter your Full Name'));
      return;
    }

    if (cleanIsl.isEmpty) {
      safeEmit(const AuthStates.error(message: 'Please enter your Bank Staff ISL'));
      return;
    }

    if (cleanPassword.length < 4) {
      safeEmit(const AuthStates.error(message: 'Password must be at least 4 characters'));
      return;
    }

    // Check if account already exists
    final exists = _accounts.any(
      (a) => a.isl.toUpperCase() == cleanIsl ||
          a.isl.replaceAll('-', '').toUpperCase() == cleanIsl.replaceAll('-', ''),
    );

    if (exists) {
      safeEmit(AuthStates.error(
        message: 'An account with ISL $cleanIsl already exists. Please Sign In.',
      ));
      return;
    }

    safeEmit(const AuthStates.verifyingCode());
    await Future.delayed(const Duration(milliseconds: 700));

    final newAccount = UserAccountModel(
      isl: cleanIsl,
      name: cleanName,
      department: cleanDept.isEmpty ? 'Central Operations' : cleanDept,
      role: role,
      password: cleanPassword,
      createdAt: DateTime.now(),
    );

    _accounts.insert(0, newAccount);
    await _persistAccounts();

    // Auto sign-in with newly registered credentials
    await loginWithIsl(
      isl: cleanIsl,
      password: cleanPassword,
      role: role,
    );
  }

  /// Primary login method with Bank Staff ISL, Password, and Role selection.
  Future<void> loginWithIsl({
    required String isl,
    required String password,
    required String role, // 'employee', 'driver', 'admin'
  }) async {
    final cleanIsl = isl.trim().toUpperCase();
    final cleanPassword = password.trim();

    if (cleanIsl.isEmpty) {
      safeEmit(const AuthStates.error(message: 'Please enter your Bank Staff ISL'));
      return;
    }

    if (cleanPassword.length < 4) {
      safeEmit(const AuthStates.error(message: 'Password must be at least 4 characters'));
      return;
    }

    safeEmit(const AuthStates.verifyingCode());
    await Future.delayed(const Duration(milliseconds: 600));

    // Look up registered account
    final index = _accounts.indexWhere(
      (a) => a.isl.toUpperCase() == cleanIsl ||
          a.isl.replaceAll('-', '').toUpperCase() == cleanIsl.replaceAll('-', ''),
    );

    if (index == -1) {
      safeEmit(AuthStates.error(
        message: 'Account with ISL $cleanIsl not found. Please register first.',
      ));
      return;
    }

    final matchingAccount = _accounts[index];

    // Validate Password
    if (matchingAccount.password != cleanPassword) {
      safeEmit(AuthStates.error(
        message: 'Invalid credentials. Password does not match ISL $cleanIsl.',
      ));
      return;
    }

    // Role Enforcement & Validation:
    // Rule: Admins can log in as 'admin' OR use 'employee' mode for garage/buses.
    // Employees CANNOT log in as driver or admin.
    // Drivers CANNOT log in as employee or admin.
    String resolvedRole = role;
    bool isActuallyAdmin = matchingAccount.role == 'admin';

    if (matchingAccount.role == 'employee') {
      if (role != 'employee') {
        safeEmit(AuthStates.error(
          message: 'Access Denied: ISL $cleanIsl is registered as Normal User (Employee). You cannot log in as ${role.toUpperCase()}.',
        ));
        return;
      }
    } else if (matchingAccount.role == 'driver') {
      if (role != 'driver') {
        safeEmit(AuthStates.error(
          message: 'Access Denied: ISL $cleanIsl is registered as Driver Captain. Please choose Driver role.',
        ));
        return;
      }
    } else if (matchingAccount.role == 'admin') {
      if (role == 'driver') {
        safeEmit(const AuthStates.error(
          message: 'Admin credentials cannot log in as Driver. Select Admin or Normal User.',
        ));
        return;
      }
      isActuallyAdmin = true;
      resolvedRole = role; // 'admin' or 'employee' (admin using user services)
    }

    // Store temporary credentials for biometric bottom sheet prompt
    _lastIsl = matchingAccount.isl;
    _lastPassword = cleanPassword;
    _lastRole = resolvedRole;
    _lastName = matchingAccount.name;

    // Save session
    _currentRole = resolvedRole;
    _currentIsl = matchingAccount.isl;
    _currentUserName = matchingAccount.name;
    _isAdminAccount = isActuallyAdmin;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAuthTokenKey, matchingAccount.isl);
    await prefs.setString(_kUserRoleKey, resolvedRole);
    await prefs.setString(_kUserIslKey, matchingAccount.isl);
    await prefs.setString(_kUserNameKey, matchingAccount.name);
    await prefs.setBool(_kIsAdminKey, isActuallyAdmin);

    safeEmit(AuthStates.success(resolvedRole));
  }

  // ==================== BIOMETRICS ====================

  /// Check if biometric hardware is supported and enabled in app
  Future<bool> checkBiometricAvailability() async {
    final isSupported = await BiometricHelper.isBiometricSupported();
    if (!isSupported) return false;
    return await SecurePrefs.isBiometricEnabled();
  }

  /// Check if credentials exist in secure storage
  Future<bool> hasSavedBiometricCredentials() async {
    final creds = await SecurePrefs.getBiometricCredentials();
    return creds != null;
  }

  /// Attempt biometric login
  Future<void> loginWithBiometrics() async {
    final isSupported = await BiometricHelper.isBiometricSupported();
    if (!isSupported) {
      safeEmit(const AuthStates.error(
        message: 'Biometric authentication is not supported on this device.',
      ));
      return;
    }

    final creds = await SecurePrefs.getBiometricCredentials();
    if (creds == null) {
      safeEmit(const AuthStates.error(
        message: 'No saved biometric credentials found. Please sign in with your ISL.',
      ));
      return;
    }

    final authenticated = await BiometricHelper.authenticate(
      localizedReason: 'Please authenticate to access AlexBank Transit',
    );

    if (!authenticated) {
      safeEmit(const AuthStates.error(
        message: 'Biometric authentication cancelled or failed.',
      ));
      return;
    }

    await loginWithIsl(
      isl: creds['isl']!,
      password: creds['password']!,
      role: creds['role'] ?? 'employee',
    );
  }

  /// Enable biometric login with provided credentials
  Future<void> enableBiometricLogin({
    required String isl,
    required String password,
    required String role,
    required String name,
  }) async {
    await SecurePrefs.saveBiometricCredentials(
      isl: isl,
      password: password,
      role: role,
      name: name,
    );
  }

  /// Disable biometric login
  Future<void> disableBiometricLogin() async {
    await SecurePrefs.clearBiometricCredentials();
  }

  /// Clear temporary credentials from memory
  void clearLastCredentials() {
    _lastIsl = null;
    _lastPassword = null;
    _lastRole = null;
    _lastName = null;
  }

  /// Allows existing Admins to provision and register new Administrator accounts.
  Future<void> registerNewAdmin({
    required String isl,
    required String name,
    required String department,
    required String password,
  }) async {
    final cleanIsl = isl.trim().toUpperCase();
    final cleanName = name.trim();
    final cleanDept = department.trim();
    final cleanPassword = password.trim();

    if (cleanIsl.isEmpty || cleanName.isEmpty || cleanPassword.isEmpty) {
      safeEmit(const AuthStates.error(message: 'Please fill all required admin fields'));
      return;
    }

    final exists = _accounts.any((a) => a.isl.toUpperCase() == cleanIsl);
    if (exists) {
      safeEmit(AuthStates.error(message: 'An account with ISL $cleanIsl already exists.'));
      return;
    }

    final newAdmin = UserAccountModel(
      isl: cleanIsl,
      name: cleanName,
      department: cleanDept.isEmpty ? 'Central Operations' : cleanDept,
      role: 'admin',
      password: cleanPassword,
      createdAt: DateTime.now(),
    );

    _accounts.insert(0, newAdmin);
    await _persistAccounts();
    safeEmit(AuthStates.success('New Admin "$cleanName" ($cleanIsl) registered successfully'));
  }

  /// Sets active role in memory (used during role switching in dev/admin).
  void setCurrentRole(String role) {
    _currentRole = role;
  }

  /// Verify legacy invite codes for testing compatibility.
  Future<void> verifyInviteCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length < 4) {
      safeEmit(const AuthStates.error(message: 'Please enter a valid invite code'));
      return;
    }

    final role = (cleanCode == 'ADMIN' || cleanCode.startsWith('ADM'))
        ? 'admin'
        : ((cleanCode == 'DRIVER' || cleanCode.startsWith('DRV')) ? 'driver' : 'employee');

    await loginWithIsl(isl: cleanCode, password: 'alex123', role: role);
  }

  /// Gets the currently active session role.
  Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_kUserRoleKey) ?? 'employee';
    _currentRole = role;
    return role;
  }

  /// Sign out / clear session.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAuthTokenKey);
    await prefs.remove(_kUserRoleKey);
    await prefs.remove(_kUserIslKey);
    await prefs.remove(_kUserNameKey);
    await prefs.remove(_kIsAdminKey);
    _currentRole = 'employee';
    _isAdminAccount = false;
    clearLastCredentials();
    safeEmit(const AuthStates.initial());
  }
}
