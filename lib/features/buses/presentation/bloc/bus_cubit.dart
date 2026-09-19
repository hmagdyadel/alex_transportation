import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_data_seeder.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/buses/data/models/bus_boarding_pass_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/buses/domain/services/bus_route_optimizer.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_states.dart';

/// Manages bus transit routes, dynamic stop optimization, seat booking, and boarding passes
/// directly backed by Cloud Firestore collections.
class BusCubit extends Cubit<BusStates> {
  List<BusRouteModel> _routes = [];
  BusRouteModel? _selectedRoute;
  BusBoardingPassModel? _activePass;
  String _selectedShift = 'All';
  StreamSubscription? _routeSubscription;

  BusCubit() : super(const BusStates.initial()) {
    _initFromCache();
  }

  void _initFromCache() {
    final sync = FirestoreSyncService.instance;
    final cachedRoutes = sync.getCachedBusRoutes();
    final allBookings = sync.getCachedBusBookings();

    final optimizedRoutes = <BusRouteModel>[];
    for (final route in cachedRoutes) {
      final routeBookings = allBookings
          .where((b) => b.routeId == route.id)
          .toList();
      final bookedStops = routeBookings.map((b) => b.stopName).toList();

      final plan = BusRouteOptimizer.optimizeRoute(
        stops: route.stops,
        bookedPickupStops: bookedStops,
      );

      final available = routeBookings.isNotEmpty
          ? (route.totalSeats - routeBookings.length).clamp(0, route.totalSeats)
          : route.availableSeats;

      optimizedRoutes.add(
        route.copyWith(stops: plan.optimizedStops, availableSeats: available),
      );
    }

    _routes = optimizedRoutes;
    if (allBookings.isNotEmpty) {
      _activePass = allBookings.first;
    }
  }

  List<BusRouteModel> get routes => List.unmodifiable(_routes);
  BusRouteModel? get selectedRoute => _selectedRoute;
  BusBoardingPassModel? get activePass => _activePass;
  String get selectedShift => _selectedShift;

  List<BusRouteModel> get filteredRoutes {
    if (_selectedShift == 'All') return _routes;
    return _routes
        .where((r) => r.shift.toLowerCase() == _selectedShift.toLowerCase())
        .toList();
  }

  /// Loads official bus routes from Firestore and optimizes stops based on active passenger bookings.
  Future<void> loadRoutes({String? employeeName}) async {
    safeEmit(const BusStates.loading());

    final sync = FirestoreSyncService.instance;
    var loadedRoutes = await sync.getBusRoutes();

    // If Firestore collections are newly initialized/empty, seed initial records
    if (loadedRoutes.isEmpty) {
      await FirestoreDataSeeder.seedInitialDataIfNeeded();
      loadedRoutes = await sync.getBusRoutes();
    }

    // Retrieve passenger bookings from Firestore to perform dynamic route optimization
    final allBookings = await sync.getBusBookings();

    final optimizedRoutes = <BusRouteModel>[];
    for (final route in loadedRoutes) {
      final routeBookings = allBookings
          .where((b) => b.routeId == route.id)
          .toList();
      final bookedStops = routeBookings.map((b) => b.stopName).toList();

      final plan = BusRouteOptimizer.optimizeRoute(
        stops: route.stops,
        bookedPickupStops: bookedStops,
      );

      final available = routeBookings.isNotEmpty
          ? (route.totalSeats - routeBookings.length).clamp(0, route.totalSeats)
          : route.availableSeats;

      optimizedRoutes.add(
        route.copyWith(stops: plan.optimizedStops, availableSeats: available),
      );
    }

    _routes = optimizedRoutes;

    // Check for employee's active pass in Firestore
    if (employeeName != null) {
      final userBookings = await sync.getBusBookings(
        employeeName: employeeName,
      );
      _activePass = userBookings.isNotEmpty ? userBookings.first : null;
    }

    if (_selectedRoute != null) {
      _selectedRoute = _routes.firstWhere(
        (r) => r.id == _selectedRoute!.id,
        orElse: () => _routes.first,
      );
    }

    safeEmit(const BusStates.loaded());
  }

  /// Filters routes by shift: 'All', 'Morning', 'Evening'.
  void filterShift(String shift) {
    _selectedShift = shift;
    safeEmit(const BusStates.loaded());
  }

  /// Selects a route to view its detailed stop timeline.
  void selectRoute(BusRouteModel? route) {
    _selectedRoute = route;
    safeEmit(const BusStates.loaded());
  }

