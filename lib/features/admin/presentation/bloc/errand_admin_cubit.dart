import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/errand_admin_states.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_request_model.dart';

/// Admin: manage errand car requests backed directly by Cloud Firestore.
class ErrandAdminCubit extends Cubit<ErrandAdminStates> {
  final List<ErrandRequestModel> _requests = [];

  ErrandAdminCubit() : super(const ErrandAdminStates.initial()) {
    loadData();
  }

  List<ErrandRequestModel> get requests => List.unmodifiable(_requests);

  /// Loads pending and active errand car mission requests directly from Firestore.
  Future<void> loadData() async {
    safeEmit(const ErrandAdminStates.loading());

    final sync = FirestoreSyncService.instance;
    final loaded = await sync.getErrandRequests();

    _requests.clear();
    _requests.addAll(loaded);

    safeEmit(const ErrandAdminStates.loaded());
  }

  /// Approves an errand car request and dispatches a vehicle in Firestore.
  Future<void> approveRequest(
    String requestId, {
    String? errandCarId,
    String? driverId,
  }) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      safeEmit(const ErrandAdminStates.error(message: 'Request not found'));
      return;
    }

    safeEmit(const ErrandAdminStates.approving());

    final current = _requests[index];
    final updated = ErrandRequestModel(
      id: current.id,
      employeeName: current.employeeName,
      employeeIsl: current.employeeIsl,
      department: current.department,
      pickupLocation: current.pickupLocation,
      destination: current.destination,
      purpose: current.purpose,
      requestedDate: current.requestedDate,
      requestedTime: current.requestedTime,
      estimatedReturnTime: current.estimatedReturnTime,
      supervisorName: current.supervisorName,
      status: 'approved',
      assignedCarId: errandCarId ?? 'CAR-001',
      assignedCarPlate: 'أ ب ج 4567',
      assignedCarMake: 'Mercedes-Benz E-Class',
      assignedDriverName: driverId != null
          ? 'Captain $driverId'
          : 'Captain Tarek',
      submittedAt: current.submittedAt,
      approvedAt: DateTime.now(),
    );

    _requests[index] = updated;
    await FirestoreSyncService.instance.saveErrandRequest(updated);

    safeEmit(ErrandAdminStates.success('Request $requestId approved'));
    safeEmit(const ErrandAdminStates.loaded());
  }

  /// Rejects an errand car request and updates Firestore.
  Future<void> rejectRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      safeEmit(const ErrandAdminStates.error(message: 'Request not found'));
      return;
    }

    safeEmit(const ErrandAdminStates.rejecting());

    final current = _requests[index];
    final updated = ErrandRequestModel(
      id: current.id,
      employeeName: current.employeeName,
      employeeIsl: current.employeeIsl,
      department: current.department,
      pickupLocation: current.pickupLocation,
      destination: current.destination,
      purpose: current.purpose,
      requestedDate: current.requestedDate,
      requestedTime: current.requestedTime,
      estimatedReturnTime: current.estimatedReturnTime,
      supervisorName: current.supervisorName,
      status: 'rejected',
      submittedAt: current.submittedAt,
    );

    _requests[index] = updated;
    await FirestoreSyncService.instance.saveErrandRequest(updated);

    safeEmit(ErrandAdminStates.success('Request $requestId rejected'));
    safeEmit(const ErrandAdminStates.loaded());
  }
}
