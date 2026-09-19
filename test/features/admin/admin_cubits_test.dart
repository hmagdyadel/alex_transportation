import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/features/admin/presentation/bloc/access_admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/bus_admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/driver_admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/errand_admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/garage_admin_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccessAdminCubit Tests', () {
    late AccessAdminCubit cubit;

    setUp(() {
      cubit = AccessAdminCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('loadCodes loads initial invite codes', () async {
      await cubit.loadCodes();
      expect(cubit.codes.length, greaterThanOrEqualTo(3));
      expect(cubit.codes.any((c) => c.role == 'admin'), isTrue);
    });

    test('generateCode adds a new code with correct role prefix', () async {
      await cubit.loadCodes();
      final initialCount = cubit.codes.length;
      await cubit.generateCode(role: 'admin', department: 'Risk');

      expect(cubit.codes.length, initialCount + 1);
      expect(cubit.codes.first.code, startsWith('ADM-'));
      expect(cubit.codes.first.department, 'Risk');
    });

    test('toggleCodeStatus toggles active state of code', () async {
      await cubit.loadCodes();
      final codeId = cubit.codes.first.id;
      final initialStatus = cubit.codes.first.isActive;

      cubit.toggleCodeStatus(codeId);
      final updated = cubit.codes.firstWhere((c) => c.id == codeId);
      expect(updated.isActive, !initialStatus);
    });

    test('revokeCode removes code from list', () async {
      await cubit.loadCodes();
      final initialCount = cubit.codes.length;
      final codeId = cubit.codes.first.id;

      cubit.revokeCode(codeId);
      expect(cubit.codes.length, initialCount - 1);
      expect(cubit.codes.any((c) => c.id == codeId), isFalse);
    });
  });

  group('BusAdminCubit Tests', () {
    late BusAdminCubit cubit;

    setUp(() {
      cubit = BusAdminCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('loadData loads routes and subscribers', () async {
      await cubit.loadData();
      expect(cubit.routes.isNotEmpty, isTrue);
      expect(cubit.subscribers.isNotEmpty, isTrue);
    });

    test('startTrip updates route status to en_route', () async {
      await cubit.loadData();
      await cubit.startTrip('R101');

      final route = cubit.routes.firstWhere((r) => r.id == 'R101');
      expect(route.status, 'en_route');
    });

    test('removeSubscriber removes subscriber by ID', () async {
      await cubit.loadData();
      final initialCount = cubit.subscribers.length;
      await cubit.removeSubscriber('SUB-101');

      expect(cubit.subscribers.length, initialCount - 1);
      expect(cubit.subscribers.any((s) => s['id'] == 'SUB-101'), isFalse);
    });
  });

  group('GarageAdminCubit Tests', () {
    late GarageAdminCubit cubit;

    setUp(() {
      cubit = GarageAdminCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('loadData loads waitlist, cancellations, and subscriptions', () async {
      await cubit.loadData();
      expect(cubit.waitingList.isNotEmpty, isTrue);
      expect(cubit.cancellations.isNotEmpty, isTrue);
      expect(cubit.subscriptions.isNotEmpty, isTrue);
    });

    test('monthlyFee management sets, increases, and decreases tariff', () {
      cubit.setMonthlyFee(1500);
      expect(cubit.monthlyFee, 1500);

      cubit.increaseMonthlyFee(200);
      expect(cubit.monthlyFee, 1700);

      cubit.decreaseMonthlyFee(300);
      expect(cubit.monthlyFee, 1400);
    });

    test(
      'approveWaiting converts applicant into active subscription',
      () async {
        await cubit.loadData();
        final initialWaitCount = cubit.waitingList.length;
        final initialSubCount = cubit.subscriptions.length;

        await cubit.approveWaiting('WAIT-001');

        expect(cubit.waitingList.length, initialWaitCount - 1);
        expect(cubit.subscriptions.length, initialSubCount + 1);
      },
    );

    test('rejectWaiting removes applicant from waitlist', () async {
      await cubit.loadData();
      final initialWaitCount = cubit.waitingList.length;

      await cubit.rejectWaiting('WAIT-002');
      expect(cubit.waitingList.length, initialWaitCount - 1);
    });

    test('runMonthlyDeduction processes successfully', () async {
      await cubit.loadData();
      await cubit.runMonthlyDeduction();
      expect(cubit.subscriptions.isNotEmpty, isTrue);
    });

    test('approveCancellation removes cancellation and subscription', () async {
      await cubit.loadData();
      final initialCanCount = cubit.cancellations.length;

      await cubit.approveCancellation('CAN-001');
      expect(cubit.cancellations.length, initialCanCount - 1);
    });

    test('rejectCancellation removes cancellation request', () async {
      await cubit.loadData();
      final initialCanCount = cubit.cancellations.length;

      await cubit.rejectCancellation('CAN-001');
      expect(cubit.cancellations.length, initialCanCount - 1);
    });
  });

  group('ErrandAdminCubit Tests', () {
    late ErrandAdminCubit cubit;

    setUp(() {
      cubit = ErrandAdminCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('loadData loads errand requests', () async {
      await cubit.loadData();
      expect(cubit.requests.isNotEmpty, isTrue);
    });

    test(
      'approveRequest marks status as approved and assigns driver/car',
      () async {
        await cubit.loadData();
        await cubit.approveRequest('REQ-101');

        final req = cubit.requests.firstWhere((r) => r.id == 'REQ-101');
        expect(req.status, 'approved');
        expect(req.assignedDriverName, isNotNull);
        expect(req.assignedCarPlate, isNotNull);
      },
    );

    test('rejectRequest marks status as rejected', () async {
      await cubit.loadData();
      await cubit.rejectRequest('REQ-102');

      final req = cubit.requests.firstWhere((r) => r.id == 'REQ-102');
      expect(req.status, 'rejected');
    });
  });

  group('DriverAdminCubit Tests', () {
    late DriverAdminCubit cubit;

    setUp(() {
      cubit = DriverAdminCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('loadData loads drivers roster', () async {
      await cubit.loadData();
      expect(cubit.drivers.isNotEmpty, isTrue);
    });

    test('assignDriver updates driver assigned resource', () async {
      await cubit.loadData();
      await cubit.assignDriver('DRV-881', 'R104');

      final driver = cubit.drivers.firstWhere((d) => d.id == 'DRV-881');
      expect(driver.assignedRouteId, 'R104');
    });
  });
}
