import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/buses/data/models/bus_boarding_pass_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_states.dart';

/// Manages bus transit routes, stop manifests, seat booking, and boarding passes.
class BusCubit extends Cubit<BusStates> {
  List<BusRouteModel> _routes = [];
  BusRouteModel? _selectedRoute;
  BusBoardingPassModel? _activePass;
  String _selectedShift = 'All';

  BusCubit() : super(const BusStates.initial()) {
    _initMockData();
  }

  List<BusRouteModel> get routes => List.unmodifiable(_routes);
  BusRouteModel? get selectedRoute => _selectedRoute;
  BusBoardingPassModel? get activePass => _activePass;
  String get selectedShift => _selectedShift;

  List<BusRouteModel> get filteredRoutes {
    if (_selectedShift == 'All') return _routes;
    return _routes.where((r) => r.shift.toLowerCase() == _selectedShift.toLowerCase()).toList();
  }

  void _initMockData() {
    _routes = [
      // MORNING ROUTES (Cairo / Giza -> Smart Village HQ)
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
        status: 'en_route',
        stops: [
          BusStopModel(
            id: 'S101-1',
            name: 'Victoria Square',
            nameAr: 'ميدان فيكتوريا',
            scheduledTime: '07:15 AM',
            isCompleted: true,
            order: 1,
          ),
          BusStopModel(
            id: 'S101-2',
            name: 'Degla Center',
            nameAr: 'سنتر دجلة',
            scheduledTime: '07:30 AM',
            isCompleted: true,
            isCurrent: true,
            order: 2,
          ),
          BusStopModel(
            id: 'S101-3',
            name: 'Arab Intersection',
            nameAr: 'تقاطع العرب',
            scheduledTime: '07:45 AM',
            order: 3,
          ),
          BusStopModel(
            id: 'S101-4',
            name: 'Autostrad / Ring Road',
            nameAr: 'الأوتوستراد والدائري',
            scheduledTime: '08:05 AM',
            order: 4,
          ),
          BusStopModel(
            id: 'S101-5',
            name: 'Smart Village (AlexBank HQ)',
            nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
            scheduledTime: '08:30 AM',
            order: 5,
          ),
        ],
      ),
      const BusRouteModel(
        id: 'R102',
        routeNumber: 'Route 102',
        name: 'New Cairo & Tagamoa — Smart Village HQ',
        shift: 'Morning',
        departureTime: '07:00 AM',
        estimatedArrival: '08:25 AM',
        totalSeats: 28,
        availableSeats: 3,
        driverName: 'Tarek Fawzy',
        driverPhone: '+20 102 987 6543',
        busPlate: 'د هـ و 5678',
        status: 'on_time',
        stops: [
          BusStopModel(
            id: 'S102-1',
            name: '90th Street North',
            nameAr: 'شمال التسعين',
            scheduledTime: '07:00 AM',
            order: 1,
          ),
          BusStopModel(
            id: 'S102-2',
            name: 'Concord Plaza',
            nameAr: 'كونكورد بلازا',
            scheduledTime: '07:20 AM',
            order: 2,
          ),
          BusStopModel(
            id: 'S102-3',
            name: 'Choueifat Junction',
            nameAr: 'تقاطع الشويفات',
            scheduledTime: '07:40 AM',
            order: 3,
          ),
          BusStopModel(
            id: 'S102-4',
            name: 'Ring Road — Katameya',
            nameAr: 'الدائري والقطامية',
            scheduledTime: '08:00 AM',
            order: 4,
          ),
          BusStopModel(
            id: 'S102-5',
            name: 'Smart Village (AlexBank HQ)',
            nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
            scheduledTime: '08:25 AM',
            order: 5,
          ),
        ],
      ),
      const BusRouteModel(
        id: 'R103',
        routeNumber: 'Route 103',
        name: 'Heliopolis & Nasr City — Smart Village HQ',
        shift: 'Morning',
        departureTime: '07:20 AM',
        estimatedArrival: '08:35 AM',
        totalSeats: 28,
        availableSeats: 0,
        driverName: 'Essam Nabil',
        driverPhone: '+20 111 555 8899',
        busPlate: 'س ع ص 9012',
        status: 'on_time',
        stops: [
          BusStopModel(
            id: 'S103-1',
            name: 'Korba Square',
            nameAr: 'ميدان الكوربة',
            scheduledTime: '07:20 AM',
            order: 1,
          ),
          BusStopModel(
            id: 'S103-2',
            name: 'Roxy Plaza',
            nameAr: 'روكسي',
            scheduledTime: '07:35 AM',
            order: 2,
          ),
          BusStopModel(
            id: 'S103-3',
            name: 'Abbas El Akkad',
            nameAr: 'عباس العقاد',
            scheduledTime: '07:55 AM',
            order: 3,
          ),
          BusStopModel(
            id: 'S103-4',
            name: 'Tayaran Intersection',
            nameAr: 'تقاطع الطيران',
            scheduledTime: '08:10 AM',
            order: 4,
          ),
          BusStopModel(
            id: 'S103-5',
            name: 'Smart Village (AlexBank HQ)',
            nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
            scheduledTime: '08:35 AM',
            order: 5,
          ),
        ],
      ),
      const BusRouteModel(
        id: 'R104',
        routeNumber: 'Route 104',
        name: '6th of October & Zayed — Smart Village HQ',
        shift: 'Morning',
        departureTime: '06:45 AM',
        estimatedArrival: '08:20 AM',
        totalSeats: 28,
        availableSeats: 8,
        driverName: 'Sameh Refaat',
        driverPhone: '+20 122 333 4411',
        busPlate: 'ط ي ك 3456',
        status: 'on_time',
        stops: [
          BusStopModel(
            id: 'S104-1',
            name: 'Hosary Mosque',
            nameAr: 'جامع الحصري',
            scheduledTime: '06:45 AM',
            order: 1,
          ),
          BusStopModel(
            id: 'S104-2',
            name: 'Sheikh Zayed Entrance 1',
            nameAr: 'مدخل زايد 1',
            scheduledTime: '07:05 AM',
            order: 2,
          ),
          BusStopModel(
            id: 'S104-3',
            name: 'Hyper One',
            nameAr: 'هايبر وان',
            scheduledTime: '07:25 AM',
            order: 3,
          ),
          BusStopModel(
            id: 'S104-4',
            name: 'Mehwar Axis',
            nameAr: 'محور 26 يوليو',
            scheduledTime: '07:45 AM',
            order: 4,
          ),
          BusStopModel(
            id: 'S104-5',
            name: 'Smart Village (AlexBank HQ)',
            nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
            scheduledTime: '08:20 AM',
            order: 5,
          ),
        ],
      ),

      // MIRRORED EVENING ROUTES (Smart Village HQ -> Cairo / Giza in reverse order)
      const BusRouteModel(
        id: 'R201',
        routeNumber: 'Route 201',
        name: 'Smart Village HQ — Maadi Return',
        shift: 'Evening',
        departureTime: '04:45 PM',
        estimatedArrival: '06:00 PM',
        totalSeats: 28,
        availableSeats: 12,
        driverName: 'Mahmoud Sayed',
        driverPhone: '+20 100 123 4567',
        busPlate: 'أ ب ج 1234',
        status: 'on_time',
        stops: [
          BusStopModel(
            id: 'S201-1',
            name: 'Smart Village (AlexBank HQ)',
            nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
            scheduledTime: '04:45 PM',
            order: 1,
          ),
          BusStopModel(
            id: 'S201-2',
            name: 'Autostrad / Ring Road',
            nameAr: 'الأوتوستراد والدائري',
            scheduledTime: '05:10 PM',
            order: 2,
          ),
          BusStopModel(
            id: 'S201-3',
            name: 'Arab Intersection',
            nameAr: 'تقاطع العرب',
            scheduledTime: '05:30 PM',
            order: 3,
          ),
          BusStopModel(
            id: 'S201-4',
            name: 'Degla Center',
            nameAr: 'سنتر دجلة',
            scheduledTime: '05:45 PM',
            order: 4,
          ),
          BusStopModel(
            id: 'S201-5',
            name: 'Victoria Square',
            nameAr: 'ميدان فيكتوريا',
            scheduledTime: '06:00 PM',
            order: 5,
          ),
        ],
      ),
      const BusRouteModel(
        id: 'R202',
        routeNumber: 'Route 202',
        name: 'Smart Village HQ — New Cairo Return',
        shift: 'Evening',
        departureTime: '04:45 PM',
        estimatedArrival: '06:15 PM',
        totalSeats: 28,
        availableSeats: 15,
        driverName: 'Tarek Fawzy',
        driverPhone: '+20 102 987 6543',
        busPlate: 'د هـ و 5678',
        status: 'on_time',
        stops: [
          BusStopModel(
            id: 'S202-1',
            name: 'Smart Village (AlexBank HQ)',
            nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
            scheduledTime: '04:45 PM',
            order: 1,
          ),
          BusStopModel(
            id: 'S202-2',
            name: 'Ring Road — Katameya',
            nameAr: 'الدائري والقطامية',
            scheduledTime: '05:15 PM',
            order: 2,
          ),
          BusStopModel(
            id: 'S202-3',
            name: 'Choueifat Junction',
            nameAr: 'تقاطع الشويفات',
            scheduledTime: '05:35 PM',
            order: 3,
          ),
          BusStopModel(
            id: 'S202-4',
            name: 'Concord Plaza',
            nameAr: 'كونكورد بلازا',
            scheduledTime: '05:55 PM',
            order: 4,
          ),
          BusStopModel(
            id: 'S202-5',
            name: '90th Street North',
            nameAr: 'شمال التسعين',
            scheduledTime: '06:15 PM',
            order: 5,
          ),
        ],
      ),
      const BusRouteModel(
        id: 'R203',
        routeNumber: 'Route 203',
        name: 'Smart Village HQ — Heliopolis & Nasr City Return',
        shift: 'Evening',
        departureTime: '04:45 PM',
        estimatedArrival: '06:10 PM',
        totalSeats: 28,
        availableSeats: 10,
        driverName: 'Essam Nabil',
        driverPhone: '+20 111 555 8899',
        busPlate: 'س ع ص 9012',
        status: 'on_time',
        stops: [
          BusStopModel(
            id: 'S203-1',
            name: 'Smart Village (AlexBank HQ)',
            nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
            scheduledTime: '04:45 PM',
            order: 1,
          ),
          BusStopModel(
            id: 'S203-2',
            name: 'Tayaran Intersection',
            nameAr: 'تقاطع الطيران',
            scheduledTime: '05:20 PM',
            order: 2,
          ),
          BusStopModel(
            id: 'S203-3',
            name: 'Abbas El Akkad',
            nameAr: 'عباس العقاد',
            scheduledTime: '05:35 PM',
            order: 3,
          ),
          BusStopModel(
            id: 'S203-4',
            name: 'Roxy Plaza',
            nameAr: 'روكسي',
            scheduledTime: '05:50 PM',
            order: 4,
          ),
          BusStopModel(
            id: 'S203-5',
            name: 'Korba Square',
            nameAr: 'ميدان الكوربة',
            scheduledTime: '06:10 PM',
            order: 5,
          ),
        ],
      ),
      const BusRouteModel(
        id: 'R204',
        routeNumber: 'Route 204',
        name: 'Smart Village HQ — 6th of October & Zayed Return',
        shift: 'Evening',
        departureTime: '04:45 PM',
        estimatedArrival: '05:55 PM',
        totalSeats: 28,
        availableSeats: 14,
        driverName: 'Sameh Refaat',
        driverPhone: '+20 122 333 4411',
        busPlate: 'ط ي ك 3456',
        status: 'on_time',
        stops: [
          BusStopModel(
            id: 'S204-1',
            name: 'Smart Village (AlexBank HQ)',
            nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
            scheduledTime: '04:45 PM',
            order: 1,
          ),
          BusStopModel(
            id: 'S204-2',
            name: 'Mehwar Axis',
            nameAr: 'محور 26 يوليو',
            scheduledTime: '05:05 PM',
            order: 2,
          ),
          BusStopModel(
            id: 'S204-3',
            name: 'Hyper One',
            nameAr: 'هايبر وان',
            scheduledTime: '05:20 PM',
            order: 3,
          ),
          BusStopModel(
            id: 'S204-4',
            name: 'Sheikh Zayed Entrance 1',
            nameAr: 'مدخل زايد 1',
            scheduledTime: '05:35 PM',
            order: 4,
          ),
          BusStopModel(
            id: 'S204-5',
            name: 'Hosary Mosque',
            nameAr: 'جامع الحصري',
            scheduledTime: '05:55 PM',
            order: 5,
          ),
        ],
      ),
    ];

