import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/data/models/invite_code_model.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/access_admin_states.dart';

/// Admin: manage invite codes for the test rollout access gate.
class AccessAdminCubit extends Cubit<AccessAdminStates> {
  final List<InviteCodeModel> _codes = [];

  AccessAdminCubit() : super(const AccessAdminStates.initial()) {
    loadCodes();
  }

  List<InviteCodeModel> get codes => List.unmodifiable(_codes);

  /// Loads the active invite codes manifest.
  Future<void> loadCodes() async {
    safeEmit(const AccessAdminStates.loading());
    await Future.delayed(const Duration(milliseconds: 200));

    if (_codes.isEmpty) {
      _codes.addAll([
        InviteCodeModel(
          id: 'COD-101',
          code: 'ADM-7788',
          role: 'admin',
          department: 'Operations & IT',
          createdAt: DateTime(2026, 9, 1),
          isActive: true,
          useCount: 14,
          note: 'Executive Transportation Admin Team',
        ),
        InviteCodeModel(
          id: 'COD-102',
          code: 'DRV-5521',
          role: 'driver',
          department: 'Fleet Transport',
          createdAt: DateTime(2026, 9, 2),
          isActive: true,
          useCount: 28,
          note: 'Authorized Captains & Chauffeurs',
        ),
        InviteCodeModel(
          id: 'COD-103',
          code: 'EMP-2026',
          role: 'employee',
          department: 'All Departments',
          createdAt: DateTime(2026, 9, 5),
          isActive: true,
          useCount: 142,
          note: 'General Employee Mobility Pass',
        ),
      ]);
    }

    safeEmit(const AccessAdminStates.loaded());
  }

  /// Generates a new access invite code.
  Future<void> generateCode({
    String role = 'employee',
    String department = 'Operations',
    String? note,
  }) async {
    safeEmit(const AccessAdminStates.generatingCode());
    await Future.delayed(const Duration(milliseconds: 300));

    final prefix = role == 'admin' ? 'ADM' : (role == 'driver' ? 'DRV' : 'EMP');
    final randomNum = (1000 + DateTime.now().millisecondsSinceEpoch % 9000);
    final code = '$prefix-$randomNum';

    final newCode = InviteCodeModel(
      id: 'COD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      code: code,
      role: role,
      department: department,
      createdAt: DateTime.now(),
      isActive: true,
      note: note,
    );

    _codes.insert(0, newCode);
    safeEmit(AccessAdminStates.success(newCode));
    safeEmit(const AccessAdminStates.loaded());
  }

  /// Toggles active status of an invite code.
  void toggleCodeStatus(String id) {
    final index = _codes.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final current = _codes[index];
    _codes[index] = current.copyWith(isActive: !current.isActive);
    safeEmit(AccessAdminStates.success(
      'Code ${current.code} is now ${!current.isActive ? "ACTIVE" : "INACTIVE"}',
    ));
    safeEmit(const AccessAdminStates.loaded());
  }

  /// Revokes an invite code.
  void revokeCode(String id) {
    final code = _codes.firstWhere((c) => c.id == id, orElse: () => _codes.first);
    _codes.removeWhere((c) => c.id == id);
    safeEmit(AccessAdminStates.success('Invite code ${code.code} has been revoked'));
    safeEmit(const AccessAdminStates.loaded());
  }
}
