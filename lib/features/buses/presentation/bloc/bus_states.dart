import 'package:freezed_annotation/freezed_annotation.dart';

part 'bus_states.freezed.dart';

@freezed
class BusStates<T> with _$BusStates<T> {
  const factory BusStates.initial() = _Initial;

  const factory BusStates.loading() = Loading;

  /// Subscribing to a bus route + stop.
  const factory BusStates.subscribingToRoute() = SubscribingToRoute;

  /// Booking a seat on a route.
  const factory BusStates.bookingSeat() = BookingSeat;

  /// Cancelling a seat booking.
  const factory BusStates.cancellingBooking() = CancellingBooking;

  /// Checking in for today's ride.
  const factory BusStates.checkingInToday() = CheckingInToday;

  const factory BusStates.loaded() = Loaded;

  const factory BusStates.empty() = Empty;

  const factory BusStates.success(T data) = Success<T>;

  const factory BusStates.error({required String message}) = Error;
}
