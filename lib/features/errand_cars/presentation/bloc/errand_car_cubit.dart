import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_states.dart';

/// Manages errand car browsing, requests, and status tracking.
///
/// Phase 0: skeleton only — no real logic yet.
class ErrandCarCubit extends Cubit<ErrandCarStates> {
  ErrandCarCubit() : super(const ErrandCarStates.initial());

  Future<void> loadCars() async {
    safeEmit(const ErrandCarStates.loading());
    // TODO: Phase 4
  }

  Future<void> submitRequest(/* request data */) async {
    safeEmit(const ErrandCarStates.submittingRequest());
    // TODO: Phase 4
  }
}
