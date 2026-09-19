import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/notifications/data/models/notification_model.dart';
import 'package:alex_transportation/features/notifications/presentation/bloc/notification_states.dart';

class NotificationCubit extends Cubit<NotificationStates> {
  NotificationCubit() : super(const NotificationStates.initial()) {
    loadNotifications();
  }

  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    safeEmit(const NotificationStates.loading());

    if (_notifications.isEmpty) {
      _notifications.addAll([
        NotificationModel(
          id: 'notif-1',
          title: '⚡ Route Optimization Active',
          body: 'Morning Line 101 starts directly at Stop 6 (Maadi Grand Mall) today due to 0 bookings on preceding stops.',
          type: NotificationType.bus,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          isRead: false,
        ),
        NotificationModel(
          id: 'notif-2',
          title: '🅿️ Parking Bay Confirmed',
          body: 'Your executive parking pass is active at Corporate Garage (Bay A-14).',
          type: NotificationType.garage,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
        NotificationModel(
          id: 'notif-3',
          title: '🚗 Errand Mission Approved',
          body: 'Your corporate errand vehicle request has been authorized by fleet administration.',
          type: NotificationType.errand,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: true,
        ),
        NotificationModel(
          id: 'notif-4',
          title: '🛡️ AlexBank Security Notice',
          body: 'Biometric Face ID authentication enabled for one-touch mobility access.',
          type: NotificationType.system,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
      ]);
    }

    if (_notifications.isEmpty) {
      safeEmit(const NotificationStates.empty());
    } else {
      safeEmit(const NotificationStates.loaded());
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    safeEmit(const NotificationStates.loaded());
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      safeEmit(const NotificationStates.loaded());
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    safeEmit(const NotificationStates.loaded());
  }

  void clearAll() {
    _notifications.clear();
    safeEmit(const NotificationStates.empty());
  }
}
