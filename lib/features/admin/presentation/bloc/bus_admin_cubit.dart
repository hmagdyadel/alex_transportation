import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_data_seeder.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/bus_admin_states.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';

/// Admin: manage bus routes, subscribers, trips, and riders directly backed by Cloud Firestore.
class BusAdminCubit extends Cubit<BusAdminStates> {
  final List<BusRouteModel> _routes = [];
  final List<Map<String, dynamic>> _subscribers = [];

  BusAdminCubit() : super(const BusAdminStates.initial()) {
    loadData();
  }

  List<BusRouteModel> get routes => List.unmodifiable(_routes);
  List<Map<String, dynamic>> get subscribers => List.unmodifiable(_subscribers);

  /// Loads routes and passenger subscription rosters directly from Cloud Firestore.
  Future<void> loadData() async {
    safeEmit(const BusAdminStates.loading());

    final sync = FirestoreSyncService.instance;
    var loaded = await sync.getBusRoutes();
    if (loaded.isEmpty) {
      await FirestoreDataSeeder.seedInitialDataIfNeeded();
      loaded = await sync.getBusRoutes();
    }

    _routes.clear();
    _routes.addAll(loaded);

    final bookings = await sync.getBusBookings();
    _subscribers.clear();
    for (final b in bookings) {
      _subscribers.add({
        'id': b.id,
        'name': b.employeeName,
        'routeId': b.routeId,
        'stop': b.stopName,
        'seat': b.seatNumber,
      });
    }

    safeEmit(const BusAdminStates.loaded());
  }

  /// Dispatches a bus trip, updating the route status to 'en_route' in Firestore.
  Future<void> startTrip(String routeId) async {
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index == -1) {
      safeEmit(const BusAdminStates.error(message: 'Route not found'));
      return;
    }

    safeEmit(const BusAdminStates.startingTrip());

    final updated = _routes[index].copyWith(status: 'en_route');
    _routes[index] = updated;
    await FirestoreSyncService.instance.saveBusRoute(updated);

    safeEmit(BusAdminStates.success(updated));
    safeEmit(const BusAdminStates.loaded());
  }

  /// Removes an employee from a route and restores seat occupancy in Firestore.
  Future<void> removeSubscriber(String subscriberId, [String? routeId]) async {
    final sub = _subscribers.firstWhere(
      (s) => s['id'] == subscriberId,
      orElse: () => {'id': subscriberId, 'routeId': routeId ?? 'R101'},
    );
    final targetRouteId = routeId ?? (sub['routeId'] as String? ?? 'R101');

    _subscribers.removeWhere((s) => s['id'] == subscriberId);
    await FirestoreSyncService.instance.cancelBusBooking(subscriberId);

    final routeIndex = _routes.indexWhere((r) => r.id == targetRouteId);
    if (routeIndex != -1) {
      final currentRoute = _routes[routeIndex];
      final updatedRoute = currentRoute.copyWith(
        availableSeats: (currentRoute.availableSeats + 1).clamp(0, currentRoute.totalSeats),
      );
      _routes[routeIndex] = updatedRoute;
      await FirestoreSyncService.instance.saveBusRoute(updatedRoute);
    }

    safeEmit(const BusAdminStates.success('Subscriber removed'));
    safeEmit(const BusAdminStates.loaded());
  }
}
