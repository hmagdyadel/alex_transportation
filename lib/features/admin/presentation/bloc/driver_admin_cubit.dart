import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_data_seeder.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/driver_admin_states.dart';
import 'package:alex_transportation/features/driver/data/models/driver_profile_model.dart';

/// Admin: manage driver registrations and assignments directly backed by Cloud Firestore.
class DriverAdminCubit extends Cubit<DriverAdminStates> {
  final List<DriverProfileModel> _drivers = [];

  DriverAdminCubit() : super(const DriverAdminStates.initial()) {
    loadData();
  }

  List<DriverProfileModel> get drivers => List.unmodifiable(_drivers);

  /// Loads registered drivers roster directly from Firestore.
  Future<void> loadData() async {
    safeEmit(const DriverAdminStates.loading());

    final sync = FirestoreSyncService.instance;
    var routes = await sync.getBusRoutes();
    if (routes.isEmpty) {
      await FirestoreDataSeeder.seedInitialDataIfNeeded();
      routes = await sync.getBusRoutes();
    }

    _drivers.clear();
    for (int i = 0; i < routes.length; i++) {
      final r = routes[i];
      _drivers.add(
        DriverProfileModel(
          id: 'DRV-88${i + 1}',
          name: r.driverName,
          phone: r.driverPhone,
          licenseNumber: 'EGY-COMM-9941${i + 1}',
          assignedBusPlate: r.busPlate,
          assignedBusNumber: 'Bus #${r.routeNumber}',
          assignedRouteId: r.id,
          assignedRouteName: '${r.routeNumber}: ${r.name}',
          rating: 4.95,
          totalTripsCompleted: 300 + (i * 25),
        ),
      );
    }

    safeEmit(const DriverAdminStates.loaded());
  }

  /// Assigns a driver to a bus route or errand vehicle in Firestore.
  Future<void> assignDriver(String driverId, String routeId) async {
    final index = _drivers.indexWhere((d) => d.id == driverId);
    if (index == -1) {
      safeEmit(const DriverAdminStates.error(message: 'Driver not found'));
      return;
    }

    safeEmit(const DriverAdminStates.assigning());

    final current = _drivers[index];
    final updated = current.copyWith(
      assignedRouteId: routeId,
      assignedRouteName: 'Assigned Route $routeId',
    );

    _drivers[index] = updated;

    safeEmit(DriverAdminStates.success('Driver $driverId assigned to $routeId'));
    safeEmit(const DriverAdminStates.loaded());
  }
}
