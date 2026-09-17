import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/garage/data/models/garage_subscription_model.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_states.dart';

/// Manages garage parking subscriptions, live capacity, QR check-in/out, and cancellation.
class GarageCubit extends Cubit<GarageStates> {
  static const int totalCapacity = 300;
  static const int vipSlots = 10;
  static const int monthlyFee = 1200; // EGP

  int _availableSlots = 42;
  int _waitingCount = 4;
  GarageSubscriptionModel? _currentSubscription;

  // In-memory registered subscriptions for demonstration & offline resilience
  final List<GarageSubscriptionModel> _subscriptions = [
    GarageSubscriptionModel(
      id: 'S001',
      name: 'Sara Hassan',
      nationalId: '29001011234567',
      isl: '10234',
      dept: 'IT',
      email: 's.hassan@alexbank.com',
      priorityTier: 'standard',
      slotLabel: 'P1-014',
      status: 'active',
      checkedIn: false,
      submittedAt: DateTime(2026, 3, 1, 9, 0),
    ),
    GarageSubscriptionModel(
      id: 'S002',
      name: 'Mohamed Ali',
      nationalId: '28808051234567',
      isl: '10512',
      dept: 'Finance',
      email: 'm.ali@alexbank.com',
      priorityTier: 'senior',
      slotLabel: 'P1-002',
      status: 'active',
      checkedIn: true,
      checkedInAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      submittedAt: DateTime(2026, 3, 2, 8, 30),
    ),
  ];

  GarageCubit() : super(const GarageStates.initial()) {
    // Default active subscription for instant demonstration
    _currentSubscription = _subscriptions.first;
  }

  int get availableSlots => _availableSlots;
  int get waitingCount => _waitingCount;
  GarageSubscriptionModel? get currentSubscription => _currentSubscription;

  /// Loads garage status and active subscriptions.
  Future<void> loadGarageData() async {
    safeEmit(const GarageStates.loading());
    await Future.delayed(const Duration(milliseconds: 500));
    safeEmit(const GarageStates.loaded());
  }

  /// Submits a new parking subscription request.
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
      safeEmit(const GarageStates.error(message: 'Please enter a valid 14-digit National ID'));
      return;
    }

    final cleanIsl = isl.trim();
    if (cleanIsl.length < 4 || cleanIsl.length > 8 || int.tryParse(cleanIsl) == null) {
      safeEmit(const GarageStates.error(message: 'Please enter a valid Bank ISL (4–8 digits)'));
      return;
    }

    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.endsWith('@alexbank.com')) {
      safeEmit(const GarageStates.error(message: 'Work email must be an @alexbank.com address'));
      return;
    }

    if (!consent) {
      safeEmit(const GarageStates.error(message: 'You must agree to the EGP 1,200 payroll deduction to proceed'));
      return;
    }

    safeEmit(const GarageStates.submittingSubscription());
    await Future.delayed(const Duration(milliseconds: 900));

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

    _subscriptions.add(newSub);
    _currentSubscription = newSub;

    if (status == 'active' && _availableSlots > 0) {
      _availableSlots--;
    } else {
      _waitingCount++;
    }

    safeEmit(GarageStates.success(newSub));
    safeEmit(const GarageStates.loaded());
  }

  /// Toggles check-in and check-out status for the active parking pass.
  Future<void> checkInOut() async {
    if (_currentSubscription == null) {
      safeEmit(const GarageStates.error(message: 'No active parking subscription found'));
      return;
    }

    safeEmit(const GarageStates.checkingInOut());
    await Future.delayed(const Duration(milliseconds: 700));

    final isCheckingIn = !_currentSubscription!.checkedIn;
    final updated = _currentSubscription!.copyWith(
      checkedIn: isCheckingIn,
      checkedInAt: isCheckingIn ? DateTime.now() : null,
    );

    _currentSubscription = updated;
    if (isCheckingIn) {
      if (_availableSlots > 0) _availableSlots--;
    } else {
      if (_availableSlots < totalCapacity) _availableSlots++;
    }

    final message = isCheckingIn
        ? 'Welcome! Checked in to bay ${updated.slotLabel ?? "General"}'
        : 'Checked out successfully. Have a safe drive!';

    safeEmit(GarageStates.success(message));
    safeEmit(const GarageStates.loaded());
  }

  /// Submits a cancellation request.
  Future<void> requestCancellation({
    required String isl,
    required String email,
  }) async {
    final cleanIsl = isl.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanIsl.isEmpty || !cleanEmail.endsWith('@alexbank.com')) {
      safeEmit(const GarageStates.error(message: 'Enter valid ISL and @alexbank.com email'));
      return;
    }

    safeEmit(const GarageStates.cancelling());
    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentSubscription != null &&
        _currentSubscription!.isl == cleanIsl &&
        _currentSubscription!.email.toLowerCase() == cleanEmail) {
      _currentSubscription = _currentSubscription!.copyWith(
        status: 'cancellation_pending',
      );
    }

    safeEmit(const GarageStates.success('Cancellation request submitted for admin review'));
    safeEmit(const GarageStates.loaded());
  }

  /// Searches for subscription status by ISL and email.
  GarageSubscriptionModel? findSubscription(String isl, String email) {
    final iT = isl.trim();
    final eT = email.trim().toLowerCase();
    try {
      return _subscriptions.firstWhere(
        (s) => s.isl == iT && s.email.toLowerCase() == eT,
      );
    } catch (_) {
      return null;
    }
  }
}
