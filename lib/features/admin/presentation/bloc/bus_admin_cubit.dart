import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/bus_admin_states.dart';

/// Admin: manage bus routes, subscribers, trips, and riders.
///
/// Phase 0: skeleton only.
class BusAdminCubit extends Cubit<BusAdminStates> {
  BusAdminCubit() : super(const BusAdminStates.initial());

  Future<void> loadData() async {
    safeEmit(const BusAdminStates.loading());
    // TODO: Phase 6
  }

  Future<void> startTrip(String busId) async {
    safeEmit(const BusAdminStates.startingTrip());
    // TODO: Phase 6
  }

  Future<void> removeSubscriber(String subId) async {
    safeEmit(const BusAdminStates.removingSubscriber());
    // TODO: Phase 6
  }

  // close() will be overridden in Phase 6 when subscriptions are added.
}