  /// Reserves a seat on a selected route for the designated pickup stop directly in Firestore.
  Future<bool> bookSeat({
    required String routeId,
    required String stopId,
    required String employeeName,
  }) async {
    final routeIndex = _routes.indexWhere((r) => r.id == routeId);
    if (routeIndex == -1) {
      safeEmit(
        const BusStates.error(message: 'Selected bus route was not found'),
      );
      return false;
    }

    final route = _routes[routeIndex];
    if (route.availableSeats <= 0) {
      safeEmit(
        const BusStates.error(
          message: 'Sorry, this route is already at full capacity',
        ),
      );
      return false;
    }

    BusStopModel? selectedStop;
    try {
      selectedStop = route.stops.firstWhere((s) => s.id == stopId);
    } catch (_) {
      selectedStop = route.stops.first;
    }

    safeEmit(const BusStates.bookingSeat());

    final assignedSeat = (route.totalSeats - route.availableSeats) + 1;
    final passId =
        'PASS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final newPass = BusBoardingPassModel(
      id: passId,
      routeId: route.id,
      routeName: route.name,
      routeNumber: route.routeNumber,
      busNumber: 'Bus #${route.id.replaceAll(RegExp(r'[^0-9]'), '')}',
      stopName: selectedStop.name,
      seatNumber: assignedSeat,
      employeeName: employeeName.trim().isEmpty
          ? 'Employee'
          : employeeName.trim(),
      departureTime: selectedStop.scheduledTime,
      status: 'active',
      qrPayload:
          'ALEXBANK-TRANSIT:${route.routeNumber}:SEAT-$assignedSeat:${employeeName.trim()}:$passId',
      bookedAt: DateTime.now(),
    );

    // Save to Firestore collections
    final sync = FirestoreSyncService.instance;
    await sync.saveBusBooking(newPass);

    final updatedRoute = route.copyWith(
      availableSeats: (route.availableSeats - 1).clamp(0, route.totalSeats),
    );
    _routes[routeIndex] = updatedRoute;
    await sync.saveBusRoute(updatedRoute);

    _activePass = newPass;

