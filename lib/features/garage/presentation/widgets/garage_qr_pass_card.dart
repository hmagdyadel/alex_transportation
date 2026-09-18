import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/garage/data/models/garage_subscription_model.dart';

/// Digital parking pass displaying employee bay assignment, live check-in state,
/// and scanner QR code.
class GarageQrPassCard extends StatelessWidget {
  final GarageSubscriptionModel subscription;
  final VoidCallback onCheckInOut;
  final bool isLoading;

  const GarageQrPassCard({
    super.key,
    required this.subscription,
    required this.onCheckInOut,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = subscription.checkedIn;
    final slotLabel = subscription.slotLabel ?? 'Pending Slot';
    final qrData = 'ALEXBANK:GARAGE:${subscription.id}:ISL${subscription.isl}:$slotLabel';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DIGITAL PARKING PASS',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subscription.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              StatusPill(
                label: isCheckedIn ? 'CHECKED IN' : 'CHECKED OUT',
                type: isCheckedIn ? StatusPillType.active : StatusPillType.neutral,
                icon: Icon(
                  isCheckedIn ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 14,
                  color: isCheckedIn ? AppColors.primaryMid : AppColors.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Bay Assignment Chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_parking_rounded,
                      color: AppColors.primaryMid,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Assigned Bay',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  slotLabel,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // QR Code Scanner Box
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.borderLg,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 180,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Use button below to check in / out at barrier gate',
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Timestamp Info
          if (isCheckedIn && subscription.checkedInAt != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'Checked in since ${_formatTime(subscription.checkedInAt!)}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),

          // Toggle Action Button
          AppButton(
            label: isCheckedIn ? 'Check Out of Garage' : 'Check In to Bay',
            variant: isCheckedIn ? AppButtonVariant.secondary : AppButtonVariant.primary,
            onPressed: isLoading ? null : onCheckInOut,
            leadingIcon: Icon(
              isCheckedIn ? Icons.logout_rounded : Icons.login_rounded,
              size: 20,
              color: isCheckedIn ? AppColors.primary : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
