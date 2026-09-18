import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/bus_admin_states.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';

/// Admin: manage bus routes, subscribers, trips, and riders.
class BusAdminCubit extends Cubit<BusAdminStates> {
  final List<BusRouteModel> _routes = [];
  final List<Map<String, dynamic>> _subscribers = [];

  BusAdminCubit() : super(const BusAdminStates.initial()) {
    loadData();
  }

  List<BusRouteModel> get routes => List.unmodifiable(_routes);
  List<Map<String, dynamic>> get subscribers => List.unmodifiable(_subscribers);

  /// Loads routes, operational metrics, and passenger subscription rosters.
  Future<void> loadData() async {
    safeEmit(const BusAdminStates.loading());
    await Future.delayed(const Duration(milliseconds: 200));

    if (_routes.isEmpty) {
      _routes.addAll([
        const BusRouteModel(
          id: 'R101',
          routeNumber: 'Route 101',
          name: 'Maadi — Smart Village HQ',
          shift: 'Morning',
          departureTime: '07:15 AM',
          estimatedArrival: '08:30 AM',
          totalSeats: 28,
          availableSeats: 6,
          driverName: 'Mahmoud Sayed',
          driverPhone: '+20 100 123 4567',
          busPlate: 'أ ب ج 1234',
          status: 'on_time',
          stops: [
            BusStopModel(
              id: 'S101-1',
              name: 'Victoria Square',
              nameAr: 'ميدان فيكتوريا',
              scheduledTime: '07:15 AM',
              isCompleted: false,
              isCurrent: true,
              order: 1,
            ),
            BusStopModel(
              id: 'S101-2',
              name: 'Smart Village (AlexBank HQ)',
              nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
              scheduledTime: '08:30 AM',
              order: 2,
            ),
          ],
        ),
      ]);
    }

    if (_subscribers.isEmpty) {
      _subscribers.addAll([
        {
          'id': 'SUB-101',
          'employeeName': 'Sherif Nabil',
          'employeeIsl': '10492',
          'routeNumber': 'Route 101',
          'stopName': 'Victoria Square',
          'status': 'active',
        },
        {
          'id': 'SUB-102',
          'employeeName': 'Mona Zaki',
          'employeeIsl': '11204',
          'routeNumber': 'Route 101',
          'stopName': 'Degla Center',
          'status': 'active',
        },
      ]);
    }

    safeEmit(const BusAdminStates.loaded());
  }

  /// Starts an active bus route trip from the admin console.
  Future<void> startTrip(String busId) async {
    safeEmit(const BusAdminStates.startingTrip());
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _routes.indexWhere((r) => r.id == busId || r.routeNumber == busId);
    if (index != -1) {
      _routes[index] = _routes[index].copyWith(status: 'en_route');
    }

    safeEmit(BusAdminStates.success('Trip started successfully for bus $busId'));
    safeEmit(const BusAdminStates.loaded());
  }

  /// Removes an employee subscription from a bus route.
  Future<void> removeSubscriber(String subId) async {
    safeEmit(const BusAdminStates.removingSubscriber());
    await Future.delayed(const Duration(milliseconds: 300));

    _subscribers.removeWhere((s) => s['id'] == subId);

    safeEmit(BusAdminStates.success('Subscriber $subId removed from route manifest'));
    safeEmit(const BusAdminStates.loaded());
  }
}
