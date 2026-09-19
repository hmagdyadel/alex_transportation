import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_data_seeder.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/garage/data/models/garage_subscription_model.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_states.dart';

/// Manages garage parking subscriptions, live capacity, check-in/out, and cancellation
/// backed directly by Cloud Firestore collections.
class GarageCubit extends Cubit<GarageStates> {
  static const int totalCapacity = 300;
  static const int vipSlots = 10;

  /// Dynamic monthly parking fee defined and adjustable by Admin (default: 1,200 EGP).
  static int monthlyFee = 1200;

  int get currentMonthlyFee => monthlyFee;

  /// Allows Admin to set the monthly parking fee to an exact amount.
  void updateMonthlyFee(int newFee) {
    if (newFee <= 0) return;
    monthlyFee = newFee;
    safeEmit(const GarageStates.loaded());
  }

  /// Allows Admin to increase the monthly parking fee by a given step (default 100 EGP).
  void increaseMonthlyFee([int step = 100]) {
    monthlyFee += step;
    safeEmit(const GarageStates.loaded());
  }

  /// Allows Admin to decrease the monthly parking fee by a given step (default 100 EGP).
  void decreaseMonthlyFee([int step = 100]) {
    if (monthlyFee - step >= 100) {
      monthlyFee -= step;
      safeEmit(const GarageStates.loaded());
    }
  }

  int _availableSlots = 42;
  int _waitingCount = 0;
  GarageSubscriptionModel? _currentSubscription;
  final List<GarageSubscriptionModel> _subscriptions = [];

  GarageCubit() : super(const GarageStates.initial()) {
    _initFromCache();
  }

  void _initFromCache() {
    final sync = FirestoreSyncService.instance;
    final subs = sync.getCachedGarageSubscriptions();
    _subscriptions.clear();
    _subscriptions.addAll(subs);
    _availableSlots = 42;
    _waitingCount = subs.where((s) => s.status == 'waiting').length;
    if (subs.isNotEmpty) {
      _currentSubscription = subs.first;
    }
  }

  int get availableSlots => _availableSlots;
  int get waitingCount => _waitingCount;
  GarageSubscriptionModel? get currentSubscription => _currentSubscription;
  List<GarageSubscriptionModel> get subscriptions =>
      List.unmodifiable(_subscriptions);

  /// Loads garage status and active subscriptions directly from Cloud Firestore.
  Future<void> loadGarageData({String? userIsl}) async {
    safeEmit(const GarageStates.loading());

    final sync = FirestoreSyncService.instance;
    var subs = await sync.getGarageSubscriptions();

    if (subs.isEmpty) {
      await FirestoreDataSeeder.seedInitialDataIfNeeded();
      subs = await sync.getGarageSubscriptions();
    }

    _subscriptions.clear();
    _subscriptions.addAll(subs);

    _availableSlots = 42;
    _waitingCount = subs.where((s) => s.status == 'waiting').length;

    if (userIsl != null) {
      final matches = subs.where((s) => s.isl == userIsl).toList();
      _currentSubscription = matches.isNotEmpty ? matches.first : null;
    } else if (subs.isNotEmpty) {
      _currentSubscription = subs.first;
    }

    safeEmit(const GarageStates.loaded());
  }

  /// Searches active and waiting subscriptions by ISL and optional email.
  GarageSubscriptionModel? findSubscription(String isl, [String? email]) {
    final cleanIsl = isl.trim().toLowerCase();
    final cleanEmail = email?.trim().toLowerCase();
    try {
      return _subscriptions.firstWhere(
        (s) =>
            s.isl.toLowerCase() == cleanIsl &&
            (cleanEmail == null ||
                cleanEmail.isEmpty ||
                s.email.toLowerCase() == cleanEmail),
      );
    } catch (_) {
      return null;
    }
  }

  /// Submits a new parking subscription request directly to Cloud Firestore.
  Future<void> submitSubscription({
    required String name,
    required String nationalId,
    required String isl,
    required String dept,
    required String email,
    required String priorityTier,
    required bool consent,
    String? licenseUrl,
  }) async {
    // Validation
    final cleanNationalId = nationalId.trim();
    if (cleanNationalId.length != 14 || int.tryParse(cleanNationalId) == null) {
      safeEmit(
        const GarageStates.error(
          message: 'Please enter a valid 14-digit National ID',
        ),
      );
      return;
    }

    final cleanIsl = isl.trim();
    if (cleanIsl.length < 4 ||
        cleanIsl.length > 8 ||
        int.tryParse(cleanIsl) == null) {
      safeEmit(
        const GarageStates.error(
          message: 'Please enter a valid Bank ISL (4–8 digits)',
        ),
      );
      return;
    }

    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.endsWith('@alexbank.com')) {
      safeEmit(
        const GarageStates.error(
          message: 'Work email must be an @alexbank.com address',
        ),
      );
      return;
    }

