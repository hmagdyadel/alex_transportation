import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/garage_admin_states.dart';

import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';

/// Admin: manage garage subscriptions, waitlist, cancellations, deductions, and parking fees.
class GarageAdminCubit extends Cubit<GarageAdminStates> {
  GarageAdminCubit() : super(const GarageAdminStates.initial());

  /// Current monthly parking fee.
  int get monthlyFee => GarageCubit.monthlyFee;

  /// Allows Admin to set the monthly parking fee.
  void setMonthlyFee(int newFee) {
    if (newFee <= 0) return;
    GarageCubit.monthlyFee = newFee;
    safeEmit(GarageAdminStates.success('Monthly parking fee updated to EGP $newFee'));
  }

  /// Allows Admin to increase the monthly parking fee.
  void increaseMonthlyFee([int step = 100]) {
    GarageCubit.monthlyFee += step;
    safeEmit(GarageAdminStates.success('Monthly parking fee increased to EGP ${GarageCubit.monthlyFee}'));
  }

  /// Allows Admin to decrease the monthly parking fee.
  void decreaseMonthlyFee([int step = 100]) {
    if (GarageCubit.monthlyFee - step >= 100) {
      GarageCubit.monthlyFee -= step;
      safeEmit(GarageAdminStates.success('Monthly parking fee decreased to EGP ${GarageCubit.monthlyFee}'));
    }
  }

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
