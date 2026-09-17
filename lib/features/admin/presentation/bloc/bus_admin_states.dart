import 'package:freezed_annotation/freezed_annotation.dart';

part 'bus_admin_states.freezed.dart';

@freezed
class BusAdminStates<T> with _$BusAdminStates<T> {
  const factory BusAdminStates.initial() = _Initial;

  const factory BusAdminStates.loading() = Loading;

  /// Starting a bus trip from admin.
  const factory BusAdminStates.startingTrip() = StartingTrip;

  /// Removing a bus subscriber.
  const factory BusAdminStates.removingSubscriber() = RemovingSubscriber;

  const factory BusAdminStates.loaded() = Loaded;

  const factory BusAdminStates.empty() = Empty;

  const factory BusAdminStates.success(T data) = Success<T>;

  const factory BusAdminStates.error({required String message}) = Error;
}
