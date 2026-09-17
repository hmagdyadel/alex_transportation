import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_states.freezed.dart';

@freezed
class DriverStates<T> with _$DriverStates<T> {
  const factory DriverStates.initial() = _Initial;

  const factory DriverStates.loading() = Loading;

  /// Registering as a new driver.
  const factory DriverStates.registering() = Registering;

  /// Starting a bus trip (triggers location stream).
  const factory DriverStates.startingTrip() = StartingTrip;

  const factory DriverStates.loaded() = Loaded;

  const factory DriverStates.empty() = Empty;

  const factory DriverStates.success(T data) = Success<T>;

  const factory DriverStates.error({required String message}) = Error;
}
