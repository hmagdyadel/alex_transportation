import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/garage_admin_states.dart';

/// Admin: manage garage subscriptions, waitlist, cancellations, deductions.
///
/// Phase 0: skeleton only.
class GarageAdminCubit extends Cubit<GarageAdminStates> {
  GarageAdminCubit() : super(const GarageAdminStates.initial());

  Future<void> loadData() async {
    safeEmit(const GarageAdminStates.loading());
    // TODO: Phase 6
  }

  Future<void> approveWaiting(String id) async {
    safeEmit(const GarageAdminStates.approving());
    // TODO: Phase 6
  }

  Future<void> rejectWaiting(String id) async {
    safeEmit(const GarageAdminStates.rejecting());
    // TODO: Phase 6
  }

  Future<void> runMonthlyDeduction() async {
    safeEmit(const GarageAdminStates.runningDeduction());
    // TODO: Phase 6
  }

  Future<void> approveCancellation(String id) async {
    safeEmit(const GarageAdminStates.approvingCancellation());
    // TODO: Phase 6
  }

  Future<void> rejectCancellation(String id) async {
    safeEmit(const GarageAdminStates.rejectingCancellation());
    // TODO: Phase 6
  }

  // close() will be overridden in Phase 6 when subscriptions are added.
}
