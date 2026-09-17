import 'package:freezed_annotation/freezed_annotation.dart';

part 'garage_admin_states.freezed.dart';

@freezed
class GarageAdminStates<T> with _$GarageAdminStates<T> {
  const factory GarageAdminStates.initial() = _Initial;

  const factory GarageAdminStates.loading() = Loading;

  /// Approving a waitlist application.
  const factory GarageAdminStates.approving() = Approving;

  /// Rejecting a waitlist application.
  const factory GarageAdminStates.rejecting() = Rejecting;

  /// Running the monthly deduction batch.
  const factory GarageAdminStates.runningDeduction() = RunningDeduction;

  /// Approving a cancellation request.
  const factory GarageAdminStates.approvingCancellation() =
      ApprovingCancellation;

  /// Rejecting a cancellation request.
  const factory GarageAdminStates.rejectingCancellation() =
      RejectingCancellation;

  const factory GarageAdminStates.loaded() = Loaded;

  const factory GarageAdminStates.empty() = Empty;

  const factory GarageAdminStates.success(T data) = Success<T>;

  const factory GarageAdminStates.error({required String message}) = Error;
}
