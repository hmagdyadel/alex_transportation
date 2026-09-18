import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_data_seeder.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/admin/data/models/invite_code_model.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/access_admin_states.dart';

/// Admin: manage invite codes backed directly by Cloud Firestore collections.
class AccessAdminCubit extends Cubit<AccessAdminStates> {
  final List<InviteCodeModel> _codes = [];

  AccessAdminCubit() : super(const AccessAdminStates.initial()) {
    loadCodes();
  }

  List<InviteCodeModel> get codes => List.unmodifiable(_codes);

  /// Loads the active invite codes manifest directly from Cloud Firestore.
  Future<void> loadCodes() async {
    safeEmit(const AccessAdminStates.loading());

    final sync = FirestoreSyncService.instance;
    var loaded = await sync.getInviteCodes();
    if (loaded.isEmpty) {
      await FirestoreDataSeeder.seedInitialDataIfNeeded();
      loaded = await sync.getInviteCodes();
    }

    _codes.clear();
    _codes.addAll(loaded);

    safeEmit(const AccessAdminStates.loaded());
  }

  /// Generates a new access invite code and persists to Firestore.
  Future<void> generateCode({
    required String role,
    required String department,
    String? note,
  }) async {
    safeEmit(const AccessAdminStates.generatingCode());

    final prefix = role.toLowerCase() == 'admin'
        ? 'ADM'
        : role.toLowerCase() == 'driver'
            ? 'DRV'
            : 'EMP';

    final entropy = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final generatedCode = '$prefix-$entropy';

    final newInvite = InviteCodeModel(
      id: 'COD-${DateTime.now().millisecondsSinceEpoch}',
      code: generatedCode,
      role: role.toLowerCase(),
      department: department.trim(),
      createdAt: DateTime.now(),
      isActive: true,
      useCount: 0,
      note: note?.trim(),
    );

    _codes.insert(0, newInvite);
    await FirestoreSyncService.instance.saveInviteCode(newInvite);

    safeEmit(AccessAdminStates.success(newInvite));
    safeEmit(const AccessAdminStates.loaded());
  }

  /// Toggles an invite code's active status and updates Firestore.
  Future<void> toggleCodeStatus(String codeId) async {
    final index = _codes.indexWhere((c) => c.id == codeId);
    if (index == -1) return;

    final existing = _codes[index];
    final updated = existing.copyWith(isActive: !existing.isActive);
    _codes[index] = updated;

    await FirestoreSyncService.instance.saveInviteCode(updated);

    final statusMsg = updated.isActive ? 'activated' : 'deactivated';
    safeEmit(AccessAdminStates.success('Invite code ${updated.code} $statusMsg.'));
    safeEmit(const AccessAdminStates.loaded());
  }

  /// Revokes an invite code and updates Firestore.
  Future<void> revokeCode(String codeId) async {
    final index = _codes.indexWhere((c) => c.id == codeId);
    if (index == -1) return;

    final existing = _codes.removeAt(index);
    await FirestoreSyncService.instance.deleteInviteCode(codeId);

    safeEmit(AccessAdminStates.success('Invite code ${existing.code} revoked.'));
    safeEmit(const AccessAdminStates.loaded());
  }
}
