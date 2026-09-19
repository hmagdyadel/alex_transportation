import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_states.freezed.dart';

@freezed
class NotificationStates with _$NotificationStates {
  const factory NotificationStates.initial() = _Initial;
  const factory NotificationStates.loading() = Loading;
  const factory NotificationStates.loaded() = Loaded;
  const factory NotificationStates.empty() = Empty;
  const factory NotificationStates.error({required String message}) = Error;
}
