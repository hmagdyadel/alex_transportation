import 'package:freezed_annotation/freezed_annotation.dart';

part 'garage_states.freezed.dart';

@freezed
class GarageStates<T> with _$GarageStates<T> {
  const factory GarageStates.initial() = _Initial;

  const factory GarageStates.loading() = Loading;

  /// Submitting a new parking subscription request.
  const factory GarageStates.submittingSubscription() = SubmittingSubscription;

  /// Checking in or out of the garage.
  const factory GarageStates.checkingInOut() = CheckingInOut;

  /// Submitting a cancellation request.
  const factory GarageStates.cancelling() = Cancelling;

  const factory GarageStates.loaded() = Loaded;

  const factory GarageStates.empty() = Empty;

  const factory GarageStates.success(T data) = Success<T>;

  const factory GarageStates.error({required String message}) = Error;
}
