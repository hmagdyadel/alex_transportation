import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/auth/data/models/user_account_model.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_states.dart';

/// Manages ISL + Password authentication, session state, and role access.
class AuthCubit extends Cubit<AuthStates> {
  static const String _kOnboardingCompleteKey = 'onboarding_completed';
  static const String _kAuthTokenKey = 'auth_session_token';
  static const String _kUserRoleKey = 'user_role';
  static const String _kUserIslKey = 'user_isl';
  static const String _kUserNameKey = 'user_name';
  static const String _kIsAdminKey = 'is_admin_account';

  String _currentRole = 'employee';
  String _currentIsl = '10492';
  String _currentUserName = 'Ahmed Hassan';
  bool _isAdminAccount = false;

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

  AuthCubit() : super(const AuthStates.initial());

  String get currentRole => _currentRole;
  String get currentIsl => _currentIsl;
  String get currentUserName => _currentUserName;
  bool get isAdmin => _isAdminAccount || _currentRole == 'admin';

  List<UserAccountModel> get adminAccounts =>
      _accounts.where((a) => a.role == 'admin').toList();

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
    await Future.delayed(const Duration(milliseconds: 900));

    // Look up registered account
    final matchingAccount = _accounts.firstWhere(
      (a) => a.isl.toUpperCase() == cleanIsl ||
          a.isl.replaceAll('-', '').toUpperCase() == cleanIsl.replaceAll('-', ''),
      orElse: () {
        // Fallback for dynamic accounts
        final defaultRole = cleanIsl.startsWith('ADM')
            ? 'admin'
            : (cleanIsl.startsWith('DRV') ? 'driver' : 'employee');
        return UserAccountModel(
          isl: cleanIsl,
          name: cleanIsl.startsWith('DRV')
              ? 'Captain ($cleanIsl)'
              : (cleanIsl.startsWith('ADM') ? 'Admin ($cleanIsl)' : 'Employee ($cleanIsl)'),
          department: 'AlexBank General',
          role: defaultRole,
          password: cleanPassword,
        );
      },
    );

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
    safeEmit(const AuthStates.initial());
  }
}
