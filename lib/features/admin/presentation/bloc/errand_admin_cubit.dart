import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/errand_admin_states.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_request_model.dart';

/// Admin: manage errand car requests (approve/reject).
class ErrandAdminCubit extends Cubit<ErrandAdminStates> {
  final List<ErrandRequestModel> _requests = [];

  ErrandAdminCubit() : super(const ErrandAdminStates.initial()) {
    loadData();
  }

  List<ErrandRequestModel> get requests => List.unmodifiable(_requests);

  /// Loads pending and active errand car mission requests.
  Future<void> loadData() async {
    safeEmit(const ErrandAdminStates.loading());
    await Future.delayed(const Duration(milliseconds: 200));

    if (_requests.isEmpty) {
      _requests.addAll([
        ErrandRequestModel(
          id: 'REQ-101',
          employeeName: 'Eng. Karim El-Sayed',
          employeeIsl: '4920',
          department: 'IT Infrastructure',
          pickupLocation: 'Smart Village (AlexBank HQ)',
          destination: 'AlexBank Downtown Cairo Branch',
          purpose: 'Core Network Server Hardware Maintenance',
          requestedDate: '2026-09-18',
          requestedTime: '10:00 AM',
          estimatedReturnTime: '02:00 PM',
          supervisorName: 'Tamer Shawky',
          status: 'pending',
          submittedAt: DateTime(2026, 9, 18, 9, 15),
        ),
        ErrandRequestModel(
          id: 'REQ-102',
          employeeName: 'Mona Abdel-Aziz',
          employeeIsl: '3811',
          department: 'Corporate Audit',
          pickupLocation: 'Smart Village (AlexBank HQ)',
          destination: 'Central Bank of Egypt (CBE HQ)',
          purpose: 'Quarterly Regulatory Audit Submission',
          requestedDate: '2026-09-18',
          requestedTime: '11:30 AM',
          estimatedReturnTime: '03:30 PM',
          supervisorName: 'Hazem Refaat',
          status: 'pending',
          submittedAt: DateTime(2026, 9, 18, 10, 0),
        ),
      ]);
    }

    safeEmit(const ErrandAdminStates.loaded());
  }

  /// Approves an errand car request and dispatches a vehicle.
  Future<void> approveRequest(String requestId) async {
    safeEmit(const ErrandAdminStates.approving());
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: 'approved',
        approvedAt: DateTime.now(),
        assignedDriverName: 'Chauffeur Khaled Nasser',
        assignedCarMake: 'Mercedes-Benz E-Class',
        assignedCarPlate: 'أ ب ج 4567',
      );
    }

    safeEmit(ErrandAdminStates.success('Errand mission request $requestId approved'));
    safeEmit(const ErrandAdminStates.loaded());
  }

  /// Rejects an errand car request.
  Future<void> rejectRequest(String requestId) async {
    safeEmit(const ErrandAdminStates.rejecting());
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: 'rejected');
    }

    safeEmit(ErrandAdminStates.success('Errand mission request $requestId rejected'));
    safeEmit(const ErrandAdminStates.loaded());
  }
}
