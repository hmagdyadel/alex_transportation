import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_data_seeder.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/core/services/gps_geofence_service.dart';
import 'package:alex_transportation/features/buses/domain/services/bus_route_optimizer.dart';
import 'package:alex_transportation/features/driver/data/models/driver_profile_model.dart';
import 'package:alex_transportation/features/driver/data/models/driver_trip_model.dart';
import 'package:alex_transportation/features/driver/data/models/trip_manifest_item_model.dart';
import 'package:alex_transportation/features/driver/presentation/bloc/driver_states.dart';

/// Manages driver profile, active trip execution, dynamic route stop skipping,
/// vehicle safety inspection, passenger boarding, and automatic GPS geofence detection.
class DriverCubit extends Cubit<DriverStates> {
  DriverProfileModel? _profile;
  DriverTripModel? _activeTrip;
  final Map<String, bool> _inspectionChecklist = {
    'tires': true,
    'fuel_battery': true,
    'first_aid': true,
    'ac_ventilation': true,
    'mirrors_cameras': true,
    'cleanliness': true,
  };

  bool _isAutoGeofenceEnabled = true;
  double? _distanceToNextStopMeters;
  bool _isGpsActive = false;
  StreamSubscription? _gpsSubscription;

  DriverCubit() : super(const DriverStates.initial()) {
    loadDriverDashboard();
  }

  DriverProfileModel? get profile => _profile;
  DriverTripModel? get activeTrip => _activeTrip;
  Map<String, bool> get inspectionChecklist =>
      Map.unmodifiable(_inspectionChecklist);
  bool get isInspectionComplete => _inspectionChecklist.values.every((v) => v);

  int get boardedCount => _activeTrip?.boardedCount ?? 0;
  int get totalPassengers => _activeTrip?.totalPassengers ?? 0;

  bool get isAutoGeofenceEnabled => _isAutoGeofenceEnabled;
  double? get distanceToNextStopMeters => _distanceToNextStopMeters;
  bool get isGpsActive => _isGpsActive;

  String? get formattedDistanceToNextStop {
    if (_distanceToNextStopMeters == null) return null;
    return GpsGeofenceService.formatDistance(_distanceToNextStopMeters!);
  }

  /// Loads driver profile, vehicle assignment, active route, and passenger manifest from Firestore.
  Future<void> loadDriverDashboard() async {
    safeEmit(const DriverStates.loading());

    final sync = FirestoreSyncService.instance;
    final routes = await sync.getBusRoutes();

    final hasDynamicRoute = routes.any((r) => r.id == 'R-DYNAMIC-10');
    if (hasDynamicRoute) {
      final route = routes.firstWhere((r) => r.id == 'R-DYNAMIC-10');
      _profile = DriverProfileModel(
        id: 'DRV-882',
        name: route.driverName,
        phone: route.driverPhone,
        licenseNumber: 'EGY-COMM-99412',
        assignedBusPlate: route.busPlate,
        assignedBusNumber: 'BUS-99',
        assignedRouteId: route.id,
        assignedRouteName: route.name,
        rating: 4.95,
        totalTripsCompleted: 342,
      );

      final bookings = await sync.getBusBookings(routeId: route.id);
      final bookedStops = bookings.map((b) => b.stopName).toList();

      final plan = BusRouteOptimizer.optimizeRoute(
        stops: route.stops,
        bookedPickupStops: bookedStops,
      );

      final passengers = bookings.asMap().entries.map((e) {
        final idx = e.key + 1;
        final b = e.value;
        return TripManifestItemModel(
          id: 'MNF-${idx.toString().padLeft(3, '0')}',
          passId: b.id,
          employeeName: b.employeeName,
          employeeIsl: '${4000 + idx}',
          department: 'Operations',
          seatNumber: b.seatNumber,
          pickupStop: b.stopName,
          status: b.status == 'boarded' ? 'boarded' : 'booked',
        );
      }).toList();

      _activeTrip = DriverTripModel(
        tripId: 'TRIP-${route.id}',
        routeId: route.id,
        routeNumber: route.routeNumber,
        routeName: route.name,
        shift: route.shift,
        busPlate: route.busPlate,
        status: 'scheduled',
        currentStopIndex: plan.startingStopIndex,
        stops: plan.optimizedStops,
        passengers: passengers,
      );
    } else {
      _profile = FirestoreDataSeeder.initialDriverProfile;
      _activeTrip = FirestoreDataSeeder.initialDriverTrip;
    }

    await sync.syncDriverTripStatus(_activeTrip!);
    safeEmit(const DriverStates.loaded());
  }

