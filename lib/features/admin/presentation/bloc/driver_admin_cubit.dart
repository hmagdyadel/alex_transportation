import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/driver_admin_states.dart';

/// Admin: manage driver registrations and assignments.
///
/// Phase 0: skeleton only.
class DriverAdminCubit extends Cubit<DriverAdminStates> {
  DriverAdminCubit() : super(const DriverAdminStates.initial());

  Future<void> loadData() async {
    safeEmit(const DriverAdminStates.loading());
    // TODO: Phase 6
  }

  Future<void> assignDriver(String driverId, String resourceId) async {
    safeEmit(const DriverAdminStates.assigning());
    // TODO: Phase 6
  }

  // close() will be overridden in Phase 6 when subscriptions are added.
}
