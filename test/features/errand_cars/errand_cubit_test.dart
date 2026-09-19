import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_cubit.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_states.dart';

void main() {
  late ErrandCarCubit cubit;

  setUp(() {
    cubit = ErrandCarCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('ErrandCarCubit — Initialization', () {
    test('starts with initial state', () {
      expect(cubit.state, const ErrandCarStates.initial());
    });

    test('fleet has 5 vehicles', () {
      expect(cubit.fleet.length, 5);
    });

    test('has demo active dispatch pass', () {
      expect(cubit.activePass, isNotNull);
      expect(cubit.activePass!.id, 'ABX-3942');
      expect(cubit.activePass!.missionCode, 'CPT-912');
    });

    test('has demo request history', () {
      expect(cubit.myRequests.length, 3);
      expect(cubit.myRequests.first.status, 'approved');
    });

    test('available cars count is correct', () {
      // 2 available + 1 in_use (demo) + 1 maintenance + 1 available = 3 available
      expect(cubit.availableCars, 3);
    });
  });

  group('ErrandCarCubit — loadFleet', () {
    test('emits loading then loaded', () async {
      final states = <ErrandCarStates>[];
      cubit.stream.listen(states.add);

      await cubit.loadFleet();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.contains(const ErrandCarStates.loading()), true);
      expect(states.contains(const ErrandCarStates.loaded()), true);
    });
  });

  group('ErrandCarCubit — submitRequest', () {
    test('rejects empty employee name', () async {
      final states = <ErrandCarStates>[];
      cubit.stream.listen(states.add);

      final result = await cubit.submitRequest(
        employeeName: '',
        employeeIsl: '10234',
        department: 'IT',
        pickupLocation: 'Smart Village Operations Hub',
        destination: 'Branch X',
        purpose: 'Delivery',
        requestedDate: '20 Sep 2026',
        requestedTime: '10:00 AM',
        estimatedReturnTime: '02:00 PM',
        supervisorName: 'Manager',
      );

      expect(result, false);
      expect(states.any((s) => s is Error), true);
    });

    test('rejects short ISL', () async {
      final result = await cubit.submitRequest(
        employeeName: 'Test User',
        employeeIsl: '12',
        department: 'IT',
        pickupLocation: 'Smart Village Operations Hub',
        destination: 'Branch X',
        purpose: 'Delivery',
        requestedDate: '20 Sep 2026',
        requestedTime: '10:00 AM',
        estimatedReturnTime: '02:00 PM',
        supervisorName: 'Manager',
      );

      expect(result, false);
    });

    test('rejects empty pickup location', () async {
      final result = await cubit.submitRequest(
        employeeName: 'Test User',
        employeeIsl: '10234',
        department: 'IT',
        pickupLocation: '',
        destination: 'Branch X',
        purpose: 'Delivery',
        requestedDate: '20 Sep 2026',
        requestedTime: '10:00 AM',
        estimatedReturnTime: '02:00 PM',
        supervisorName: 'Manager',
      );

      expect(result, false);
    });

    test('rejects empty destination', () async {
      final result = await cubit.submitRequest(
        employeeName: 'Test User',
        employeeIsl: '10234',
        department: 'IT',
        pickupLocation: 'Smart Village Operations Hub',
        destination: '',
        purpose: 'Delivery',
        requestedDate: '20 Sep 2026',
        requestedTime: '10:00 AM',
        estimatedReturnTime: '02:00 PM',
        supervisorName: 'Manager',
      );

      expect(result, false);
    });

    test('submits valid request and assigns car', () async {
      final initialRequests = cubit.myRequests.length;
      final initialAvailable = cubit.availableCars;

      final result = await cubit.submitRequest(
        employeeName: 'Sara Hassan',
        employeeIsl: '20456',
        department: 'Finance',
        pickupLocation: 'AlexBank Downtown Cairo HQ',
        destination: 'Central Bank',
        purpose: 'Regulatory submission',
        requestedDate: '20 Sep 2026',
        requestedTime: '09:00 AM',
        estimatedReturnTime: '01:00 PM',
        supervisorName: 'Dr. Amr',
      );

      expect(result, true);
      expect(cubit.myRequests.length, initialRequests + 1);
      expect(cubit.myRequests.first.status, 'approved');
      expect(
        cubit.myRequests.first.pickupLocation,
        'AlexBank Downtown Cairo HQ',
      );
      expect(cubit.myRequests.first.assignedCarId, isNotNull);
      expect(cubit.availableCars, initialAvailable - 1);
    });
  });

  group('ErrandCarCubit — cancelRequest', () {
    test('cancels pending request', () async {
      // First submit a request to get a pending one
      await cubit.submitRequest(
        employeeName: 'Cancel Test',
        employeeIsl: '30567',
        department: 'HR',
        pickupLocation: 'Smart Village Operations Hub',
        destination: 'Test Branch',
        purpose: 'Testing',
        requestedDate: '20 Sep 2026',
        requestedTime: '11:00 AM',
        estimatedReturnTime: '03:00 PM',
        supervisorName: 'Supervisor',
      );

      final newRequest = cubit.myRequests.first;
      final availableBefore = cubit.availableCars;

      final result = await cubit.cancelRequest(newRequest.id);

      expect(result, true);
      final cancelled = cubit.myRequests.firstWhere(
        (r) => r.id == newRequest.id,
      );
      expect(cancelled.status, 'cancelled');

      // Car should be freed
      if (newRequest.assignedCarId != null) {
        expect(cubit.availableCars, availableBefore + 1);
      }
    });

    test('rejects cancelling non-existent request', () async {
      final result = await cubit.cancelRequest('FAKE-ID');
      expect(result, false);
    });
  });

  group('ErrandCarCubit — startMission', () {
    test('starts mission for active pass', () async {
      final states = <ErrandCarStates>[];
      cubit.stream.listen(states.add);

      await cubit.startMission(cubit.activePass!.id);

      expect(states.any((s) => s is StartingMission), true);
      // Request should move to in_progress
      final request = cubit.myRequests.firstWhere(
        (r) => r.id == cubit.activePass?.requestId,
        orElse: () => cubit.myRequests.first,
      );
      expect(request.status, 'in_progress');
    });

    test('rejects start for non-existent pass', () async {
      final states = <ErrandCarStates>[];
      cubit.stream.listen(states.add);

      await cubit.startMission('FAKE-PASS');

      expect(states.any((s) => s is Error), true);
    });
  });

  group('ErrandCarCubit — endMission', () {
    test('rejects end mileage less than start', () async {
      final states = <ErrandCarStates>[];
      cubit.stream.listen(states.add);

      await cubit.endMission(cubit.activePass!.id, 100); // Less than 34520

      expect(states.any((s) => s is Error), true);
    });

    test('ends mission with valid mileage', () async {
      final passId = cubit.activePass!.id;
      final carId = cubit.myRequests
          .firstWhere((r) => r.id == cubit.activePass!.requestId)
          .assignedCarId;

      await cubit.endMission(passId, 34580);

      // Active pass should be cleared
      expect(cubit.activePass, isNull);

      // Car should be freed and mileage updated
      if (carId != null) {
        final car = cubit.fleet.firstWhere((c) => c.id == carId);
        expect(car.status, 'available');
        expect(car.currentMileage, 34580);
      }
    });
  });
}
