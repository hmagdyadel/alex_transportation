import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/buses/data/models/bus_boarding_pass_model.dart';

/// Digital bus boarding pass card with seat assignment, pickup stop, and boarding actions.
class BusBoardingPassCard extends StatelessWidget {
  final BusBoardingPassModel pass;
  final VoidCallback? onCheckIn;
  final VoidCallback? onCancel;

  const BusBoardingPassCard({
    super.key,
    required this.pass,
    this.onCheckIn,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBoarded = pass.status == 'boarded';

    return AppCard(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Banner
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_bus_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      pass.routeNumber,
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                StatusPill(
                  label: isBoarded
                      ? l10n.busBoardedAction.toUpperCase()
                      : l10n.confirmed.toUpperCase(),
                  type: isBoarded ? StatusPillType.neutral : StatusPillType.active,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Route title & seat badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pass.routeName,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pass.busNumber,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.busSeatLabel.toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Free',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Pickup Stop & Time Grid
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.busPickupStopLabel.toUpperCase(),
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 9,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    pass.stopName,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 1,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 20,
                            color: AppColors.accentGold,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.busDepartureTimeLabel.toUpperCase(),
                                style: AppTypography.caption.copyWith(
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                pass.departureTime,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Boarding Status & Verification Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isBoarded ? AppColors.greenLight : AppColors.goldLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isBoarded
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : AppColors.accentGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: (isBoarded ? AppColors.primary : AppColors.accentGold)
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isBoarded
                              ? Icons.check_circle_rounded
                              : Icons.airline_seat_recline_normal_rounded,
                          color: isBoarded ? AppColors.primary : AppColors.accentGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBoarded
                                  ? l10n.busBoardedAction
                                  : l10n.busActivePassHeader,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isBoarded
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${pass.routeNumber} — ${pass.routeName}',
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

                const SizedBox(height: AppSpacing.md),

                // Action Buttons
                Row(
                  children: [
                    if (!isBoarded && onCheckIn != null)
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.directions_bus_rounded, size: 18),
                          label: Text(l10n.busBoardAction),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          onPressed: onCheckIn,
                        ),
                      ),
                    if (!isBoarded && onCancel != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          onPressed: onCancel,
                          child: Text(l10n.cancel),
                        ),
                      ),
                    ],
                    if (isBoarded)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.primaryLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryLight,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.busBoardedAction,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
