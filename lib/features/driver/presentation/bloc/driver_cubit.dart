import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/driver/presentation/bloc/driver_states.dart';

/// Manages driver registration, assignment polling, and trip control.
///
/// Phase 0: skeleton only — no real logic yet.
class DriverCubit extends Cubit<DriverStates> {
  DriverCubit() : super(const DriverStates.initial());

  Future<void> register(/* registration data */) async {
    safeEmit(const DriverStates.registering());
    // TODO: Phase 5
  }

  Future<void> startTrip() async {
    safeEmit(const DriverStates.startingTrip());
    // TODO: Phase 5
  }
}
