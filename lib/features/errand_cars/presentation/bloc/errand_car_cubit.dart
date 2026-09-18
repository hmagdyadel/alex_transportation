import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_car_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_dispatch_pass_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_request_model.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_states.dart';

/// Manages official errand car fleet, mission requests, dispatch passes,
/// and mileage tracking.
class ErrandCarCubit extends Cubit<ErrandCarStates> {
  List<ErrandCarModel> _fleet = [];
  List<ErrandRequestModel> _requests = [];
  ErrandDispatchPassModel? _activePass;

  static const int totalFleet = 5;

  ErrandCarCubit() : super(const ErrandCarStates.initial()) {
    _initMockData();
  }

  List<ErrandCarModel> get fleet => List.unmodifiable(_fleet);
  List<ErrandRequestModel> get myRequests => List.unmodifiable(_requests);
  ErrandDispatchPassModel? get activePass => _activePass;

  int get availableCars =>
      _fleet.where((c) => c.status == 'available').length;

  List<ErrandCarModel> get availableCarsList =>
      _fleet.where((c) => c.status == 'available').toList();

  void _initMockData() {
    _fleet = [
      ErrandCarModel(
        id: 'CAR-001',
        plateNumber: 'أ ب ج 4567',
        make: 'Mercedes-Benz E-Class',
        color: 'Black',
        status: 'in_use',
        currentMileage: 34520,
        lastServiceDate: DateTime(2026, 8, 15),
      ),
      ErrandCarModel(
        id: 'CAR-002',
        plateNumber: 'د هـ و 8901',
        make: 'BMW 520i',
        color: 'Dark Grey',
        status: 'available',
        currentMileage: 28310,
        lastServiceDate: DateTime(2026, 9, 1),
      ),
      ErrandCarModel(
        id: 'CAR-003',
        plateNumber: 'س ع ص 2345',
        make: 'Toyota Camry',
        color: 'White',
        status: 'available',
        currentMileage: 41870,
        lastServiceDate: DateTime(2026, 7, 20),
      ),
      ErrandCarModel(
        id: 'CAR-004',
        plateNumber: 'ط ي ك 6789',
        make: 'Hyundai Sonata',
        color: 'Silver',
        status: 'available',
        currentMileage: 19450,
        lastServiceDate: DateTime(2026, 9, 10),
      ),
      ErrandCarModel(
        id: 'CAR-005',
        plateNumber: 'ل م ن 1122',
        make: 'Kia K5',
        color: 'Navy Blue',
        status: 'maintenance',
        currentMileage: 52300,
        lastServiceDate: DateTime(2026, 6, 5),
      ),
    ];

    // Demo active request + dispatch pass
    _requests = [
      ErrandRequestModel(
        id: 'ERQ-3942',
        employeeName: 'Ahmed Hassan',
        employeeIsl: '10234',
        department: 'IT',
        pickupLocation: 'Smart Village Operations Hub',
        destination: 'Finance Hub Branch',
        purpose: 'Deliver signed audit documents to Finance Hub for quarterly review',
        requestedDate: '18 Sep 2026',
        requestedTime: '10:00 AM',
        estimatedReturnTime: '02:00 PM',
        supervisorName: 'Dr. Hany Fouad',
        status: 'approved',
        assignedCarId: 'CAR-001',
        assignedCarPlate: 'أ ب ج 4567',
        assignedCarMake: 'Mercedes-Benz E-Class',
        assignedDriverName: 'Khaled Nasser',
        submittedAt: DateTime(2026, 9, 17, 14, 30),
        approvedAt: DateTime(2026, 9, 17, 15, 45),
      ),
      ErrandRequestModel(
        id: 'ERQ-3938',
        employeeName: 'Ahmed Hassan',
        employeeIsl: '10234',
        department: 'IT',
        pickupLocation: 'AlexBank Downtown Cairo HQ',
        destination: 'Central Bank of Egypt',
        purpose: 'Submit regulatory compliance forms',
        requestedDate: '15 Sep 2026',
        requestedTime: '09:30 AM',
        estimatedReturnTime: '12:30 PM',
        supervisorName: 'Dr. Hany Fouad',
        status: 'completed',
        assignedCarId: 'CAR-003',
        assignedCarPlate: 'س ع ص 2345',
        assignedCarMake: 'Toyota Camry',
        submittedAt: DateTime(2026, 9, 14, 16, 0),
        approvedAt: DateTime(2026, 9, 14, 17, 15),
      ),
      ErrandRequestModel(
        id: 'ERQ-3935',
        employeeName: 'Ahmed Hassan',
        employeeIsl: '10234',
        department: 'IT',
        pickupLocation: 'Smart Village Operations Hub',
        destination: 'Nasr City Branch',
        purpose: 'IT equipment delivery and installation',
        requestedDate: '12 Sep 2026',
        requestedTime: '11:00 AM',
        estimatedReturnTime: '03:00 PM',
        supervisorName: 'Dr. Hany Fouad',
        status: 'rejected',
        submittedAt: DateTime(2026, 9, 11, 10, 0),
      ),
    ];

    // Active dispatch pass for the approved request
    _activePass = const ErrandDispatchPassModel(
      id: 'ABX-3942',
      requestId: 'ERQ-3942',
      missionCode: 'CPT-912',
      employeeName: 'Ahmed Hassan',
      pickupLocation: 'Smart Village Operations Hub',
      destination: 'Finance Hub Branch',
      carPlate: 'أ ب ج 4567',
      carMake: 'Mercedes-Benz E-Class',
      departureTime: '10:00 AM',
      estimatedReturn: '02:00 PM',
      status: 'active',
      startMileage: 34520,
      qrPayload: 'ALEXBANK:ERRAND:ABX-3942:CPT-912:AHMED-HASSAN:FINANCE-HUB',
    );
  }

