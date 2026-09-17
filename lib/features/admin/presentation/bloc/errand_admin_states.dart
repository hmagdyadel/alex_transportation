import 'package:freezed_annotation/freezed_annotation.dart';

part 'errand_admin_states.freezed.dart';

@freezed
class ErrandAdminStates<T> with _$ErrandAdminStates<T> {
  const factory ErrandAdminStates.initial() = _Initial;

  const factory ErrandAdminStates.loading() = Loading;

  /// Approving an errand car request.
  const factory ErrandAdminStates.approving() = Approving;

  /// Rejecting an errand car request.
  const factory ErrandAdminStates.rejecting() = Rejecting;

  const factory ErrandAdminStates.loaded() = Loaded;

  const factory ErrandAdminStates.empty() = Empty;

  const factory ErrandAdminStates.success(T data) = Success<T>;

  const factory ErrandAdminStates.error({required String message}) = Error;
}
