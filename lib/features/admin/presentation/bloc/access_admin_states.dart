import 'package:freezed_annotation/freezed_annotation.dart';

part 'access_admin_states.freezed.dart';

@freezed
class AccessAdminStates<T> with _$AccessAdminStates<T> {
  const factory AccessAdminStates.initial() = _Initial;

  const factory AccessAdminStates.loading() = Loading;

  /// Generating a new invite code.
  const factory AccessAdminStates.generatingCode() = GeneratingCode;

  const factory AccessAdminStates.loaded() = Loaded;

  const factory AccessAdminStates.empty() = Empty;

  const factory AccessAdminStates.success(T data) = Success<T>;

  const factory AccessAdminStates.error({required String message}) = Error;
}