  /// Loads fleet and request data with brief delay simulation.
  Future<void> loadFleet() async {
    safeEmit(const ErrandCarStates.loading());
    await Future.delayed(const Duration(milliseconds: 500));
    safeEmit(const ErrandCarStates.loaded());
  }

  /// Submits a new errand car mission request.
  Future<bool> submitRequest({
    required String employeeName,
    required String employeeIsl,
    required String department,
    required String pickupLocation,
    required String destination,
    required String purpose,
    required String requestedDate,
    required String requestedTime,
    required String estimatedReturnTime,
    required String supervisorName,
  }) async {
    // Validation
    if (employeeName.trim().isEmpty) {
      safeEmit(const ErrandCarStates.error(message: 'Employee name is required'));
      return false;
    }
    if (employeeIsl.trim().isEmpty || employeeIsl.trim().length < 4) {
      safeEmit(const ErrandCarStates.error(message: 'Valid Bank ISL (4-8 digits) is required'));
      return false;
    }
    if (pickupLocation.trim().isEmpty) {
      safeEmit(const ErrandCarStates.error(message: 'Pickup location is required'));
      return false;
    }
    if (destination.trim().isEmpty) {
      safeEmit(const ErrandCarStates.error(message: 'Mission destination is required'));
      return false;
    }
    if (purpose.trim().isEmpty) {
      safeEmit(const ErrandCarStates.error(message: 'Mission purpose is required'));
      return false;
    }
    if (supervisorName.trim().isEmpty) {
      safeEmit(const ErrandCarStates.error(message: 'Supervisor name is required'));
      return false;
    }

    safeEmit(const ErrandCarStates.submittingRequest());
    await Future.delayed(const Duration(milliseconds: 900));

    final requestId = 'ERQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Auto-assign an available car if one exists
    final available = availableCarsList;
    ErrandCarModel? assignedCar;
    if (available.isNotEmpty) {
      assignedCar = available.first;
      // Mark car as in use
      final carIndex = _fleet.indexWhere((c) => c.id == assignedCar!.id);
      if (carIndex != -1) {
        _fleet[carIndex] = _fleet[carIndex].copyWith(status: 'in_use');
      }
    }

    final request = ErrandRequestModel(
      id: requestId,
      employeeName: employeeName.trim(),
      employeeIsl: employeeIsl.trim(),
      department: department,
      pickupLocation: pickupLocation.trim(),
      destination: destination.trim(),
      purpose: purpose.trim(),
      requestedDate: requestedDate,
      requestedTime: requestedTime,
      estimatedReturnTime: estimatedReturnTime,
      supervisorName: supervisorName.trim(),
      status: assignedCar != null ? 'approved' : 'pending',
      assignedCarId: assignedCar?.id,
      assignedCarPlate: assignedCar?.plateNumber,
      assignedCarMake: assignedCar?.make,
      submittedAt: DateTime.now(),
      approvedAt: assignedCar != null ? DateTime.now() : null,
    );

    _requests.insert(0, request);

    // If approved, create a dispatch pass
    if (assignedCar != null) {
      final missionCode = 'CPT-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
      final passId = 'ABX-${requestId.replaceAll('ERQ-', '')}';

      _activePass = ErrandDispatchPassModel(
        id: passId,
        requestId: requestId,
        missionCode: missionCode,
        employeeName: employeeName.trim(),
        pickupLocation: pickupLocation.trim(),
        destination: destination.trim(),
        carPlate: assignedCar.plateNumber,
        carMake: assignedCar.make,
        departureTime: requestedTime,
        estimatedReturn: estimatedReturnTime,
        status: 'active',
        startMileage: assignedCar.currentMileage,
        qrPayload:
            'ALEXBANK:ERRAND:$passId:$missionCode:${employeeName.trim().toUpperCase().replaceAll(' ', '-')}:${destination.trim().toUpperCase().replaceAll(' ', '-')}',
      );

      safeEmit(ErrandCarStates.success(request));
    } else {
      safeEmit(const ErrandCarStates.success(
          'Request submitted. Awaiting vehicle availability and supervisor approval.'));
    }

    // Sync errand request to Firestore (fire-and-forget)
    FirestoreSyncService.instance.syncErrandRequest(
      requestId: requestId,
      employeeName: employeeName.trim(),
      pickupLocation: pickupLocation.trim(),
      destination: destination.trim(),
      purpose: purpose.trim(),
      status: request.status,
    );

    safeEmit(const ErrandCarStates.loaded());
    return true;
  }

