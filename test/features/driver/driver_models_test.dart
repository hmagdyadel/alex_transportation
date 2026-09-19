import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/driver/data/models/driver_profile_model.dart';
import 'package:alex_transportation/features/driver/data/models/driver_trip_model.dart';
import 'package:alex_transportation/features/driver/data/models/trip_manifest_item_model.dart';

void main() {
  group('DriverProfileModel', () {
    const profile = DriverProfileModel(
      id: 'DRV-882',
      name: 'Captain Tarek Mostafa',
      phone: '+20 100 123 4567',
      licenseNumber: 'EGY-COMM-99412',
      assignedBusPlate: 'س ق د 1892',
      assignedBusNumber: 'BUS-101',
      assignedRouteId: 'BUS-101',
      assignedRouteName: 'AlexBank HQ → Innovation Park',
      rating: 4.95,
      totalTripsCompleted: 342,
    );

    test('serializes to and from JSON', () {
      final json = profile.toJson();
      expect(json['id'], 'DRV-882');
      expect(json['name'], 'Captain Tarek Mostafa');
      expect(json['assignedBusPlate'], 'س ق د 1892');

      final deserialized = DriverProfileModel.fromJson(json);
      expect(deserialized.id, profile.id);
      expect(deserialized.name, profile.name);
      expect(deserialized.rating, 4.95);
      expect(deserialized.totalTripsCompleted, 342);
    });

    test('copyWith updates fields correctly', () {
      final updated = profile.copyWith(rating: 5.0, totalTripsCompleted: 343);
      expect(updated.rating, 5.0);
      expect(updated.totalTripsCompleted, 343);
      expect(updated.name, profile.name);
    });
  });

  group('TripManifestItemModel', () {
    const item = TripManifestItemModel(
      id: 'MNF-001',
      passId: 'BP-101-08',
      employeeName: 'Ahmed Mansour',
      employeeIsl: '4920',
      department: 'IT Infrastructure',
      seatNumber: 8,
      pickupStop: 'City Center Hub',
      status: 'booked',
    );

    test('serializes to and from JSON', () {
      final json = item.toJson();
      expect(json['id'], 'MNF-001');
      expect(json['employeeName'], 'Ahmed Mansour');
      expect(json['seatNumber'], 8);
      expect(json['status'], 'booked');

      final deserialized = TripManifestItemModel.fromJson(json);
      expect(deserialized.id, item.id);
      expect(deserialized.employeeName, item.employeeName);
      expect(deserialized.isBoarded, false);
    });

    test('isBoarded getter reflects status', () {
      expect(item.isBoarded, false);
      final boarded = item.copyWith(status: 'boarded');
      expect(boarded.isBoarded, true);
    });
  });

  group('DriverTripModel', () {
    const trip = DriverTripModel(
      tripId: 'TRIP-20260918-101',
      routeId: 'BUS-101',
      routeNumber: '101',
      routeName: 'AlexBank HQ → Innovation Park',
      shift: 'Morning Shift',
      busPlate: 'س ق د 1892',
      status: 'scheduled',
      currentStopIndex: 0,
      stops: [
        BusStopModel(
          id: 'stop-1',
          name: 'AlexBank HQ',
          scheduledTime: '07:30 AM',
          order: 1,
        ),
        BusStopModel(
          id: 'stop-2',
          name: 'Innovation Park',
          scheduledTime: '08:45 AM',
          order: 2,
        ),
      ],
      passengers: [
        TripManifestItemModel(
          id: 'MNF-001',
          passId: 'BP-101-08',
          employeeName: 'Ahmed Mansour',
          employeeIsl: '4920',
          department: 'IT',
          seatNumber: 8,
          pickupStop: 'AlexBank HQ',
          status: 'boarded',
        ),
        TripManifestItemModel(
          id: 'MNF-002',
          passId: 'BP-101-12',
          employeeName: 'Sara Khalil',
          employeeIsl: '3811',
          department: 'Finance',
          seatNumber: 12,
          pickupStop: 'AlexBank HQ',
          status: 'booked',
        ),
      ],
    );

    test('serializes to and from JSON', () {
      final json = trip.toJson();
      expect(json['tripId'], 'TRIP-20260918-101');
      expect(json['routeNumber'], '101');
      expect(json['status'], 'scheduled');

      final deserialized = DriverTripModel.fromJson(json);
      expect(deserialized.tripId, trip.tripId);
      expect(deserialized.stops.length, 2);
      expect(deserialized.passengers.length, 2);
    });

    test('computed getters evaluate correctly', () {
      expect(trip.isScheduled, true);
      expect(trip.isInProgress, false);
      expect(trip.isCompleted, false);
      expect(trip.boardedCount, 1);
      expect(trip.totalPassengers, 2);
      expect(trip.currentStop?.name, 'AlexBank HQ');
      expect(trip.nextStop?.name, 'Innovation Park');
    });

    test(
      'Stop skipping: nextStop skips intermediate stops marked isSkipped',
      () {
        // 10 stops, stops 1-5 and stop 7 are skipped
        final stops = List.generate(10, (i) {
          final stopNum = i + 1;
          final isSkipped = (stopNum <= 5) || (stopNum == 7);
          return BusStopModel(
            id: 'S-$stopNum',
            name: 'Stop $stopNum',
            scheduledTime: '07:${stopNum * 5} AM',
            order: stopNum,
            isSkipped: isSkipped,
            riderCount: isSkipped ? 0 : 2,
          );
        });

        final optimizedTrip = trip.copyWith(
          currentStopIndex: 5, // Stop 6 (index 5)
          stops: stops,
        );

        expect(optimizedTrip.isRouteOptimized, isTrue);
        expect(optimizedTrip.skippedStopsCount, equals(6));
        expect(optimizedTrip.currentStop?.name, equals('Stop 6'));
        // Next stop must be Stop 8 (skipping Stop 7!)
        expect(optimizedTrip.nextStop?.name, equals('Stop 8'));
        expect(
          optimizedTrip.nextActiveStopIndex,
          equals(7),
        ); // index 7 is Stop 8
      },
    );
  });
}
