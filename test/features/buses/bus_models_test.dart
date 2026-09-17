import 'package:flutter_test/flutter_test.dart';
import 'package:alex_transportation/features/buses/data/models/bus_boarding_pass_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';

void main() {
  group('Bus Models Pure JSON Serialization', () {
    test('BusStopModel serialization and deserialization', () {
      const stop = BusStopModel(
        id: 'S1',
        name: 'Victoria Square',
        nameAr: 'ميدان فيكتوريا',
        scheduledTime: '07:15 AM',
        isCompleted: true,
        isCurrent: false,
        order: 1,
      );

      final json = stop.toJson();
      expect(json['id'], 'S1');
      expect(json['name'], 'Victoria Square');
      expect(json['nameAr'], 'ميدان فيكتوريا');
      expect(json['isCompleted'], true);

      final deserialized = BusStopModel.fromJson(json);
      expect(deserialized.id, 'S1');
      expect(deserialized.scheduledTime, '07:15 AM');
    });

    test('BusRouteModel serialization and deserialization', () {
      const route = BusRouteModel(
        id: 'R1',
        routeNumber: 'Route 101',
        name: 'Maadi Express',
        shift: 'Morning',
        departureTime: '07:15 AM',
        estimatedArrival: '08:30 AM',
        totalSeats: 28,
        availableSeats: 6,
        driverName: 'Mahmoud Sayed',
        driverPhone: '+20 100 123 4567',
        busPlate: 'ABC 123',
        status: 'en_route',
        stops: [
          BusStopModel(
            id: 'S1',
            name: 'Victoria Square',
            scheduledTime: '07:15 AM',
            order: 1,
          ),
        ],
      );

      final json = route.toJson();
      expect(json['id'], 'R1');
      expect(json['routeNumber'], 'Route 101');
      expect(json['totalSeats'], 28);
      expect(json['availableSeats'], 6);
      expect(json['stops'], isA<List>());

      final deserialized = BusRouteModel.fromJson(json);
      expect(deserialized.id, 'R1');
      expect(deserialized.stops.length, 1);
      expect(deserialized.stops.first.name, 'Victoria Square');
    });

    test('BusBoardingPassModel serialization and deserialization', () {
      final now = DateTime.parse('2026-09-17T07:00:00.000Z');
      final pass = BusBoardingPassModel(
        id: 'PASS-101',
        routeId: 'R1',
        routeName: 'Maadi Express',
        routeNumber: 'Route 101',
        busNumber: 'Bus #14',
        stopName: 'Victoria Square',
        seatNumber: 14,
        employeeName: 'Ahmed Hassan',
        departureTime: '07:15 AM',
        status: 'active',
        qrPayload: 'ALEXBANK-TRANSIT:ROUTE-101:SEAT-14:PASS-101',
        bookedAt: now,
      );

      final json = pass.toJson();
      expect(json['id'], 'PASS-101');
      expect(json['seatNumber'], 14);
      expect(json['employeeName'], 'Ahmed Hassan');
      expect(json['bookedAt'], now.toIso8601String());

      final deserialized = BusBoardingPassModel.fromJson(json);
      expect(deserialized.id, 'PASS-101');
      expect(deserialized.seatNumber, 14);
      expect(deserialized.status, 'active');
    });
  });
}