    if (!consent) {
      safeEmit(
        GarageStates.error(
          message:
              'You must agree to the EGP $monthlyFee payroll deduction to proceed',
        ),
      );
      return;
    }

    safeEmit(const GarageStates.submittingSubscription());

    final newId = 'S00${_subscriptions.length + 1}';
    final slotNumber = (_subscriptions.length + 14).toString().padLeft(3, '0');
    final assignedSlot = _availableSlots > 0 ? 'P1-$slotNumber' : null;
    final status = _availableSlots > 0 ? 'active' : 'waiting';

    final newSub = GarageSubscriptionModel(
      id: newId,
      name: name.trim(),
      nationalId: cleanNationalId,
      isl: cleanIsl,
      dept: dept,
      email: cleanEmail,
      priorityTier: priorityTier,
      slotLabel: assignedSlot,
      status: status,
      waitingPosition: status == 'waiting' ? _waitingCount + 1 : null,
      checkedIn: false,
      submittedAt: DateTime.now(),
      licenseUrl: licenseUrl,
    );

    // Save directly to Firestore collection
    final sync = FirestoreSyncService.instance;
    await sync.saveGarageSubscription(newSub);

    _subscriptions.add(newSub);
    _currentSubscription = newSub;

    if (status == 'active' && _availableSlots > 0) {
      _availableSlots--;
    } else {
      _waitingCount++;
    }

    await sync.syncGarageEvent(
      isl: cleanIsl,
      eventType: 'subscribe',
      slotLabel: assignedSlot,
    );

    safeEmit(GarageStates.success(newSub));
    safeEmit(const GarageStates.loaded());
  }

  /// Toggles parking check-in / check-out and persists status to Firestore.
  Future<void> checkInOut() async {
    if (_currentSubscription == null) {
      safeEmit(
        const GarageStates.error(message: 'No active subscription found'),
      );
      return;
    }

    if (_currentSubscription!.status != 'active') {
      safeEmit(
        const GarageStates.error(message: 'Subscription is not active yet'),
      );
      return;
    }

    safeEmit(const GarageStates.checkingInOut());

    final isCurrentlyCheckedIn = _currentSubscription!.checkedIn;
    final updated = _currentSubscription!.copyWith(
      checkedIn: !isCurrentlyCheckedIn,
      checkedInAt: !isCurrentlyCheckedIn ? DateTime.now() : null,
    );

    _currentSubscription = updated;

    final index = _subscriptions.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _subscriptions[index] = updated;
    }

    if (!isCurrentlyCheckedIn) {
      _availableSlots = (_availableSlots - 1).clamp(0, totalCapacity);
    } else {
      _availableSlots = (_availableSlots + 1).clamp(0, totalCapacity);
    }

    // Persist to Cloud Firestore
    final sync = FirestoreSyncService.instance;
    await sync.saveGarageSubscription(updated);

    await sync.syncGarageEvent(
      isl: updated.isl,
      eventType: !isCurrentlyCheckedIn ? 'check_in' : 'check_out',
      slotLabel: updated.slotLabel,
    );

    final msg = !isCurrentlyCheckedIn
        ? 'Checked in! Bay ${updated.slotLabel ?? "assigned"} is reserved.'
        : 'Checked out! Have a safe trip.';

    safeEmit(GarageStates.success(msg));
    safeEmit(const GarageStates.loaded());
  }

  /// Submits a subscription cancellation request to Cloud Firestore.
  Future<void> requestCancellation({
    required String isl,
    required String email,
  }) async {
    if (_currentSubscription == null) {
      safeEmit(const GarageStates.error(message: 'No subscription to cancel'));
      return;
    }

    final cleanIsl = isl.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (_currentSubscription!.isl != cleanIsl ||
        _currentSubscription!.email.toLowerCase() != cleanEmail) {
      safeEmit(
        const GarageStates.error(
          message: 'ISL and email must match your active subscription',
        ),
      );
      return;
    }

    safeEmit(const GarageStates.cancelling());

    final updated = _currentSubscription!.copyWith(
      status: 'cancellation_pending',
    );

    _currentSubscription = updated;
    final index = _subscriptions.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _subscriptions[index] = updated;
    }

    // Persist to Cloud Firestore
    final sync = FirestoreSyncService.instance;
    await sync.saveGarageSubscription(updated);

    await sync.syncGarageEvent(
      isl: cleanIsl,
      eventType: 'cancel',
      slotLabel: updated.slotLabel,
    );

    safeEmit(
      const GarageStates.success(
        'Cancellation request submitted for payroll cut-off',
      ),
    );
    safeEmit(const GarageStates.loaded());
  }
}