    safeEmit(BusStates.success(newPass));
    safeEmit(const BusStates.loaded());
    return true;
  }

  /// Cancels an active seat reservation in Firestore and re-optimizes the route stops.
  Future<bool> cancelBooking(String passId) async {
    if (_activePass == null || _activePass!.id != passId) {
      safeEmit(const BusStates.error(message: 'Boarding pass not found'));
      return false;
    }

    safeEmit(const BusStates.cancellingBooking());

    final savedRouteId = _activePass!.routeId;
    final sync = FirestoreSyncService.instance;
    await sync.cancelBusBooking(passId);

    // Restore seat on route
    final routeIndex = _routes.indexWhere((r) => r.id == savedRouteId);
    if (routeIndex != -1) {
      final route = _routes[routeIndex];
      final updatedRoute = route.copyWith(
        availableSeats: (route.availableSeats + 1).clamp(0, route.totalSeats),
      );
      _routes[routeIndex] = updatedRoute;
      await sync.saveBusRoute(updatedRoute);
    }

    _activePass = null;

    safeEmit(
      const BusStates.success('Seat reservation cancelled successfully'),
    );
    safeEmit(const BusStates.loaded());
    return true;
  }

  /// Checks in for today's bus ride using digital pass.
  Future<void> checkInForToday() async {
    if (_activePass == null) {
      safeEmit(
        const BusStates.error(message: 'No active boarding pass to check in'),
      );
      return;
    }

    safeEmit(const BusStates.checkingInToday());
    _activePass = _activePass!.copyWith(status: 'boarded');
    await FirestoreSyncService.instance.saveBusBooking(_activePass!);

    safeEmit(
      const BusStates.success('Checked in with driver! Enjoy your ride.'),
    );
    safeEmit(const BusStates.loaded());
  }

  // ================= ADMIN ROUTE & SCHEDULE CONTROLS =================

  /// Admin: Adds a new station to an existing route directly in Firestore.
  void addStationToRoute(String routeId, BusStopModel newStop) {
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index == -1) return;

    final route = _routes[index];
    final updatedStops = List<BusStopModel>.from(route.stops)..add(newStop);
    updatedStops.sort((a, b) => a.order.compareTo(b.order));

    final updatedRoute = route.copyWith(stops: updatedStops);
    _routes[index] = updatedRoute;
    FirestoreSyncService.instance.saveBusRoute(updatedRoute);

    safeEmit(
      BusStates.success(
        'Station "${newStop.name}" added to ${route.routeNumber}',
      ),
    );
    safeEmit(const BusStates.loaded());
  }

  /// Admin: Removes a station from an existing route in Firestore.
  void removeStationFromRoute(String routeId, String stopId) {
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index == -1) return;

    final route = _routes[index];
    final updatedStops = route.stops.where((s) => s.id != stopId).toList();

    final updatedRoute = route.copyWith(stops: updatedStops);
    _routes[index] = updatedRoute;
    FirestoreSyncService.instance.saveBusRoute(updatedRoute);

    safeEmit(BusStates.success('Station removed from ${route.routeNumber}'));
    safeEmit(const BusStates.loaded());
  }

  /// Admin: Updates the scheduled time of a specific station.
  void updateStationTime(String routeId, String stopId, String newTime) {
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index == -1) return;

    final route = _routes[index];
    final updatedStops = route.stops.map((s) {
      if (s.id == stopId) {
        return s.copyWith(scheduledTime: newTime);
      }
      return s;
    }).toList();

    final updatedRoute = route.copyWith(stops: updatedStops);
    _routes[index] = updatedRoute;
    FirestoreSyncService.instance.saveBusRoute(updatedRoute);

    safeEmit(BusStates.success('Station timing updated to $newTime'));
    safeEmit(const BusStates.loaded());
  }

  /// Admin: Updates general route schedule or driver assignment.
  void updateRouteSchedule(
    String routeId, {
    String? departureTime,
    String? estimatedArrival,
    String? driverName,
    String? busPlate,
  }) {
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index == -1) return;

    final route = _routes[index];
    final updatedRoute = route.copyWith(
      departureTime: departureTime ?? route.departureTime,
      estimatedArrival: estimatedArrival ?? route.estimatedArrival,
      driverName: driverName ?? route.driverName,
      busPlate: busPlate ?? route.busPlate,
    );
    _routes[index] = updatedRoute;
    FirestoreSyncService.instance.saveBusRoute(updatedRoute);

    safeEmit(
      BusStates.success('Route details updated for ${route.routeNumber}'),
    );
    safeEmit(const BusStates.loaded());
  }

  /// Alias for loadRoutes to support existing screen callbacks.
  Future<void> loadBuses() => loadRoutes();

  /// Admin: Automatically generates or syncs the mirrored evening return route
  /// originating from Smart Village (HQ) back to the Cairo departure stations in exact reverse order.
  BusRouteModel generateReverseEveningRoute(
    String morningRouteId, {
    String departureTime = '04:45 PM',
    String estimatedArrival = '06:00 PM',
  }) {
    final morningRoute = _routes.firstWhere(
      (r) => r.id == morningRouteId,
      orElse: () => FirestoreDataSeeder.initialRoutes.firstWhere(
        (r) => r.id == morningRouteId,
      ),
    );
    final eveningRouteId = morningRoute.id.replaceFirst('R1', 'R2');
    final eveningRouteNumber = morningRoute.routeNumber.replaceFirst(
      '10',
      '20',
    );

    // Reverse stops: Smart Village HQ becomes stop #1, and preceding stations reverse order.
    final reversedMorningStops = morningRoute.stops.reversed.toList();
    final reversedStops = <BusStopModel>[];

    for (int i = 0; i < reversedMorningStops.length; i++) {
      final s = reversedMorningStops[i];
      final isFirst = i == 0;
      final isLast = i == reversedMorningStops.length - 1;

      reversedStops.add(
        BusStopModel(
          id: '${eveningRouteId}_S${i + 1}',
          name: s.name,
          nameAr: s.nameAr,
          scheduledTime: isFirst
              ? departureTime
              : isLast
              ? estimatedArrival
              : 'Transit Stop',
          order: i + 1,
          latitude: s.latitude,
          longitude: s.longitude,
          radiusMeters: s.radiusMeters,
        ),
      );
    }

    final eveningRoute = BusRouteModel(
      id: eveningRouteId,
      routeNumber: eveningRouteNumber,
      name: '${morningRoute.name.split('—').first.trim()} — Mirrored Return',
      shift: 'Evening',
      departureTime: departureTime,
      estimatedArrival: estimatedArrival,
      totalSeats: morningRoute.totalSeats,
      availableSeats: morningRoute.totalSeats,
      driverName: morningRoute.driverName,
      driverPhone: morningRoute.driverPhone,
      busPlate: morningRoute.busPlate,
      stops: reversedStops,
    );

    final existingIndex = _routes.indexWhere((r) => r.id == eveningRouteId);
    if (existingIndex != -1) {
      _routes[existingIndex] = eveningRoute;
    } else {
      _routes.add(eveningRoute);
    }

    FirestoreSyncService.instance.saveBusRoute(eveningRoute);

    safeEmit(
      BusStates.success(
        'Mirrored evening return route synced for $eveningRouteNumber',
      ),
    );
    safeEmit(const BusStates.loaded());
    return eveningRoute;
  }

  @override
  Future<void> close() {
    _routeSubscription?.cancel();
    return super.close();
  }
}
