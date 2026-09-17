import 'package:flutter_bloc/flutter_bloc.dart';

/// Guards against the "Cannot emit new states after calling close" crash.
///
/// Every Cubit in this project must call [safeEmit] instead of raw [emit].
/// This is a safety net for async callbacks (stream listeners, Futures, Timers)
/// that resolve after the Cubit has closed.
///
/// **It is NOT a substitute for proper cleanup**: any Cubit that opens a
/// [StreamSubscription] must cancel it in an overridden [close()].
///
/// This extends [Cubit] from `flutter_bloc` (which re-exports `bloc`)
/// so we don't need a direct dependency on the `bloc` package.
extension SafeEmitExtension<State> on Cubit<State> {
  void safeEmit(State state) {
    if (!isClosed) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      emit(state);
    }
  }
}
