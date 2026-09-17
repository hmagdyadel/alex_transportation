import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_admin_states.freezed.dart';

@freezed
class DriverAdminStates<T> with _$DriverAdminStates<T> {
  const factory DriverAdminStates.initial() = _Initial;

  const factory DriverAdminStates.loading() = Loading;

  /// Assigning a driver to a bus or car.
  const factory DriverAdminStates.assigning() = Assigning;

  const factory DriverAdminStates.loaded() = Loaded;

  const factory DriverAdminStates.empty() = Empty;

  const factory DriverAdminStates.success(T data) = Success<T>;

  const factory DriverAdminStates.error({required String message}) = Error;
}
