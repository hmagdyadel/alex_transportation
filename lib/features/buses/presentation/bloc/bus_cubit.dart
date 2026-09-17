import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_states.dart';

/// Manages bus route subscription, daily check-in, and live tracking.
///
/// Phase 0: skeleton only — no real logic yet.
class BusCubit extends Cubit<BusStates> {
  BusCubit() : super(const BusStates.initial());

  Future<void> loadBuses() async {
    safeEmit(const BusStates.loading());
    // TODO: Phase 3
  }

  Future<void> subscribeToRoute(/* route + stop data */) async {
    safeEmit(const BusStates.subscribingToRoute());
    // TODO: Phase 3
  }

  Future<void> checkInForToday() async {
    safeEmit(const BusStates.checkingInToday());
    // TODO: Phase 3
  }
}
