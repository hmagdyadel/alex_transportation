import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_states.dart';

/// Manages garage parking subscription, check-in/out, and cancellation.
///
/// Phase 0: skeleton only — no real logic yet.
/// Data is owned as private fields on the Cubit, exposed via getters.
class GarageCubit extends Cubit<GarageStates> {
  GarageCubit() : super(const GarageStates.initial());

  // TODO: Phase 2 — add private data fields (subscribed list, waiting list, etc.)
  // and expose via getters.

  Future<void> loadGarageData() async {
    safeEmit(const GarageStates.loading());
    // TODO: Phase 2
  }

  Future<void> submitSubscription(/* form data */) async {
    safeEmit(const GarageStates.submittingSubscription());
    // TODO: Phase 2
  }

  Future<void> checkInOut() async {
    safeEmit(const GarageStates.checkingInOut());
    // TODO: Phase 2
  }

  Future<void> requestCancellation(/* form data */) async {
    safeEmit(const GarageStates.cancelling());
    // TODO: Phase 2
  }
}
