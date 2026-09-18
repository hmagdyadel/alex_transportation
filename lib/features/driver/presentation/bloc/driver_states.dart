import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_states.freezed.dart';

@freezed
class DriverStates<T> with _$DriverStates<T> {
  const factory DriverStates.initial() = _Initial;

  const factory DriverStates.loading() = Loading;

  /// Registering as a new driver.
  const factory DriverStates.registering() = Registering;

  /// Starting a bus trip.
  const factory DriverStates.startingTrip() = StartingTrip;

  /// Driver moving to or announcing next stop.
  const factory DriverStates.advancingStop() = AdvancingStop;

  /// Boarding / verifying passenger pass.
  const factory DriverStates.boardingPassenger() = BoardingPassenger;

  /// Completing the current route run.
  const factory DriverStates.completingTrip() = CompletingTrip;

  const factory DriverStates.loaded() = Loaded;

  const factory DriverStates.empty() = Empty;

  const factory DriverStates.success(T data) = Success<T>;

  const factory DriverStates.error({required String message}) = Error;
}
