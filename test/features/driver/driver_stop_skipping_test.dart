import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/buses/data/models/bus_boarding_pass_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/driver/presentation/bloc/driver_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriverCubit — Dynamic Stop Skipping & Route Optimization', () {
    late DriverCubit cubit;

    final tenStops = List.generate(10, (index) {
      final stopNumber = index + 1;
      return BusStopModel(
        id: 'S-$stopNumber',
        name: 'Station $stopNumber',
        nameAr: 'محطة $stopNumber',
        scheduledTime: '07:${(index * 8).toString().padLeft(2, '0')} AM',
        order: stopNumber,
        latitude: 30.0500 + (index * 0.005),
        longitude: 31.0500 + (index * 0.005),
        radiusMeters: 150.0,
      );
    });

    final testRoute = BusRouteModel(
      id: 'R-DYNAMIC-10',
      routeNumber: 'Route 99',
      name: 'Test Dynamic Line — HQ',
      shift: 'Morning',
      departureTime: '07:00 AM',
      estimatedArrival: '08:15 AM',
      totalSeats: 28,
      availableSeats: 24,
      driverName: 'Captain Tarek',
      driverPhone: '+20 100 000 0000',
      busPlate: 'ت س ت 1234',
      stops: tenStops,
    );

    setUp(() async {
      final sync = FirestoreSyncService.instance;
      await sync.saveBusRoute(testRoute);

      // Save bookings only for Station 6 and Station 8
      // Stations 1-5 have 0 riders, Station 7 has 0 riders
      await sync.saveBusBooking(
        BusBoardingPassModel(
          id: 'BP-06-1',
          routeId: testRoute.id,
          routeName: testRoute.name,
          routeNumber: testRoute.routeNumber,
          busNumber: 'Bus 99',
          stopName: 'Station 6',
          seatNumber: 1,
          employeeName: 'Mohamed Salah',
          departureTime: '07:40 AM',
          qrPayload: 'TEST-QR-1',
          bookedAt: DateTime.now(),
        ),
      );
      await sync.saveBusBooking(
        BusBoardingPassModel(
          id: 'BP-08-1',
          routeId: testRoute.id,
          routeName: testRoute.name,
          routeNumber: testRoute.routeNumber,
          busNumber: 'Bus 99',
          stopName: 'Station 8',
          seatNumber: 2,
          employeeName: 'Ahmed Zewail',
          departureTime: '07:56 AM',
          qrPayload: 'TEST-QR-2',
          bookedAt: DateTime.now(),
        ),
      );
      await sync.saveBusBooking(
        BusBoardingPassModel(
          id: 'BP-09-1',
          routeId: testRoute.id,
          routeName: testRoute.name,
          routeNumber: testRoute.routeNumber,
          busNumber: 'Bus 99',
          stopName: 'Station 9',
          seatNumber: 3,
          employeeName: 'Naguib Mahfouz',
          departureTime: '08:04 AM',
          qrPayload: 'TEST-QR-3',
          bookedAt: DateTime.now(),
        ),
      );

      cubit = DriverCubit();
      await cubit.loadDriverDashboard();
    });

    tearDown(() {
      cubit.close();
    });

    test('Trip automatically starts at Station 6 and marks Stations 1-5 and Station 7 as skipped', () async {
      final trip = cubit.activeTrip;
      expect(trip, isNotNull);
      expect(trip!.isRouteOptimized, isTrue);
      expect(trip.skippedStopsCount, equals(6)); // Stations 1, 2, 3, 4, 5, 7

      // Current stop starts at index 5 (Station 6)
      expect(trip.currentStopIndex, equals(5));
      expect(trip.currentStop?.name, equals('Station 6'));

      // Next non-skipped stop is Station 8 (skipping Station 7)
      expect(trip.nextStop?.name, equals('Station 8'));
      expect(trip.nextActiveStopIndex, equals(7)); // Station 8 is index 7

      // Stations 1-5 are marked skipped
      for (int i = 0; i < 5; i++) {
        expect(trip.stops[i].isSkipped, isTrue);
      }
      // Station 7 (index 6) is marked skipped
      expect(trip.stops[6].name, equals('Station 7'));
      expect(trip.stops[6].isSkipped, isTrue);
    });

    test('advanceToNextStop seamlessly advances from Station 6 directly to Station 8, skipping Station 7', () async {
      await cubit.startTrip();
      expect(cubit.activeTrip!.isInProgress, isTrue);
      expect(cubit.activeTrip!.currentStop?.name, equals('Station 6'));

      // Advance stop: must jump past Station 7 to Station 8
      await cubit.advanceToNextStop();

      final updatedTrip = cubit.activeTrip!;
      expect(updatedTrip.currentStopIndex, equals(7)); // Jumped to Station 8
      expect(updatedTrip.currentStop?.name, equals('Station 8'));
      expect(
        updatedTrip.stops[6].isCompleted,
        isTrue,
      ); // Station 7 marked passed
      expect(updatedTrip.stops[6].isSkipped, isTrue);

      // Next stop after Station 8 is Station 9
      expect(updatedTrip.nextStop?.name, equals('Station 9'));
    });

    test('GPS geofence handler tracks distance to Station 8 while navigating from Station 6', () async {
      await cubit.startTrip();

      // Current location is near Station 6
      final station6 = cubit.activeTrip!.currentStop!;
      cubit.handleGpsLocationUpdate(station6.latitude!, station6.longitude!);

      expect(cubit.distanceToNextStopMeters, isNotNull);
      expect(cubit.isGpsActive, isTrue);

      // Simulate moving into Station 8 geofence
      final station8 = cubit.activeTrip!.nextStop!;
      cubit.handleGpsLocationUpdate(station8.latitude!, station8.longitude!);

      // Allow async advance to complete
      await Future.delayed(const Duration(milliseconds: 400));

      // Should automatically arrive at Station 8
      expect(cubit.activeTrip!.currentStop?.name, equals('Station 8'));
    });
  });
}
