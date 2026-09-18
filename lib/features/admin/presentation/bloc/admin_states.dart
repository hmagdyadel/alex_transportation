import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_states.freezed.dart';

@freezed
class AdminStates<T> with _$AdminStates<T> {
  const factory AdminStates.initial() = _Initial;

  const factory AdminStates.loading() = Loading;

  const factory AdminStates.loaded() = Loaded;

  const factory AdminStates.generatingCode() = GeneratingCode;

  const factory AdminStates.approving() = Approving;

  const factory AdminStates.rejecting() = Rejecting;

  const factory AdminStates.success(T data) = Success<T>;

  const factory AdminStates.error({required String message}) = Error;
}
