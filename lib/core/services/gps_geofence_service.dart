import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';

/// Service managing GPS location streaming, geodesic distance calculation,
/// geofence arrival detection, and simulation for AlexBank bus transit.
class GpsGeofenceService {
  GpsGeofenceService._();
  static final GpsGeofenceService instance = GpsGeofenceService._();

  StreamSubscription<Position>? _positionSubscription;
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();

  final Set<String> _triggeredStopIds = {};
  Position? _lastKnownPosition;
  bool _isListening = false;

  /// Broadcast stream of current driver/bus GPS positions.
  Stream<Position> get positionStream => _positionController.stream;

  /// Last known GPS location.
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Whether active GPS streaming is running.
  bool get isListening => _isListening;

  /// Checks and requests location permissions.
  Future<bool> checkAndRequestPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[GpsGeofenceService] Location services are disabled.');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[GpsGeofenceService] Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[GpsGeofenceService] Location permissions are permanently denied');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('[GpsGeofenceService] Error checking permissions: $e');
      return false;
    }
  }

  /// Starts listening to real device GPS updates.
  Future<void> startLocationUpdates({
    void Function(Position position)? onPosition,
  }) async {
    if (_isListening) return;

    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      debugPrint('[GpsGeofenceService] Proceeding in fallback/simulation mode without native GPS');
    }

    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Minimum change of 10 meters
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (position) {
          _lastKnownPosition = position;
          _positionController.add(position);
          onPosition?.call(position);
        },
        onError: (e) {
          debugPrint('[GpsGeofenceService] GPS stream error: $e');
        },
      );

      _isListening = true;
      debugPrint('[GpsGeofenceService] GPS tracking started.');
    } catch (e) {
      debugPrint('[GpsGeofenceService] Could not start native GPS stream: $e');
    }
  }

  /// Stops the GPS position stream.
  void stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isListening = false;
    debugPrint('[GpsGeofenceService] GPS tracking stopped.');
  }

  /// Manually simulates or injects a GPS position (useful for testing on emulator).
  void simulatePosition({
    required double latitude,
    required double longitude,
    double speed = 40.0,
    double accuracy = 5.0,
  }) {
    final simulated = Position(
      longitude: longitude,
      latitude: latitude,
      timestamp: DateTime.now(),
      accuracy: accuracy,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: speed,
      speedAccuracy: 0.0,
    );

    _lastKnownPosition = simulated;
    _positionController.add(simulated);
  }

  /// Calculates geodesic surface distance in meters between two coordinates
  /// using the high-accuracy Haversine formula.
  static double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMeters = 6371000;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Checks if a given coordinate is within the target stop's geofence radius.
  bool isWithinGeofence({
    required double currentLat,
    required double currentLng,
    required BusStopModel targetStop,
  }) {
    if (targetStop.latitude == null || targetStop.longitude == null) {
      return false;
    }

    final distance = calculateDistanceMeters(
      currentLat,
      currentLng,
      targetStop.latitude!,
      targetStop.longitude!,
    );

    return distance <= targetStop.radiusMeters;
  }

  /// Computes distance in meters from a current coordinate to a target stop.
  /// Returns null if stop does not have GPS coordinates.
  double? distanceToStop({
    required double currentLat,
    required double currentLng,
    required BusStopModel targetStop,
  }) {
    if (targetStop.latitude == null || targetStop.longitude == null) {
      return null;
    }

    return calculateDistanceMeters(
      currentLat,
      currentLng,
      targetStop.latitude!,
      targetStop.longitude!,
    );
  }

  /// Formats raw meters into human-readable distance (e.g. "150 m" or "2.4 km").
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Tries to trigger geofence arrival for a stop ID.
  /// Returns true if this is the first trigger for this stop (debounced).
  bool tryTriggerArrival(String stopId) {
    if (_triggeredStopIds.contains(stopId)) {
      return false;
    }
    _triggeredStopIds.add(stopId);
    return true;
  }

  /// Resets debounced stops (e.g. when starting a new trip).
  void resetTriggers() {
    _triggeredStopIds.clear();
  }
}
