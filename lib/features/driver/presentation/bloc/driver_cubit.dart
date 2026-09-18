import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/core/services/gps_geofence_service.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/driver/data/models/driver_profile_model.dart';
import 'package:alex_transportation/features/driver/data/models/driver_trip_model.dart';
import 'package:alex_transportation/features/driver/data/models/trip_manifest_item_model.dart';
import 'package:alex_transportation/features/driver/presentation/bloc/driver_states.dart';

/// Manages driver profile, active trip execution, route stops navigation,
/// pre-trip vehicle safety inspection, passenger boarding pass verification,
/// and automatic GPS geofence stop arrival detection.
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
  Map<String, bool> get inspectionChecklist => Map.unmodifiable(_inspectionChecklist);
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

  /// Loads driver profile, vehicle assignment, active route, and passenger manifest.
  Future<void> loadDriverDashboard() async {
    safeEmit(const DriverStates.loading());

    await Future.delayed(const Duration(milliseconds: 300));

    _profile = const DriverProfileModel(
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

    final initialStops = [
      const BusStopModel(
        id: 'stop-1',
        name: 'AlexBank HQ (Main Gate)',
        nameAr: 'المقر الرئيسي لبنك الإسكندرية',
        scheduledTime: '07:30 AM',
        isCompleted: false,
        isCurrent: true,
        order: 1,
        latitude: 30.0715,
        longitude: 31.0210,
        radiusMeters: 150.0,
      ),
      const BusStopModel(
        id: 'stop-2',
        name: 'City Center Hub',
        nameAr: 'محطة سيتي سنتر',
        scheduledTime: '07:50 AM',
        isCompleted: false,
        isCurrent: false,
        order: 2,
        latitude: 30.0520,
        longitude: 31.0530,
        radiusMeters: 150.0,
      ),
      const BusStopModel(
        id: 'stop-3',
        name: 'Metro Station — Station 4',
        nameAr: 'محطة المترو — المحطة الرابعة',
        scheduledTime: '08:15 AM',
        isCompleted: false,
        isCurrent: false,
        order: 3,
        latitude: 30.0380,
        longitude: 31.0850,
        radiusMeters: 150.0,
      ),
      const BusStopModel(
        id: 'stop-4',
        name: 'Innovation Park Campus',
        nameAr: 'مجمع واحة الابتكار',
        scheduledTime: '08:45 AM',
        isCompleted: false,
        isCurrent: false,
        order: 4,
        latitude: 30.0190,
        longitude: 31.1210,
        radiusMeters: 150.0,
      ),
    ];

    final initialPassengers = [
      const TripManifestItemModel(
        id: 'MNF-001',
        passId: 'BP-101-08',
        employeeName: 'Ahmed Mansour',
        employeeIsl: '4920',
        department: 'IT Infrastructure',
        seatNumber: 8,
        pickupStop: 'City Center Hub',
        status: 'booked',
      ),
      const TripManifestItemModel(
        id: 'MNF-002',
        passId: 'BP-101-12',
        employeeName: 'Sara Khalil',
        employeeIsl: '3811',
        department: 'Finance & Treasury',
        seatNumber: 12,
        pickupStop: 'AlexBank HQ (Main Gate)',
        status: 'boarded',
      ),
      const TripManifestItemModel(
        id: 'MNF-003',
        passId: 'BP-101-15',
        employeeName: 'Omar Sherif',
        employeeIsl: '2901',
        department: 'Operations & Logistics',
        seatNumber: 15,
        pickupStop: 'Metro Station — Station 4',
        status: 'booked',
      ),
      const TripManifestItemModel(
        id: 'MNF-004',
        passId: 'BP-101-04',
        employeeName: 'Nour El-Din',
        employeeIsl: '5542',
        department: 'Risk Management',
        seatNumber: 4,
        pickupStop: 'AlexBank HQ (Main Gate)',
        status: 'boarded',
      ),
      const TripManifestItemModel(
        id: 'MNF-005',
        passId: 'BP-101-19',
        employeeName: 'Dina Adel',
        employeeIsl: '6109',
        department: 'Human Resources',
        seatNumber: 19,
        pickupStop: 'City Center Hub',
        status: 'booked',
      ),
      const TripManifestItemModel(
        id: 'MNF-006',
        passId: 'BP-101-22',
        employeeName: 'Mostafa Hassan',
        employeeIsl: '4233',
        department: 'Legal Affairs',
        seatNumber: 22,
        pickupStop: 'Metro Station — Station 4',
        status: 'booked',
      ),
    ];

    _activeTrip = DriverTripModel(
      tripId: 'TRIP-20260918-101',
      routeId: 'BUS-101',
      routeNumber: '101',
      routeName: 'AlexBank HQ → Innovation Park',
      shift: 'Morning Shift',
      busPlate: 'س ق د 1892',
      status: 'scheduled',
      currentStopIndex: 0,
      stops: initialStops,
      passengers: initialPassengers,
      startedAt: null,
      completedAt: null,
    );

    safeEmit(const DriverStates.loaded());
  }

  /// Toggles an inspection checklist item.
  void toggleInspectionItem(String itemId) {
    if (_inspectionChecklist.containsKey(itemId)) {
      _inspectionChecklist[itemId] = !(_inspectionChecklist[itemId] ?? false);
      safeEmit(const DriverStates.loaded());
    }
  }

  /// Toggles automatic GPS geofencing arrival detection.
  void toggleAutoGeofence() {
    _isAutoGeofenceEnabled = !_isAutoGeofenceEnabled;
    safeEmit(const DriverStates.loaded());
  }

  /// Starts the bus trip and enters in_progress state with live GPS geofencing.
  Future<void> startTrip() async {
    final trip = _activeTrip;
    if (trip == null) {
      safeEmit(const DriverStates.error(message: 'No trip session available'));
      return;
    }

    if (trip.isInProgress) {
      safeEmit(const DriverStates.error(message: 'Trip is already in progress'));
      return;
    }

    safeEmit(const DriverStates.startingTrip());
    await Future.delayed(const Duration(milliseconds: 600));

    final updatedStops = trip.stops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;
      return stop.copyWith(
        isCurrent: index == 0,
        isCompleted: false,
      );
    }).toList();

    _activeTrip = trip.copyWith(
      status: 'in_progress',
      currentStopIndex: 0,
      stops: updatedStops,
      startedAt: DateTime.now(),
    );

    // Initialize GPS Geofencing
    _startGpsGeofencing();

    FirestoreSyncService.instance.syncDriverTripStatus(_activeTrip!);

    safeEmit(const DriverStates.success('Trip started! Route 101 is now active.'));
    safeEmit(const DriverStates.loaded());
  }

  void _startGpsGeofencing() {
    _gpsSubscription?.cancel();
    GpsGeofenceService.instance.resetTriggers();

    if (_activeTrip != null && _activeTrip!.stops.isNotEmpty) {
      GpsGeofenceService.instance.tryTriggerArrival(_activeTrip!.stops[0].id);
      if (_activeTrip!.stops.length > 1) {
        final nextStop = _activeTrip!.stops[1];
        if (_activeTrip!.stops[0].latitude != null && _activeTrip!.stops[0].longitude != null) {
          _distanceToNextStopMeters = GpsGeofenceService.instance.distanceToStop(
            currentLat: _activeTrip!.stops[0].latitude!,
            currentLng: _activeTrip!.stops[0].longitude!,
            targetStop: nextStop,
          );
        }
      }
    }

    _gpsSubscription = GpsGeofenceService.instance.positionStream.listen((pos) {
      handleGpsLocationUpdate(pos.latitude, pos.longitude);
    });

    GpsGeofenceService.instance.startLocationUpdates();
    _isGpsActive = true;
  }

  /// Processes a GPS location update and detects geofence arrival at the next stop.
  void handleGpsLocationUpdate(double latitude, double longitude) {
    final trip = _activeTrip;
    if (trip == null || !trip.isInProgress) return;

    final currentIdx = trip.currentStopIndex;
    if (currentIdx >= trip.stops.length - 1) {
      _distanceToNextStopMeters = 0;
      safeEmit(const DriverStates.loaded());
      return;
    }

    final targetStop = trip.stops[currentIdx + 1];
    final distance = GpsGeofenceService.instance.distanceToStop(
      currentLat: latitude,
      currentLng: longitude,
      targetStop: targetStop,
    );

    _distanceToNextStopMeters = distance;
    _isGpsActive = true;

    // Check automatic geofence arrival
    if (_isAutoGeofenceEnabled && distance != null && distance <= targetStop.radiusMeters) {
      if (GpsGeofenceService.instance.tryTriggerArrival(targetStop.id)) {
        advanceToNextStop(isFromGps: true);
        return;
      }
    }

    safeEmit(const DriverStates.loaded());
  }

  /// Advances to the next stop along the route.
  Future<void> advanceToNextStop({bool isFromGps = false}) async {
    final trip = _activeTrip;
    if (trip == null || !trip.isInProgress) {
      safeEmit(const DriverStates.error(message: 'No active trip in progress'));
      return;
    }

    final currentIdx = trip.currentStopIndex;
    if (currentIdx >= trip.stops.length - 1) {
      safeEmit(const DriverStates.error(message: 'Already at the final destination! You can now complete the trip.'));
      return;
    }

    safeEmit(const DriverStates.advancingStop());
    await Future.delayed(const Duration(milliseconds: 350));

    final nextIdx = currentIdx + 1;
    final updatedStops = trip.stops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;
      return stop.copyWith(
        isCompleted: index < nextIdx,
        isCurrent: index == nextIdx,
      );
    }).toList();

    _activeTrip = trip.copyWith(
      currentStopIndex: nextIdx,
      stops: updatedStops,
    );

    if (nextIdx < trip.stops.length - 1) {
      final upcoming = trip.stops[nextIdx + 1];
      final lastPos = GpsGeofenceService.instance.lastKnownPosition;
      if (lastPos != null) {
        _distanceToNextStopMeters = GpsGeofenceService.instance.distanceToStop(
          currentLat: lastPos.latitude,
          currentLng: lastPos.longitude,
          targetStop: upcoming,
        );
      } else if (trip.stops[nextIdx].latitude != null && trip.stops[nextIdx].longitude != null) {
        _distanceToNextStopMeters = GpsGeofenceService.instance.distanceToStop(
          currentLat: trip.stops[nextIdx].latitude!,
          currentLng: trip.stops[nextIdx].longitude!,
          targetStop: upcoming,
        );
      }
    } else {
      _distanceToNextStopMeters = 0;
    }

    FirestoreSyncService.instance.syncDriverTripStatus(_activeTrip!);

    final nextStopName = trip.stops[nextIdx].name;
    if (isFromGps) {
      safeEmit(DriverStates.success('📍 GPS Geofence: Arrived at $nextStopName!'));
    } else {
      safeEmit(DriverStates.success('Arrived at $nextStopName'));
    }
    safeEmit(const DriverStates.loaded());
  }

  /// Simulates entering the geofence of the next stop (for demo / emulator testing).
  Future<void> simulateArrivalAtNextStop() async {
    final trip = _activeTrip;
    if (trip == null || !trip.isInProgress) return;
    final currentIdx = trip.currentStopIndex;
    if (currentIdx >= trip.stops.length - 1) return;

    final targetStop = trip.stops[currentIdx + 1];
    if (targetStop.latitude != null && targetStop.longitude != null) {
      GpsGeofenceService.instance.simulatePosition(
        latitude: targetStop.latitude!,
        longitude: targetStop.longitude!,
      );
    } else {
      await advanceToNextStop(isFromGps: true);
    }
  }

  /// Toggles or marks a passenger as boarded.
  Future<void> boardPassenger(String passengerId) async {
    final trip = _activeTrip;
    if (trip == null) return;

    safeEmit(const DriverStates.boardingPassenger());
    await Future.delayed(const Duration(milliseconds: 300));

    final passengerIndex = trip.passengers.indexWhere((p) => p.id == passengerId);
    if (passengerIndex == -1) {
      safeEmit(const DriverStates.error(message: 'Passenger not found on manifest'));
      return;
    }

    final passenger = trip.passengers[passengerIndex];
    final newStatus = passenger.isBoarded ? 'booked' : 'boarded';
    final updatedPassenger = passenger.copyWith(
      status: newStatus,
      boardedAt: newStatus == 'boarded' ? DateTime.now() : null,
    );

    final updatedList = List<TripManifestItemModel>.from(trip.passengers);
    updatedList[passengerIndex] = updatedPassenger;

    _activeTrip = trip.copyWith(passengers: updatedList);

    if (newStatus == 'boarded') {
      safeEmit(DriverStates.success('${passenger.employeeName} checked in on board'));
    } else {
      safeEmit(DriverStates.success('${passenger.employeeName} check-in reverted'));
    }
    safeEmit(const DriverStates.loaded());
  }

  /// Completes the trip session upon reaching the final destination.
  Future<void> completeTrip() async {
    final trip = _activeTrip;
    if (trip == null || !trip.isInProgress) {
      safeEmit(const DriverStates.error(message: 'No active trip to complete'));
      return;
    }

    safeEmit(const DriverStates.completingTrip());
    await Future.delayed(const Duration(milliseconds: 700));

    final updatedStops = trip.stops.map((stop) => stop.copyWith(
      isCompleted: true,
      isCurrent: false,
    )).toList();

    _activeTrip = trip.copyWith(
      status: 'completed',
      stops: updatedStops,
      completedAt: DateTime.now(),
    );

    _gpsSubscription?.cancel();
    GpsGeofenceService.instance.stopLocationUpdates();
    _isGpsActive = false;
    _distanceToNextStopMeters = null;

    FirestoreSyncService.instance.syncDriverTripStatus(_activeTrip!);

    safeEmit(const DriverStates.success('Trip completed! All passengers safely arrived.'));
    safeEmit(const DriverStates.loaded());
  }

  @override
  Future<void> close() {
    _gpsSubscription?.cancel();
    GpsGeofenceService.instance.stopLocationUpdates();
    return super.close();
  }
}