  /// Cancels a pending request.
  Future<bool> cancelRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      safeEmit(const ErrandCarStates.error(message: 'Request not found'));
      return false;
    }

    final request = _requests[index];
    if (request.status != 'pending' && request.status != 'approved') {
      safeEmit(const ErrandCarStates.error(
          message: 'Only pending or approved requests can be cancelled'));
      return false;
    }

    safeEmit(const ErrandCarStates.cancellingRequest());
    await Future.delayed(const Duration(milliseconds: 600));

    // Free the assigned car if any
    if (request.assignedCarId != null) {
      final carIndex = _fleet.indexWhere((c) => c.id == request.assignedCarId);
      if (carIndex != -1) {
        _fleet[carIndex] = _fleet[carIndex].copyWith(status: 'available');
      }
    }

    _requests[index] = request.copyWith(status: 'cancelled');

    // Clear active pass if it was for this request
    if (_activePass?.requestId == requestId) {
      _activePass = null;
    }

    safeEmit(const ErrandCarStates.success('Errand request cancelled successfully'));
    safeEmit(const ErrandCarStates.loaded());
    return true;
  }

  /// Starts an approved mission — records departure mileage.
  Future<void> startMission(String passId) async {
    if (_activePass == null || _activePass!.id != passId) {
      safeEmit(const ErrandCarStates.error(message: 'Dispatch pass not found'));
      return;
    }

    safeEmit(const ErrandCarStates.startingMission());
    await Future.delayed(const Duration(milliseconds: 600));

    // Update request status to in_progress
    final requestIndex =
        _requests.indexWhere((r) => r.id == _activePass!.requestId);
    if (requestIndex != -1) {
      _requests[requestIndex] =
          _requests[requestIndex].copyWith(status: 'in_progress');
    }

    safeEmit(const ErrandCarStates.success('Mission started! Drive safely.'));
    safeEmit(const ErrandCarStates.loaded());
  }

  /// Ends an active mission — records return mileage and frees the car.
  Future<void> endMission(String passId, int endMileage) async {
    if (_activePass == null || _activePass!.id != passId) {
      safeEmit(const ErrandCarStates.error(message: 'Dispatch pass not found'));
      return;
    }

    if (_activePass!.startMileage != null && endMileage < _activePass!.startMileage!) {
      safeEmit(const ErrandCarStates.error(
          message: 'Return mileage cannot be less than departure mileage'));
      return;
    }

    safeEmit(const ErrandCarStates.endingMission());
    await Future.delayed(const Duration(milliseconds: 700));

    _activePass = _activePass!.copyWith(
      status: 'completed',
      endMileage: endMileage,
    );

    // Update request status
    final requestIndex =
        _requests.indexWhere((r) => r.id == _activePass!.requestId);
    if (requestIndex != -1) {
      _requests[requestIndex] =
          _requests[requestIndex].copyWith(status: 'completed');
    }

    // Free the car and update mileage
    final requestCarId = requestIndex != -1
        ? _requests[requestIndex].assignedCarId
        : null;
    if (requestCarId != null) {
      final carIndex = _fleet.indexWhere((c) => c.id == requestCarId);
      if (carIndex != -1) {
        _fleet[carIndex] = _fleet[carIndex].copyWith(
          status: 'available',
          currentMileage: endMileage,
        );
      }
    }

    final distance = _activePass!.distanceDriven ?? 0;
    safeEmit(ErrandCarStates.success(
        'Mission completed! Total distance: $distance km'));

    _activePass = null;
    safeEmit(const ErrandCarStates.loaded());
  }
}
