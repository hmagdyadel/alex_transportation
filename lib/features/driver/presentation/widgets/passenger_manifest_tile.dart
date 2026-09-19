import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/features/driver/data/models/trip_manifest_item_model.dart';

/// Passenger manifest card for the driver's passenger roster with 1-tap check-in.
class PassengerManifestTile extends StatelessWidget {
  final TripManifestItemModel passenger;
  final VoidCallback onToggleBoarding;

  const PassengerManifestTile({
    super.key,
    required this.passenger,
    required this.onToggleBoarding,
  });

  @override
  Widget build(BuildContext context) {
    final isBoarded = passenger.isBoarded;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      backgroundColor: isBoarded ? AppColors.greenLight : AppColors.surface,
      borderSide: BorderSide(
        color: isBoarded
            ? AppColors.primaryLight.withValues(alpha: 0.4)
            : AppColors.border,
      ),
      child: Row(
        children: [
          // Passenger Icon Badge
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isBoarded ? AppColors.primary : AppColors.goldLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isBoarded
                    ? AppColors.primary
                    : AppColors.accentGold.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              Icons.airline_seat_recline_normal_rounded,
              color: isBoarded ? Colors.white : AppColors.accentGold,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Passenger Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        passenger.employeeName,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'ISL: ${passenger.employeeIsl}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  passenger.department,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMid,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 12,
                      color: AppColors.primaryMid,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        passenger.pickupStop,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.primaryMid,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Action Button / Boarding Checkmark
          InkWell(
            onTap: onToggleBoarding,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isBoarded ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isBoarded ? AppColors.primary : AppColors.primaryLight,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isBoarded
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isBoarded ? Colors.white : AppColors.primaryLight,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isBoarded
                        ? context.l10n.driverBoardedBadge
                        : context.l10n.driverBoardButton,
                    style: AppTypography.caption.copyWith(
                      color: isBoarded ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
