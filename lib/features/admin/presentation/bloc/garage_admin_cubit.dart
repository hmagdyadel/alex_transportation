import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/garage_admin_states.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';

/// Admin: manage garage subscriptions, waitlist, cancellations, deductions, and parking fees.
class GarageAdminCubit extends Cubit<GarageAdminStates> {
  final List<Map<String, dynamic>> _waitingList = [];
  final List<Map<String, dynamic>> _cancellations = [];
  final List<Map<String, dynamic>> _subscriptions = [];

  GarageAdminCubit() : super(const GarageAdminStates.initial()) {
    loadData();
  }

  List<Map<String, dynamic>> get waitingList => List.unmodifiable(_waitingList);
  List<Map<String, dynamic>> get cancellations => List.unmodifiable(_cancellations);
  List<Map<String, dynamic>> get subscriptions => List.unmodifiable(_subscriptions);

  /// Current monthly parking fee.
  int get monthlyFee => GarageCubit.monthlyFee;

  /// Allows Admin to set the monthly parking fee.
  void setMonthlyFee(int newFee) {
    if (newFee <= 0) return;
    GarageCubit.monthlyFee = newFee;
    safeEmit(GarageAdminStates.success('Monthly parking fee updated to EGP $newFee'));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Allows Admin to increase the monthly parking fee.
  void increaseMonthlyFee([int step = 100]) {
    GarageCubit.monthlyFee += step;
    safeEmit(GarageAdminStates.success('Monthly parking fee increased to EGP ${GarageCubit.monthlyFee}'));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Allows Admin to decrease the monthly parking fee.
  void decreaseMonthlyFee([int step = 100]) {
    if (GarageCubit.monthlyFee - step >= 100) {
      GarageCubit.monthlyFee -= step;
      safeEmit(GarageAdminStates.success('Monthly parking fee decreased to EGP ${GarageCubit.monthlyFee}'));
      safeEmit(const GarageAdminStates.loaded());
    }
  }

  /// Loads garage operational metrics, waitlists, and cancellation requests.
  Future<void> loadData() async {
    safeEmit(const GarageAdminStates.loading());
    await Future.delayed(const Duration(milliseconds: 200));

    if (_waitingList.isEmpty) {
      _waitingList.addAll([
        {
          'id': 'WAIT-001',
          'name': 'Hossam Hassan',
          'isl': '18204',
          'department': 'Corporate Banking',
          'appliedAt': '2026-09-10',
        },
        {
          'id': 'WAIT-002',
          'name': 'Nadine Fahmy',
          'isl': '19302',
          'department': 'Digital Products',
          'appliedAt': '2026-09-12',
        },
      ]);
    }

    if (_cancellations.isEmpty) {
      _cancellations.addAll([
        {
          'id': 'CAN-001',
          'name': 'Kareem Sobhy',
          'isl': '14201',
          'slotLabel': 'P1-022',
          'requestedAt': '2026-09-15',
        },
      ]);
    }

    if (_subscriptions.isEmpty) {
      _subscriptions.addAll([
        {
          'id': 'SUB-G01',
          'name': 'Mohamed Ali',
          'isl': '10492',
          'slotLabel': 'P1-014',
          'status': 'active',
        },
      ]);
    }

    safeEmit(const GarageAdminStates.loaded());
  }

  /// Approves a waitlist application and assigns a parking bay.
  Future<void> approveWaiting(String id) async {
    safeEmit(const GarageAdminStates.approving());
    await Future.delayed(const Duration(milliseconds: 300));

    final applicant = _waitingList.firstWhere((w) => w['id'] == id, orElse: () => {});
    _waitingList.removeWhere((w) => w['id'] == id);

    if (applicant.isNotEmpty) {
      _subscriptions.add({
        'id': 'SUB-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'name': applicant['name'],
        'isl': applicant['isl'],
        'slotLabel': 'P1-${100 + _subscriptions.length}',
        'status': 'active',
      });
    }

    safeEmit(GarageAdminStates.success('Waitlist application $id approved'));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Rejects a waitlist application.
  Future<void> rejectWaiting(String id) async {
    safeEmit(const GarageAdminStates.rejecting());
    await Future.delayed(const Duration(milliseconds: 300));

    _waitingList.removeWhere((w) => w['id'] == id);

    safeEmit(GarageAdminStates.success('Waitlist application $id rejected'));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Runs the automated monthly payroll deduction batch for all active parking subscribers.
  Future<void> runMonthlyDeduction() async {
    safeEmit(const GarageAdminStates.runningDeduction());
    await Future.delayed(const Duration(milliseconds: 500));

    final count = _subscriptions.length;
    final totalDeducted = count * monthlyFee;

    safeEmit(GarageAdminStates.success(
      'Monthly payroll deduction of EGP $monthlyFee successfully processed for $count subscribers (Total: EGP $totalDeducted)',
    ));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Approves a garage parking cancellation request and frees the assigned bay.
  Future<void> approveCancellation(String id) async {
    safeEmit(const GarageAdminStates.approvingCancellation());
    await Future.delayed(const Duration(milliseconds: 300));

    final item = _cancellations.firstWhere((c) => c['id'] == id, orElse: () => {});
    _cancellations.removeWhere((c) => c['id'] == id);
    if (item.isNotEmpty) {
      _subscriptions.removeWhere((s) => s['isl'] == item['isl']);
    }

    safeEmit(GarageAdminStates.success('Cancellation request $id approved and parking bay released'));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Rejects a garage parking cancellation request.
  Future<void> rejectCancellation(String id) async {
    safeEmit(const GarageAdminStates.rejectingCancellation());
    await Future.delayed(const Duration(milliseconds: 300));

    _cancellations.removeWhere((c) => c['id'] == id);

    safeEmit(GarageAdminStates.success('Cancellation request $id rejected'));
    safeEmit(const GarageAdminStates.loaded());
  }
}
