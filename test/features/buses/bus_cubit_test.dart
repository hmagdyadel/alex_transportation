import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_cubit.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_states.dart';

void main() {
  group('BusCubit', () {
    late BusCubit cubit;

    setUp(() {
      cubit = BusCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state and default mock routes', () {
      expect(cubit.state, const BusStates.initial());
      expect(cubit.routes.length, 8);
      expect(cubit.activePass, isNotNull);
      expect(cubit.activePass!.routeNumber, 'Route 101');
      expect(cubit.activePass!.seatNumber, 14);

      // Verify bidirectional terminus
      final morningR101 = cubit.routes.firstWhere((r) => r.id == 'R101');
      expect(morningR101.stops.last.name, 'Smart Village (AlexBank HQ)');

      final eveningR201 = cubit.routes.firstWhere((r) => r.id == 'R201');
      expect(eveningR201.stops.first.name, 'Smart Village (AlexBank HQ)');
      expect(eveningR201.stops.last.name, 'Victoria Square');
    });

    test('filterShift correctly filters morning and evening routes', () {
      cubit.filterShift('Morning');
      expect(cubit.filteredRoutes.length, 4);
      expect(cubit.filteredRoutes.every((r) => r.shift == 'Morning'), isTrue);

      cubit.filterShift('Evening');
      expect(cubit.filteredRoutes.length, 4);
      expect(cubit.filteredRoutes.every((r) => r.shift == 'Evening'), isTrue);

      cubit.filterShift('All');
      expect(cubit.filteredRoutes.length, 8);
    });

    test('checkInForToday marks pass as boarded', () async {
      expect(cubit.activePass!.status, 'active');

      await cubit.checkInForToday();

      expect(cubit.activePass!.status, 'boarded');
    });

    test('cancelBooking clears active pass and restores seat to route', () async {
      final passId = cubit.activePass!.id;
      final route101 = cubit.routes.firstWhere((r) => r.id == 'R101');
      final initialSeats = route101.availableSeats;

      final success = await cubit.cancelBooking(passId);

      expect(success, isTrue);
      expect(cubit.activePass, isNull);
      final updatedRoute = cubit.routes.firstWhere((r) => r.id == 'R101');
      expect(updatedRoute.availableSeats, initialSeats + 1);
    });

    test('bookSeat reserves seat on available route', () async {
      // First cancel the existing pass so we can book a fresh one
      await cubit.cancelBooking(cubit.activePass!.id);

      final route102 = cubit.routes.firstWhere((r) => r.id == 'R102');
      final initialSeats = route102.availableSeats;

      final success = await cubit.bookSeat(
        routeId: 'R102',
        stopId: 'S102-1',
        employeeName: 'Ahmed Hassan',
      );

      expect(success, isTrue);
      expect(cubit.activePass, isNotNull);
      expect(cubit.activePass!.routeId, 'R102');
      expect(cubit.activePass!.stopName, '90th Street North');

      final updatedRoute = cubit.routes.firstWhere((r) => r.id == 'R102');
      expect(updatedRoute.availableSeats, initialSeats - 1);
    });

    test('bookSeat rejects booking when route is full', () async {
      await cubit.cancelBooking(cubit.activePass!.id);

      // Route 103 has 0 available seats
      final success = await cubit.bookSeat(
        routeId: 'R103',
        stopId: 'S103-1',
        employeeName: 'Ahmed Hassan',
      );

      expect(success, isFalse);
    });

    test('addStationToRoute adds station and updates route manifest', () {
      final initialStopCount = cubit.routes.firstWhere((r) => r.id == 'R101').stops.length;
      cubit.addStationToRoute(
        'R101',
        const BusStopModel(
          id: 'S101-NEW',
          name: 'South Ring Road Overpass',
          scheduledTime: '08:15 AM',
          order: 5,
        ),
      );

      final updated = cubit.routes.firstWhere((r) => r.id == 'R101');
      expect(updated.stops.length, initialStopCount + 1);
      expect(updated.stops.any((s) => s.id == 'S101-NEW'), isTrue);
    });

    test('removeStationFromRoute removes station from route', () {
      cubit.removeStationFromRoute('R101', 'S101-3');
      final updated = cubit.routes.firstWhere((r) => r.id == 'R101');
      expect(updated.stops.any((s) => s.id == 'S101-3'), isFalse);
    });

    test('updateStationTime updates scheduled time of station', () {
      cubit.updateStationTime('R101', 'S101-1', '07:10 AM');
      final updated = cubit.routes.firstWhere((r) => r.id == 'R101');
      expect(updated.stops.firstWhere((s) => s.id == 'S101-1').scheduledTime, '07:10 AM');
    });

    test('generateReverseEveningRoute mirrors morning line in reverse from Smart Village HQ', () {
      final mirrored = cubit.generateReverseEveningRoute('R102');
      expect(mirrored.shift, 'Evening');
      expect(mirrored.stops.first.name, 'Smart Village (AlexBank HQ)');
      expect(mirrored.stops.last.name, '90th Street North');
    });
  });
}
