import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/garage/data/models/garage_subscription_model.dart';

/// Digital parking pass displaying employee bay assignment, live check-in state,
/// and check-in/out button.
class GaragePassCard extends StatelessWidget {
  final GarageSubscriptionModel subscription;
  final VoidCallback onCheckInOut;
  final bool isLoading;

  const GaragePassCard({
    super.key,
    required this.subscription,
    required this.onCheckInOut,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = subscription.checkedIn;
    final slotLabel = subscription.slotLabel ?? 'Pending Slot';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with AlexBank branding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const AlexLogo(size: 22),
                  const SizedBox(width: AppSpacing.xs),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIGITAL PARKING PASS',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        subscription.name,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              StatusPill(
                label: isCheckedIn ? 'CHECKED IN' : 'CHECKED OUT',
                type: isCheckedIn ? StatusPillType.active : StatusPillType.neutral,
                icon: Icon(
                  isCheckedIn ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 14,
                  color: isCheckedIn ? AppColors.primaryMid : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Bay Assignment & Details Box
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCheckedIn
                    ? [
                        AppColors.greenLight,
                        AppColors.surface,
                      ]
                    : [
                        AppColors.background,
                        AppColors.surface,
                      ],
              ),
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: isCheckedIn
                    ? AppColors.primaryLight.withValues(alpha: 0.4)
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isCheckedIn ? AppColors.primary : AppColors.primaryMid,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_parking_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASSIGNED BAY',
                          style: AppTypography.caption.copyWith(
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          slotLabel,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn('LEVEL', 'Basement 2'),
                    _buildInfoColumn('ISL', subscription.isl),
                    _buildInfoColumn('TIER', 'Executive'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Live Parking Status Banner
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isCheckedIn ? AppColors.greenLight : AppColors.goldLight,
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: isCheckedIn
                    ? AppColors.primaryLight.withValues(alpha: 0.3)
                    : AppColors.accentGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCheckedIn
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: isCheckedIn ? AppColors.primary : AppColors.accentGold,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCheckedIn
                            ? 'Vehicle currently parked in bay'
                            : 'Bay available — Ready for parking',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isCheckedIn ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (isCheckedIn && subscription.checkedInAt != null)
                        Text(
                          'Checked in at ${_formatTime(subscription.checkedInAt!)}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMid,
                            fontSize: 10,
                          ),
                        )
                      else if (!isCheckedIn)
                        Text(
                          'Tap below to check in when you park',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMid,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Toggle Action Button (Check in / Check out)
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

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