  /// Toggles automatic GPS stop arrival detection on/off.
  void toggleAutoGeofence() {
    _isAutoGeofenceEnabled = !_isAutoGeofenceEnabled;
    safeEmit(const DriverStates.loaded());
  }

  /// Starts the scheduled trip and activates GPS tracking on the first non-skipped stop.
  Future<void> startTrip() async {
    final trip = _activeTrip;
    if (trip == null) {
      safeEmit(const DriverStates.error(message: 'No trip available to start'));
      return;
    }

    if (!isInspectionComplete) {
      safeEmit(
        const DriverStates.error(
          message: 'Pre-trip inspection must be complete before starting',
        ),
      );
      return;
    }

    safeEmit(const DriverStates.startingTrip());
    await Future.delayed(const Duration(milliseconds: 300));

    final startIdx = trip.currentStopIndex;
    final updatedStops = trip.stops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;
      return stop.copyWith(
        isCurrent: index == startIdx,
        isCompleted: index < startIdx,
      );
    }).toList();

    _activeTrip = trip.copyWith(
      status: 'in_progress',
      currentStopIndex: startIdx,
      stops: updatedStops,
      startedAt: DateTime.now(),
    );

    // Initialize GPS Geofencing for the optimized route
    _startGpsGeofencing();

    await FirestoreSyncService.instance.syncDriverTripStatus(_activeTrip!);

    final startStopName = _activeTrip!.currentStop?.name ?? 'Route Start';
    final skippedMsg = _activeTrip!.skippedStopsCount > 0
        ? ' (${_activeTrip!.skippedStopsCount} empty stops skipped)'
        : '';

    safeEmit(
      DriverStates.success('Trip started from $startStopName$skippedMsg!'),
    );
    safeEmit(const DriverStates.loaded());
  }

  void _startGpsGeofencing() {
    _gpsSubscription?.cancel();
    GpsGeofenceService.instance.resetTriggers();

    final trip = _activeTrip;
    if (trip != null && trip.currentStop != null) {
      GpsGeofenceService.instance.tryTriggerArrival(trip.currentStop!.id);
      final next = trip.nextStop;
      if (next != null &&
          trip.currentStop!.latitude != null &&
          trip.currentStop!.longitude != null) {
        _distanceToNextStopMeters = GpsGeofenceService.instance.distanceToStop(
          currentLat: trip.currentStop!.latitude!,
          currentLng: trip.currentStop!.longitude!,
          targetStop: next,
        );
      }
    }

    _gpsSubscription = GpsGeofenceService.instance.positionStream.listen((pos) {
      handleGpsLocationUpdate(pos.latitude, pos.longitude);
    });

    GpsGeofenceService.instance.startLocationUpdates();
    _isGpsActive = true;
  }

  /// Processes a GPS location update and detects geofence arrival at the next active stop.
  void handleGpsLocationUpdate(double latitude, double longitude) {
    final trip = _activeTrip;
    if (trip == null || !trip.isInProgress) return;

    final targetStop = trip.nextStop;
    if (targetStop == null) {
      _distanceToNextStopMeters = 0;
      safeEmit(const DriverStates.loaded());
      return;
    }

    final distance = GpsGeofenceService.instance.distanceToStop(
      currentLat: latitude,
      currentLng: longitude,
      targetStop: targetStop,
    );

    _distanceToNextStopMeters = distance;
    _isGpsActive = true;

    // Check automatic geofence arrival at target stop
    if (_isAutoGeofenceEnabled &&
        distance != null &&
        distance <= targetStop.radiusMeters) {
      if (GpsGeofenceService.instance.tryTriggerArrival(targetStop.id)) {
        advanceToNextStop(isFromGps: true);
        return;
      }
    }

    safeEmit(const DriverStates.loaded());
  }

  /// Advances to the next non-skipped active stop along the route.
  Future<void> advanceToNextStop({bool isFromGps = false}) async {
    final trip = _activeTrip;
    if (trip == null || !trip.isInProgress) {
      safeEmit(const DriverStates.error(message: 'No active trip in progress'));
      return;
    }

    final nextActiveIdx = trip.nextActiveStopIndex;
    if (nextActiveIdx == null) {
      safeEmit(
        const DriverStates.error(
          message: 'Already at the final destination! You can now complete the trip.',
        ),
      );
      return;
    }

    safeEmit(const DriverStates.advancingStop());
    await Future.delayed(const Duration(milliseconds: 350));

    final updatedStops = trip.stops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;
      return stop.copyWith(
        isCompleted: index < nextActiveIdx,
        isCurrent: index == nextActiveIdx,
      );
    }).toList();

    _activeTrip = trip.copyWith(
      currentStopIndex: nextActiveIdx,
      stops: updatedStops,
    );

    // Update distance to upcoming non-skipped stop
    final upcoming = _activeTrip!.nextStop;
    if (upcoming != null) {
      final lastPos = GpsGeofenceService.instance.lastKnownPosition;
      if (lastPos != null) {
        _distanceToNextStopMeters = GpsGeofenceService.instance.distanceToStop(
          currentLat: lastPos.latitude,
          currentLng: lastPos.longitude,
          targetStop: upcoming,
        );
      } else if (_activeTrip!.currentStop?.latitude != null &&
          _activeTrip!.currentStop?.longitude != null) {
        _distanceToNextStopMeters = GpsGeofenceService.instance.distanceToStop(
          currentLat: _activeTrip!.currentStop!.latitude!,
          currentLng: _activeTrip!.currentStop!.longitude!,
          targetStop: upcoming,
        );
      }
    } else {
      _distanceToNextStopMeters = 0;
    }

    await FirestoreSyncService.instance.syncDriverTripStatus(_activeTrip!);

    final nextStopName = trip.stops[nextActiveIdx].name;
    if (isFromGps) {
      safeEmit(
        DriverStates.success('📍 GPS Geofence: Arrived at $nextStopName!'),
      );
    } else {
      safeEmit(DriverStates.success('Arrived at $nextStopName'));
    }
    safeEmit(const DriverStates.loaded());
  }

  /// Simulates entering the geofence of the next active stop (for demo / testing).
  Future<void> simulateArrivalAtNextStop() async {
    final trip = _activeTrip;
    if (trip == null || !trip.isInProgress) return;
    final targetStop = trip.nextStop;
    if (targetStop == null) return;

    if (targetStop.latitude != null && targetStop.longitude != null) {
      GpsGeofenceService.instance.simulatePosition(
        latitude: targetStop.latitude!,
        longitude: targetStop.longitude!,
      );
    } else {
      advanceToNextStop();
    }
  }

  /// Completes the active trip session.
  Future<void> completeTrip() async {
    final trip = _activeTrip;
    if (trip == null || !trip.isInProgress) {
      safeEmit(
        const DriverStates.error(message: 'No trip in progress to complete'),
      );
      return;
    }

    safeEmit(const DriverStates.completingTrip());
    await Future.delayed(const Duration(milliseconds: 600));

    _gpsSubscription?.cancel();
    GpsGeofenceService.instance.stopLocationUpdates();
    _isGpsActive = false;

    _activeTrip = trip.copyWith(
      status: 'completed',
      completedAt: DateTime.now(),
    );

    await FirestoreSyncService.instance.syncDriverTripStatus(_activeTrip!);

    safeEmit(
      const DriverStates.success(
        'Trip completed successfully! All passengers arrived.',
      ),
    );
    safeEmit(const DriverStates.loaded());
  }

  /// Boards a passenger by pass ID.
  Future<bool> boardPassenger(String passId) => togglePassengerBoarding(passId);

  /// Toggles passenger boarding state.
  Future<bool> togglePassengerBoarding(String passId) async {
    final trip = _activeTrip;
    if (trip == null) return false;

    final passengerExists = trip.passengers.any(
      (p) => p.passId == passId || p.id == passId,
    );
    if (!passengerExists) return false;

    final updatedPassengers = trip.passengers.map((p) {
      if (p.passId == passId || p.id == passId) {
        final newStatus = p.isBoarded ? 'booked' : 'boarded';
        return p.copyWith(
          status: newStatus,
          boardedAt: newStatus == 'boarded' ? DateTime.now() : null,
        );
      }
      return p;
    }).toList();

    _activeTrip = trip.copyWith(passengers: updatedPassengers);
    await FirestoreSyncService.instance.syncDriverTripStatus(_activeTrip!);
    safeEmit(const DriverStates.loaded());
    return true;
  }

  /// Toggles a vehicle safety inspection checklist item.
  void toggleInspectionItem(String key) {
    if (_inspectionChecklist.containsKey(key)) {
      _inspectionChecklist[key] = !(_inspectionChecklist[key] ?? false);
      safeEmit(const DriverStates.loaded());
    }
  }

  /// Marks all safety inspection items as checked.
  void markAllInspectionComplete() {
    for (final key in _inspectionChecklist.keys) {
      _inspectionChecklist[key] = true;
    }
    safeEmit(const DriverStates.loaded());
  }

  @override
  Future<void> close() {
    _gpsSubscription?.cancel();
    GpsGeofenceService.instance.stopLocationUpdates();
    return super.close();
  }
}
