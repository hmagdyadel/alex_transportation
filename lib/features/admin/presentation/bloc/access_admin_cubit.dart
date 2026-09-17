import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/access_admin_states.dart';

/// Admin: manage invite codes for the test rollout access gate.
///
/// Phase 0: skeleton only.
class AccessAdminCubit extends Cubit<AccessAdminStates> {
  AccessAdminCubit() : super(const AccessAdminStates.initial());

  Future<void> loadCodes() async {
    safeEmit(const AccessAdminStates.loading());
    // TODO: Phase 6
  }

  Future<void> generateCode() async {
    safeEmit(const AccessAdminStates.generatingCode());
    // TODO: Phase 6
  }

  // close() will be overridden in Phase 6 when subscriptions are added.
}
