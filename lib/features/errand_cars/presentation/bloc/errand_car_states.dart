import 'package:freezed_annotation/freezed_annotation.dart';

part 'errand_car_states.freezed.dart';

@freezed
class ErrandCarStates<T> with _$ErrandCarStates<T> {
  const factory ErrandCarStates.initial() = _Initial;

  const factory ErrandCarStates.loading() = Loading;

  /// Submitting a new errand car request.
  const factory ErrandCarStates.submittingRequest() = SubmittingRequest;

  /// Cancelling a pending request.
  const factory ErrandCarStates.cancellingRequest() = CancellingRequest;

  /// Starting an approved mission (recording departure mileage).
  const factory ErrandCarStates.startingMission() = StartingMission;

  /// Ending an active mission (recording return mileage).
  const factory ErrandCarStates.endingMission() = EndingMission;

  const factory ErrandCarStates.loaded() = Loaded;

  const factory ErrandCarStates.empty() = Empty;

  const factory ErrandCarStates.success(T data) = Success<T>;

  const factory ErrandCarStates.error({required String message}) = Error;
}
