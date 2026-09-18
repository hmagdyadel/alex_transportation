import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/driver_admin_states.dart';
import 'package:alex_transportation/features/driver/data/models/driver_profile_model.dart';

/// Admin: manage driver registrations and assignments.
class DriverAdminCubit extends Cubit<DriverAdminStates> {
  final List<DriverProfileModel> _drivers = [];

  DriverAdminCubit() : super(const DriverAdminStates.initial()) {
    loadData();
  }

  List<DriverProfileModel> get drivers => List.unmodifiable(_drivers);

  /// Loads registered drivers roster and operational vehicle assignments.
  Future<void> loadData() async {
    safeEmit(const DriverAdminStates.loading());
    await Future.delayed(const Duration(milliseconds: 200));

    if (_drivers.isEmpty) {
      _drivers.addAll([
        const DriverProfileModel(
          id: 'DRV-881',
          name: 'Captain Mahmoud Sayed',
          phone: '+20 100 123 4567',
          licenseNumber: 'EGY-COMM-99411',
          assignedBusPlate: 'أ ب ج 1234',
          assignedBusNumber: 'Bus #14',
          assignedRouteId: 'R101',
          assignedRouteName: 'Route 101: Maadi — Smart Village HQ',
          rating: 4.96,
          totalTripsCompleted: 412,
        ),
        const DriverProfileModel(
          id: 'DRV-882',
          name: 'Captain Tarek Fawzy',
          phone: '+20 102 987 6543',
          licenseNumber: 'EGY-COMM-99412',
          assignedBusPlate: 'د هـ و 5678',
          assignedBusNumber: 'Bus #22',
          assignedRouteId: 'R102',
          assignedRouteName: 'Route 102: New Cairo — Smart Village HQ',
          rating: 4.92,
          totalTripsCompleted: 356,
        ),
        const DriverProfileModel(
          id: 'DRV-885',
          name: 'Chauffeur Khaled Nasser',
          phone: '+20 101 222 3344',
          licenseNumber: 'EGY-COMM-99415',
          assignedBusPlate: 'أ ب ج 4567',
          assignedBusNumber: 'Mercedes-Benz E-Class',
          assignedRouteId: 'ERRAND-01',
          assignedRouteName: 'Executive Errand Fleet (CAR-001)',
          rating: 4.98,
          totalTripsCompleted: 520,
        ),
      ]);
    }

    safeEmit(const DriverAdminStates.loaded());
  }

  /// Assigns a driver to a bus route or corporate vehicle resource.
  Future<void> assignDriver(String driverId, String resourceId) async {
    safeEmit(const DriverAdminStates.assigning());
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _drivers.indexWhere((d) => d.id == driverId);
    if (index != -1) {
      _drivers[index] = _drivers[index].copyWith(
        assignedRouteId: resourceId,
        assignedRouteName: 'Assigned: $resourceId',
      );
    }

    safeEmit(DriverAdminStates.success('Driver $driverId assigned to $resourceId'));
    safeEmit(const DriverAdminStates.loaded());
  }
}
