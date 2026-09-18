import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/core/services/gps_geofence_service.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = GpsGeofenceService.instance;

  setUp(() {
    service.resetTriggers();
  });

  group('GpsGeofenceService — Distance Calculations', () {
    test('calculateDistanceMeters returns 0 for identical points', () {
      final distance = GpsGeofenceService.calculateDistanceMeters(
        30.0715,
        31.0210,
        30.0715,
        31.0210,
      );
      expect(distance, closeTo(0.0, 0.001));
    });

    test('calculateDistanceMeters accurately computes geodesic distance', () {
      // Cairo to Alexandria distance is approx 175-185 km
      final distance = GpsGeofenceService.calculateDistanceMeters(
        30.0444,
        31.2357, // Cairo Center
        31.2001,
        29.9187, // Alexandria Center
      );
      final km = distance / 1000;
      expect(km, greaterThan(170));
      expect(km, lessThan(190));
    });

    test('formatDistance formats meters and kilometers properly', () {
      expect(GpsGeofenceService.formatDistance(0), '0 m');
      expect(GpsGeofenceService.formatDistance(145), '145 m');
      expect(GpsGeofenceService.formatDistance(999), '999 m');
      expect(GpsGeofenceService.formatDistance(1000), '1.0 km');
      expect(GpsGeofenceService.formatDistance(1520), '1.5 km');
      expect(GpsGeofenceService.formatDistance(3850), '3.9 km');
    });
  });

  group('GpsGeofenceService — Geofence Detection & Debounce', () {
    const stopWithGps = BusStopModel(
      id: 'stop-test-1',
      name: 'Test Gate',
      scheduledTime: '08:00 AM',
      order: 1,
      latitude: 30.0715,
      longitude: 31.0210,
      radiusMeters: 150.0,
    );

    const stopWithoutGps = BusStopModel(
      id: 'stop-test-2',
      name: 'No GPS Gate',
      scheduledTime: '08:30 AM',
      order: 2,
    );

    test('isWithinGeofence returns true when within radius', () {
      // Coordinate approximately 50 meters away
      final isInside = service.isWithinGeofence(
        currentLat: 30.0718,
        currentLng: 31.0212,
        targetStop: stopWithGps,
      );
      expect(isInside, isTrue);
    });

    test('isWithinGeofence returns false when outside radius', () {
      // Coordinate approximately 5 km away
      final isOutside = service.isWithinGeofence(
        currentLat: 30.0380,
        currentLng: 31.0850,
        targetStop: stopWithGps,
      );
      expect(isOutside, isFalse);
    });

    test('isWithinGeofence returns false when stop lacks GPS coordinates', () {
      final result = service.isWithinGeofence(
        currentLat: 30.0715,
        currentLng: 31.0210,
        targetStop: stopWithoutGps,
      );
      expect(result, isFalse);
    });

    test('distanceToStop returns null when stop lacks GPS coordinates', () {
      final distance = service.distanceToStop(
        currentLat: 30.0715,
        currentLng: 31.0210,
        targetStop: stopWithoutGps,
      );
      expect(distance, isNull);
    });

    test('tryTriggerArrival debounces repeated triggers for the same stop', () {
      expect(service.tryTriggerArrival('stop-A'), isTrue);
      expect(service.tryTriggerArrival('stop-A'), isFalse);
      expect(service.tryTriggerArrival('stop-A'), isFalse);

      // Different stop can trigger
      expect(service.tryTriggerArrival('stop-B'), isTrue);
      expect(service.tryTriggerArrival('stop-B'), isFalse);

      // Reset clears debounce
      service.resetTriggers();
      expect(service.tryTriggerArrival('stop-A'), isTrue);
    });

    test('simulatePosition updates lastKnownPosition and emits to stream', () async {
      final positions = [];
      final sub = service.positionStream.listen(positions.add);

      service.simulatePosition(latitude: 30.0715, longitude: 31.0210);
      await Future.delayed(const Duration(milliseconds: 20));

      expect(service.lastKnownPosition, isNotNull);
      expect(service.lastKnownPosition!.latitude, 30.0715);
      expect(service.lastKnownPosition!.longitude, 31.0210);
      expect(positions.length, 1);

      await sub.cancel();
    });
  });
}
