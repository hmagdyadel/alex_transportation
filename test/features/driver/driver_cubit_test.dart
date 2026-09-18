import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/features/driver/presentation/bloc/driver_cubit.dart';
import 'package:alex_transportation/features/driver/presentation/bloc/driver_states.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DriverCubit cubit;

  setUp(() {
    cubit = DriverCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('DriverCubit — Initialization & Inspection', () {
    test('initializes and loads driver dashboard data', () async {
      final states = <DriverStates>[];
      cubit.stream.listen(states.add);

      await cubit.loadDriverDashboard();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.profile, isNotNull);
      expect(cubit.profile!.name, 'Captain Tarek Mostafa');
      expect(cubit.activeTrip, isNotNull);
      expect(cubit.activeTrip!.routeNumber, '101');
      expect(cubit.totalPassengers, 6);
      expect(cubit.isInspectionComplete, true);
    });

    test('toggleInspectionItem toggles checklist value', () async {
      await cubit.loadDriverDashboard();
      expect(cubit.inspectionChecklist['tires'], true);

      cubit.toggleInspectionItem('tires');
      expect(cubit.inspectionChecklist['tires'], false);
      expect(cubit.isInspectionComplete, false);

      cubit.toggleInspectionItem('tires');
      expect(cubit.inspectionChecklist['tires'], true);
      expect(cubit.isInspectionComplete, true);
    });
  });

  group('DriverCubit — Trip Execution Lifecycle', () {
    test('startTrip sets status to in_progress and activates first stop', () async {
      await cubit.loadDriverDashboard();
      expect(cubit.activeTrip!.isScheduled, true);

      await cubit.startTrip();

      expect(cubit.activeTrip!.isInProgress, true);
      expect(cubit.activeTrip!.currentStopIndex, 0);
      expect(cubit.activeTrip!.currentStop?.name, contains('AlexBank HQ'));
    });

    test('advanceToNextStop moves through stops sequentially', () async {
      await cubit.loadDriverDashboard();
      await cubit.startTrip();

      expect(cubit.activeTrip!.currentStopIndex, 0);

      await cubit.advanceToNextStop();
      expect(cubit.activeTrip!.currentStopIndex, 1);
      expect(cubit.activeTrip!.currentStop?.name, contains('City Center Hub'));

      await cubit.advanceToNextStop();
      expect(cubit.activeTrip!.currentStopIndex, 2);
      expect(cubit.activeTrip!.currentStop?.name, contains('Metro Station'));
    });

    test('boardPassenger toggles passenger boarding state', () async {
      await cubit.loadDriverDashboard();
      final initialBoarded = cubit.boardedCount;

      // Board Ahmed Mansour (MNF-001)
      await cubit.boardPassenger('MNF-001');
      expect(cubit.boardedCount, initialBoarded + 1);

      final ahmed = cubit.activeTrip!.passengers.firstWhere((p) => p.id == 'MNF-001');
      expect(ahmed.isBoarded, true);

      // Toggle back
      await cubit.boardPassenger('MNF-001');
      expect(cubit.boardedCount, initialBoarded);
    });

    test('boardPassenger ignores unknown passenger ID gracefully', () async {
      await cubit.loadDriverDashboard();
      final initialBoarded = cubit.boardedCount;

      await cubit.boardPassenger('UNKNOWN_ID');

      expect(cubit.boardedCount, initialBoarded);
    });

    test('completeTrip marks trip as completed', () async {
      await cubit.loadDriverDashboard();
      await cubit.startTrip();

      await cubit.completeTrip();

      expect(cubit.activeTrip!.isCompleted, true);
      expect(cubit.activeTrip!.completedAt, isNotNull);
    });
  });
}
