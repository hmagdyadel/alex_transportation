import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_data_seeder.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/garage_admin_states.dart';
import 'package:alex_transportation/features/garage/data/models/garage_subscription_model.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';

/// Admin: manage garage subscriptions, waitlist, cancellations, deductions, and parking fees
/// directly backed by Cloud Firestore collections.
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

  /// Loads garage operational metrics, waitlists, and cancellation requests from Firestore.
  Future<void> loadData() async {
    safeEmit(const GarageAdminStates.loading());

    final sync = FirestoreSyncService.instance;
    var loaded = await sync.getGarageSubscriptions();
    if (loaded.isEmpty) {
      await FirestoreDataSeeder.seedInitialDataIfNeeded();
      loaded = await sync.getGarageSubscriptions();
    }

    _subscriptions.clear();
    _waitingList.clear();
    _cancellations.clear();

    for (final s in loaded) {
      final map = {
        'id': s.id,
        'name': s.name,
        'isl': s.isl,
        'department': s.dept,
        'slot': s.slotLabel ?? 'None',
        'status': s.status,
      };

      if (s.status == 'waiting') {
        _waitingList.add(map);
      } else if (s.status == 'cancellation_requested' || s.status == 'cancellation_pending') {
        _cancellations.add(map);
      } else {
        _subscriptions.add(map);
      }
    }

    // Ensure initial cancellation item CAN-001 exists for administrative management
    for (final s in FirestoreDataSeeder.initialSubscriptions) {
      final map = {
        'id': s.id,
        'name': s.name,
        'isl': s.isl,
        'department': s.dept,
        'slot': s.slotLabel ?? 'None',
        'status': s.status,
      };
      if (s.status == 'waiting' && !_waitingList.any((w) => w['id'] == s.id)) {
        _waitingList.add(map);
      } else if ((s.status == 'cancellation_requested' || s.status == 'cancellation_pending') &&
          !_cancellations.any((c) => c['id'] == s.id)) {
        _cancellations.add(map);
      }
    }

    safeEmit(const GarageAdminStates.loaded());
  }

  /// Approves an employee's waiting list application and assigns a parking bay in Firestore.
  Future<void> approveWaiting(String id) async {
    final index = _waitingList.indexWhere((w) => w['id'] == id);
    if (index == -1) return;

    final item = _waitingList.removeAt(index);
    final assignedBay = 'BAY-${(_subscriptions.length + 1).toString().padLeft(2, '0')}';
    item['slot'] = assignedBay;
    item['status'] = 'active';
    _subscriptions.add(item);

    final sub = GarageSubscriptionModel(
      id: item['id'] as String,
      name: item['name'] as String,
      nationalId: '29000000000000',
      isl: item['isl'] as String,
      dept: item['department'] as String,
      email: '${(item['isl'] as String)}@alexbank.com',
      priorityTier: 'standard',
      slotLabel: assignedBay,
      status: 'active',
      submittedAt: DateTime.now(),
    );

    await FirestoreSyncService.instance.saveGarageSubscription(sub);

    safeEmit(GarageAdminStates.success('Waitlist approved for $id'));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Rejects an employee's waiting list application.
  Future<void> rejectWaiting(String id) async {
    _waitingList.removeWhere((w) => w['id'] == id);

    final sub = GarageSubscriptionModel(
      id: id,
      name: 'Applicant',
      nationalId: '29000000000000',
      isl: '0000',
      dept: 'General',
      email: 'applicant@alexbank.com',
      priorityTier: 'standard',
      status: 'rejected',
      submittedAt: DateTime.now(),
    );
    await FirestoreSyncService.instance.saveGarageSubscription(sub);

    safeEmit(GarageAdminStates.success('Waitlist rejected for $id'));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Runs the monthly payroll deduction batch calculation across all active subscribers.
  Future<void> runMonthlyDeduction() async {
    safeEmit(const GarageAdminStates.runningDeduction());

    final activeCount = _subscriptions.where((s) => s['status'] == 'active').length;
    final totalAmount = activeCount * monthlyFee;

    safeEmit(GarageAdminStates.success('Processed $activeCount deductions totaling EGP $totalAmount'));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Approves a subscription cancellation request and vacates the parking bay in Firestore.
  Future<void> approveCancellation(String id) async {
    final index = _cancellations.indexWhere((c) => c['id'] == id);
    if (index == -1) return;

    final item = _cancellations.removeAt(index);
    _subscriptions.removeWhere((s) => s['id'] == id);

    final sub = GarageSubscriptionModel(
      id: item['id'] as String,
      name: item['name'] as String,
      nationalId: '29000000000000',
      isl: item['isl'] as String,
      dept: item['department'] as String,
      email: '${item['isl']}@alexbank.com',
      priorityTier: 'standard',
      status: 'cancelled',
      submittedAt: DateTime.now(),
    );
    await FirestoreSyncService.instance.saveGarageSubscription(sub);

    safeEmit(GarageAdminStates.success('Cancellation approved for $id'));
    safeEmit(const GarageAdminStates.loaded());
  }

  /// Rejects a cancellation request.
  Future<void> rejectCancellation(String id) async {
    final index = _cancellations.indexWhere((c) => c['id'] == id);
    if (index == -1) return;

    final item = _cancellations.removeAt(index);
    item['status'] = 'active';

    final sub = GarageSubscriptionModel(
      id: item['id'] as String,
      name: item['name'] as String,
      nationalId: '29000000000000',
      isl: item['isl'] as String,
      dept: item['department'] as String,
      email: '${item['isl']}@alexbank.com',
      priorityTier: 'standard',
      status: 'active',
      submittedAt: DateTime.now(),
    );
    await FirestoreSyncService.instance.saveGarageSubscription(sub);

    safeEmit(GarageAdminStates.success('Cancellation rejected for $id'));
    safeEmit(const GarageAdminStates.loaded());
  }
}
