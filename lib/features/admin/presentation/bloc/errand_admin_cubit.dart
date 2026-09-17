import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/errand_admin_states.dart';

/// Admin: manage errand car requests (approve/reject).
///
/// Phase 0: skeleton only.
class ErrandAdminCubit extends Cubit<ErrandAdminStates> {
  ErrandAdminCubit() : super(const ErrandAdminStates.initial());

  Future<void> loadData() async {
    safeEmit(const ErrandAdminStates.loading());
    // TODO: Phase 6
  }

  Future<void> approveRequest(String requestId) async {
    safeEmit(const ErrandAdminStates.approving());
    // TODO: Phase 6
  }

  Future<void> rejectRequest(String requestId) async {
    safeEmit(const ErrandAdminStates.rejecting());
    // TODO: Phase 6
  }

  // close() will be overridden in Phase 6 when subscriptions are added.
}
