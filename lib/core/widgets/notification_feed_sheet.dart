import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/services/push_notification_service.dart';
import 'package:alex_transportation/features/notifications/data/models/notification_model.dart';
import 'package:alex_transportation/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:alex_transportation/features/notifications/presentation/bloc/notification_states.dart';

/// Interactive modal sheet displaying in-app notifications and real-time transit alerts.
class NotificationFeedSheet extends StatelessWidget {
  const NotificationFeedSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationFeedSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationCubit>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppRadius.borderPill,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Notifications',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                BlocBuilder<NotificationCubit, NotificationStates>(
                  builder: (context, _) {
                    final unread = cubit.unreadCount;
                    if (unread == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.borderPill,
                      ),
                      child: Text(
                        '$unread new',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    cubit.markAllAsRead();
                  },
                  child: Text(
                    'Mark all read',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Quick Simulation Actions
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            color: AppColors.background,
            child: Row(
              children: [
                Text(
                  'Quick Demo Alert:',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _DemoChip(
                  label: '🚌 Bus',
                  onTap: () {
                    PushNotificationService.instance.demoBusArrival();
                    cubit.addNotification(
                      NotificationModel(
                        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                        title: '🚌 Bus Approaching',
                        body: 'Route 101 is 5 minutes away from your pickup stop.',
                        type: NotificationType.bus,
                        timestamp: DateTime.now(),
                        isRead: false,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                _DemoChip(
                  label: '🚗 Errand',
                  onTap: () {
                    PushNotificationService.instance.demoErrandApproval();
                    cubit.addNotification(
                      NotificationModel(
                        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                        title: '🚗 Errand Approved',
                        body: 'Your vehicle request has been authorized by fleet admin.',
                        type: NotificationType.errand,
                        timestamp: DateTime.now(),
                        isRead: false,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                _DemoChip(
                  label: '🅿️ Garage',
                  onTap: () {
                    PushNotificationService.instance.demoGarageConfirmed();
                    cubit.addNotification(
                      NotificationModel(
                        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
                        title: '🅿️ Parking Bay Confirmed',
                        body: 'Your parking pass has been verified.',
                        type: NotificationType.garage,
                        timestamp: DateTime.now(),
                        isRead: false,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Notification List
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationStates>(
              builder: (context, state) {
                final list = cubit.notifications;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No Notifications Yet',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Transit alerts and mission updates will appear here.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final notif = list[index];
                    return _NotificationTile(
                      notification: notif,
                      onTap: () => cubit.markAsRead(notif.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DemoChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.bus:
        return Icons.directions_bus_rounded;
      case NotificationType.garage:
        return Icons.local_parking_rounded;
      case NotificationType.errand:
        return Icons.drive_eta_rounded;
      case NotificationType.system:
        return Icons.security_rounded;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.bus:
        return AppColors.accentBlue;
      case NotificationType.garage:
        return AppColors.primary;
      case NotificationType.errand:
        return AppColors.accentGold;
      case NotificationType.system:
        return AppColors.primaryLight;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread ? AppColors.greenLight.withValues(alpha: 0.3) : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _colorForType(notification.type).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(notification.type),
                size: 20,
                color: _colorForType(notification.type),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.timestamp),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTypography.bodySmall.copyWith(
                      color: isUnread
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