    // Default demonstration active pass
    _activePass = BusBoardingPassModel(
      id: 'PASS-88214',
      routeId: 'R101',
      routeName: 'Maadi — HQ Express',
      routeNumber: 'Route 101',
      busNumber: 'Bus #14',
      stopName: 'Victoria Square',
      seatNumber: 14,
      employeeName: 'Ahmed Hassan',
      departureTime: '07:15 AM',
      status: 'active',
      qrPayload: 'ALEXBANK-TRANSIT:ROUTE-101:SEAT-14:AHMED-HASSAN:PASS-88214',
      bookedAt: DateTime(2026, 9, 17, 6, 30),
    );
  }

  /// Loads routes and passes with brief network delay simulation.
  Future<void> loadBuses() async {
    safeEmit(const BusStates.loading());
    await Future.delayed(const Duration(milliseconds: 500));
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

  /// Reserves a seat on a selected route for the designated pickup stop.
  Future<bool> bookSeat({
    required String routeId,
    required String stopId,
    required String employeeName,
  }) async {
    final routeIndex = _routes.indexWhere((r) => r.id == routeId);
    if (routeIndex == -1) {
      safeEmit(const BusStates.error(message: 'Selected bus route was not found'));
      return false;
    }

    final route = _routes[routeIndex];
    if (route.availableSeats <= 0) {
      safeEmit(const BusStates.error(message: 'Sorry, this route is already at full capacity'));
      return false;
    }

    BusStopModel? selectedStop;
    try {
      selectedStop = route.stops.firstWhere((s) => s.id == stopId);
    } catch (_) {
      selectedStop = route.stops.first;
    }

    safeEmit(const BusStates.bookingSeat());
    await Future.delayed(const Duration(milliseconds: 800));

    final assignedSeat = (route.totalSeats - route.availableSeats) + 1;
    final passId = 'PASS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final newPass = BusBoardingPassModel(
      id: passId,
      routeId: route.id,
      routeName: route.name,
      routeNumber: route.routeNumber,
      busNumber: 'Bus #${route.id.replaceAll(RegExp(r'[^0-9]'), '')}',
      stopName: selectedStop.name,
      seatNumber: assignedSeat,
      employeeName: employeeName.trim().isEmpty ? 'Employee' : employeeName.trim(),
      departureTime: selectedStop.scheduledTime,
      status: 'active',
      qrPayload: 'ALEXBANK-TRANSIT:${route.routeNumber}:SEAT-$assignedSeat:${employeeName.trim()}:$passId',
      bookedAt: DateTime.now(),
    );

    // Update route seats
    _routes[routeIndex] = route.copyWith(
      availableSeats: route.availableSeats - 1,
    );

    _activePass = newPass;
    safeEmit(BusStates.success(newPass));
    safeEmit(const BusStates.loaded());
    return true;
  }

  /// Cancels an active seat reservation.
  Future<bool> cancelBooking(String passId) async {
    if (_activePass == null || _activePass!.id != passId) {
      safeEmit(const BusStates.error(message: 'Boarding pass not found'));
      return false;
    }

    safeEmit(const BusStates.cancellingBooking());
    await Future.delayed(const Duration(milliseconds: 700));

    // Restore seat on route
    final routeIndex = _routes.indexWhere((r) => r.id == _activePass!.routeId);
    if (routeIndex != -1) {
      final route = _routes[routeIndex];
      _routes[routeIndex] = route.copyWith(
        availableSeats: (route.availableSeats + 1).clamp(0, route.totalSeats),
      );
    }

    _activePass = null;
    safeEmit(const BusStates.success('Seat reservation cancelled successfully'));
    safeEmit(const BusStates.loaded());
    return true;
  }

  /// Checks in for today's bus ride using digital pass.
  Future<void> checkInForToday() async {
    if (_activePass == null) {
      safeEmit(const BusStates.error(message: 'No active boarding pass to check in'));
      return;
    }

    safeEmit(const BusStates.checkingInToday());
    await Future.delayed(const Duration(milliseconds: 600));

    _activePass = _activePass!.copyWith(status: 'boarded');
    safeEmit(const BusStates.success('Checked in with driver! Enjoy your ride.'));
    safeEmit(const BusStates.loaded());
  }

  // ================= ADMIN ROUTE & SCHEDULE CONTROLS =================

  /// Admin: Adds a new station to an existing route.
  void addStationToRoute(String routeId, BusStopModel newStop) {
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index == -1) return;

    final route = _routes[index];
    final updatedStops = List<BusStopModel>.from(route.stops)..add(newStop);
    updatedStops.sort((a, b) => a.order.compareTo(b.order));

    _routes[index] = route.copyWith(stops: updatedStops);
    safeEmit(BusStates.success('Station "${newStop.name}" added to ${route.routeNumber}'));
    safeEmit(const BusStates.loaded());
  }

  /// Admin: Removes a station from an existing route.
  void removeStationFromRoute(String routeId, String stopId) {
    final index = _routes.indexWhere((r) => r.id == routeId);
    if (index == -1) return;

    final route = _routes[index];
    final updatedStops = route.stops.where((s) => s.id != stopId).toList();

    _routes[index] = route.copyWith(stops: updatedStops);
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

    _routes[index] = route.copyWith(stops: updatedStops);
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
    _routes[index] = route.copyWith(
      departureTime: departureTime ?? route.departureTime,
      estimatedArrival: estimatedArrival ?? route.estimatedArrival,
      driverName: driverName ?? route.driverName,
      busPlate: busPlate ?? route.busPlate,
    );
    safeEmit(BusStates.success('Route details updated for ${route.routeNumber}'));
    safeEmit(const BusStates.loaded());
  }

  /// Admin: Automatically generates or syncs the mirrored evening return route
  /// originating from Smart Village (HQ) back to the Cairo departure stations in exact reverse order.
  BusRouteModel generateReverseEveningRoute(
    String morningRouteId, {
    String departureTime = '04:45 PM',
    String estimatedArrival = '06:00 PM',
  }) {
    final morningRoute = _routes.firstWhere((r) => r.id == morningRouteId);
    final eveningRouteId = morningRoute.id.replaceFirst('R1', 'R2');
    final eveningRouteNumber = morningRoute.routeNumber.replaceFirst('10', '20');

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

    safeEmit(BusStates.success('Mirrored evening return route synced for $eveningRouteNumber'));
    safeEmit(const BusStates.loaded());
    return eveningRoute;
  }
}
