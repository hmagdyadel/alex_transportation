import 'package:flutter_test/flutter_test.dart';
import 'package:alex_transportation/features/notifications/data/models/notification_model.dart';
import 'package:alex_transportation/features/notifications/presentation/bloc/notification_cubit.dart';

void main() {
  group('NotificationCubit Tests', () {
    late NotificationCubit cubit;

    setUp(() {
      cubit = NotificationCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test(
      'initial load seeds notifications and calculates unread count',
      () async {
        await cubit.loadNotifications();
        expect(cubit.notifications.isNotEmpty, isTrue);
        expect(cubit.unreadCount, greaterThan(0));
      },
    );

    test(
      'markAsRead updates isRead flag and decrements unread count',
      () async {
        await cubit.loadNotifications();
        final initialUnread = cubit.unreadCount;
        final unreadNotif = cubit.notifications.firstWhere((n) => !n.isRead);

        cubit.markAsRead(unreadNotif.id);
        expect(cubit.unreadCount, equals(initialUnread - 1));

        final updated = cubit.notifications.firstWhere(
          (n) => n.id == unreadNotif.id,
        );
        expect(updated.isRead, isTrue);
      },
    );

    test(
      'markAllAsRead marks all items as read and reduces unreadCount to 0',
      () async {
        await cubit.loadNotifications();
        expect(cubit.unreadCount, greaterThan(0));

        cubit.markAllAsRead();
        expect(cubit.unreadCount, equals(0));
      },
    );

    test('addNotification adds item to the top of the feed', () {
      final newNotif = NotificationModel(
        id: 'test-custom-1',
        title: 'Custom Alert',
        body: 'Testing notification addition',
        type: NotificationType.system,
        timestamp: DateTime.now(),
        isRead: false,
      );

      cubit.addNotification(newNotif);
      expect(cubit.notifications.first.id, equals('test-custom-1'));
    });

    test('clearAll clears notifications list and sets unreadCount to 0', () {
      cubit.clearAll();
      expect(cubit.notifications.isEmpty, isTrue);
      expect(cubit.unreadCount, equals(0));
    });
  });
}
