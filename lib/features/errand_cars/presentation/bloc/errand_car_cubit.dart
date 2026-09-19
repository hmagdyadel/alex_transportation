import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_data_seeder.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_car_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_dispatch_pass_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_request_model.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_states.dart';

/// Manages official errand car fleet, mission requests, dispatch passes,
/// and mileage tracking directly backed by Cloud Firestore collections.
class ErrandCarCubit extends Cubit<ErrandCarStates> {
  final List<ErrandCarModel> _fleet = [];
  final List<ErrandRequestModel> _requests = [];
  ErrandDispatchPassModel? _activePass;

  static const int totalFleet = 5;

  ErrandCarCubit() : super(const ErrandCarStates.initial()) {
    _initFromCache();
  }

  void _initFromCache() {
    final sync = FirestoreSyncService.instance;
    _fleet.clear();
    _fleet.addAll(sync.getCachedErrandFleet());
    _requests.clear();
    _requests.addAll(
      sync.getCachedErrandRequests().where((r) => r.id.startsWith('ERQ-')),
    );
    _activePass = FirestoreDataSeeder.initialErrandPass;
  }

  List<ErrandCarModel> get fleet => List.unmodifiable(_fleet);
  List<ErrandRequestModel> get myRequests => List.unmodifiable(_requests);
  ErrandDispatchPassModel? get activePass => _activePass;

  int get availableCars => _fleet.where((c) => c.status == 'available').length;

  List<ErrandCarModel> get availableCarsList =>
      _fleet.where((c) => c.status == 'available').toList();

  /// Loads fleet and user requests directly from Cloud Firestore collections.
  Future<void> loadFleet({String? employeeIsl}) async {
    safeEmit(const ErrandCarStates.loading());

    final sync = FirestoreSyncService.instance;
    var loadedFleet = await sync.getErrandFleet();

    if (loadedFleet.isEmpty) {
      await FirestoreDataSeeder.seedInitialDataIfNeeded();
      loadedFleet = await sync.getErrandFleet();
    }

    _fleet.clear();
    _fleet.addAll(loadedFleet);

    final reqs = await sync.getErrandRequests(employeeIsl: employeeIsl);
    _requests.clear();
    _requests.addAll(
      employeeIsl != null ? reqs : reqs.where((r) => r.id.startsWith('ERQ-')),
    );

    // If an approved request exists, recreate or load active dispatch pass
    final approved = _requests
        .where((r) => r.status == 'approved' || r.status == 'in_progress')
        .toList();
    if (approved.isNotEmpty) {
      final req = approved.first;
      final assignedCar = _fleet.firstWhere(
        (c) => c.id == req.assignedCarId,
        orElse: () => _fleet.first,
      );

      final missionCode = 'CPT-${req.id.replaceAll(RegExp(r'[^0-9]'), '')}';
      final passId = 'ABX-${req.id.replaceAll('ERQ-', '')}';

      _activePass = ErrandDispatchPassModel(
        id: passId,
        requestId: req.id,
        missionCode: missionCode,
        employeeName: req.employeeName,
        pickupLocation: req.pickupLocation,
        destination: req.destination,
        carPlate: req.assignedCarPlate ?? assignedCar.plateNumber,
        carMake: req.assignedCarMake ?? assignedCar.make,
        departureTime: req.requestedTime,
        estimatedReturn: req.estimatedReturnTime,
        status: req.status == 'in_progress' ? 'in_progress' : 'active',
        startMileage: assignedCar.currentMileage,
        qrPayload:
            'ALEXBANK:ERRAND:$passId:$missionCode:${req.employeeName.trim().toUpperCase().replaceAll(' ', '-')}:${req.destination.trim().toUpperCase().replaceAll(' ', '-')}',
      );
    } else {
      _activePass = null;
    }

    safeEmit(const ErrandCarStates.loaded());
  }

  /// Submits a new errand mission request and persists to Cloud Firestore.
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
    if (purpose.trim().length < 10) {
      safeEmit(
        const ErrandCarStates.error(
          message: 'Please provide a detailed purpose (minimum 10 characters)',
        ),
      );
      return false;
    }

    if (supervisorName.trim().isEmpty) {
      safeEmit(
        const ErrandCarStates.error(
          message: 'Supervisor name is required for mission approval',
        ),
      );
      return false;
    }

    safeEmit(const ErrandCarStates.submittingRequest());

    final available = _fleet.where((c) => c.status == 'available').toList();
    final assignedCar = available.isNotEmpty ? available.first : null;
    final requestId =
        'ERQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final request = ErrandRequestModel(
      id: requestId,
      employeeName: employeeName.trim(),
      employeeIsl: employeeIsl.trim(),
      department: department.trim(),
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
      assignedDriverName: assignedCar != null ? 'Assigned Driver' : null,
      submittedAt: DateTime.now(),
      approvedAt: assignedCar != null ? DateTime.now() : null,
    );

    final sync = FirestoreSyncService.instance;
    await sync.saveErrandRequest(request);

    // Mark car as in_use if assigned
    if (assignedCar != null) {
      final updatedCar = assignedCar.copyWith(status: 'in_use');
      final carIdx = _fleet.indexWhere((c) => c.id == assignedCar.id);
      if (carIdx != -1) {
        _fleet[carIdx] = updatedCar;
      }
      await sync.saveErrandCar(updatedCar);
    }

    _requests.insert(0, request);

    // If approved, create a dispatch pass
    if (assignedCar != null) {
      final missionCode =
          'CPT-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
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
      safeEmit(
        const ErrandCarStates.success(
          'Request submitted. Awaiting vehicle availability and supervisor approval.',
        ),
      );
    }

    safeEmit(const ErrandCarStates.loaded());
    return true;
  }

  /// Cancels a pending request and updates Firestore.
  Future<bool> cancelRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      safeEmit(const ErrandCarStates.error(message: 'Request not found'));
      return false;
    }

    final request = _requests[index];
    if (request.status != 'pending' && request.status != 'approved') {
      safeEmit(
        const ErrandCarStates.error(
          message: 'Only pending or approved requests can be cancelled',
        ),
      );
      return false;
    }

    safeEmit(const ErrandCarStates.cancellingRequest());

    final sync = FirestoreSyncService.instance;

    // Free the assigned car if any
    if (request.assignedCarId != null) {
      final carIndex = _fleet.indexWhere((c) => c.id == request.assignedCarId);
      if (carIndex != -1) {
        final freedCar = _fleet[carIndex].copyWith(status: 'available');
        _fleet[carIndex] = freedCar;
        await sync.saveErrandCar(freedCar);
      }
    }

    final updatedRequest = request.copyWith(status: 'cancelled');
    _requests[index] = updatedRequest;
    await sync.saveErrandRequest(updatedRequest);

    if (_activePass?.requestId == requestId) {
      _activePass = null;
    }

    safeEmit(
      const ErrandCarStates.success('Errand request cancelled successfully'),
    );
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

    final requestIndex = _requests.indexWhere(
      (r) => r.id == _activePass!.requestId,
    );
    if (requestIndex != -1) {
      final updatedReq = _requests[requestIndex].copyWith(
        status: 'in_progress',
      );
      _requests[requestIndex] = updatedReq;
      await FirestoreSyncService.instance.saveErrandRequest(updatedReq);
    }

    _activePass = _activePass!.copyWith(status: 'in_progress');

    safeEmit(const ErrandCarStates.success('Mission started! Drive safely.'));
    safeEmit(const ErrandCarStates.loaded());
  }

  /// Ends an active mission — records return mileage, updates Firestore, and frees the car.
  Future<void> endMission(String passId, int endMileage) async {
    if (_activePass == null || _activePass!.id != passId) {
      safeEmit(const ErrandCarStates.error(message: 'Dispatch pass not found'));
      return;
    }

    if (_activePass!.startMileage != null &&
        endMileage < _activePass!.startMileage!) {
      safeEmit(
        const ErrandCarStates.error(
          message: 'Return mileage cannot be less than departure mileage',
        ),
      );
      return;
    }

    safeEmit(const ErrandCarStates.endingMission());

    _activePass = _activePass!.copyWith(
      status: 'completed',
      endMileage: endMileage,
    );

    final sync = FirestoreSyncService.instance;

    // Update request status in Firestore
    final requestIndex = _requests.indexWhere(
      (r) => r.id == _activePass!.requestId,
    );
    if (requestIndex != -1) {
      final updatedReq = _requests[requestIndex].copyWith(status: 'completed');
      _requests[requestIndex] = updatedReq;
      await sync.saveErrandRequest(updatedReq);
    }

    // Free the car and update mileage in Firestore
    final requestCarId = requestIndex != -1
        ? _requests[requestIndex].assignedCarId
        : null;
    if (requestCarId != null) {
      final carIndex = _fleet.indexWhere((c) => c.id == requestCarId);
      if (carIndex != -1) {
        final updatedCar = _fleet[carIndex].copyWith(
          status: 'available',
          currentMileage: endMileage,
        );
        _fleet[carIndex] = updatedCar;
        await sync.saveErrandCar(updatedCar);
      }
    }

    final distance = _activePass!.distanceDriven ?? 0;
    safeEmit(
      ErrandCarStates.success(
        'Mission completed! Total distance: $distance km',
      ),
    );

    _activePass = null;
    safeEmit(const ErrandCarStates.loaded());
  }
}
