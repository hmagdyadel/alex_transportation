import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';

/// Vertical stepper / timeline of stops along an AlexBank bus route.
class BusStopTimeline extends StatelessWidget {
  final List<BusStopModel> stops;
  final String? selectedStopId;
  final ValueChanged<BusStopModel>? onStopSelected;

  const BusStopTimeline({
    super.key,
    required this.stops,
    this.selectedStopId,
    this.onStopSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(stops.length, (index) {
        final stop = stops[index];
        final isFirst = index == 0;
        final isLast = index == stops.length - 1;
        final isSelected = selectedStopId == stop.id;

        return InkWell(
          onTap: onStopSelected != null ? () => onStopSelected!(stop) : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: isSelected
                ? BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.primaryLight),
                  )
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Connector & Node Icon
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 2,
                        height: 12,
                        color: isFirst
                            ? Colors.transparent
                            : (stop.isCompleted
                                ? AppColors.primaryLight
                                : AppColors.border),
                      ),
                      _buildNodeIndicator(stop),
                      Container(
                        width: 2,
                        height: 24,
                        color: isLast
                            ? Colors.transparent
                            : (stop.isCompleted
                                ? AppColors.primaryLight
                                : AppColors.border),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Stop Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                stop.name,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: stop.isCurrent || isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: stop.isCompleted
                                      ? AppColors.textMid
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              stop.scheduledTime,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: stop.isCurrent
                                    ? AppColors.accentGold
                                    : AppColors.textMid,
                              ),
                            ),
                          ],
                        ),
                        if (stop.nameAr != null)
                          Text(
                            stop.nameAr!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        if (stop.isSkipped) ...[
                          const SizedBox(height: 4),
                          const StatusPill(
                            label: 'SKIPPED (0 RIDERS)',
                            type: StatusPillType.neutral,
                          ),
                        ] else if (stop.isCurrent) ...[
                          const SizedBox(height: 4),
                          const StatusPill(
                            label: 'BUS CURRENTLY HERE',
                            type: StatusPillType.gold,
                          ),
                        ] else if (stop.riderCount > 0 && !stop.isCompleted) ...[
                          const SizedBox(height: 4),
                          StatusPill(
                            label: '${stop.riderCount} RIDERS BOOKED',
                            type: StatusPillType.active,
                          ),
                        ] else if (stop.latitude != null && !stop.isCompleted) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.near_me_rounded,
                                size: 11,
                                color: AppColors.primaryLight,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'GPS Geofence: ${stop.radiusMeters.round()}m',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10,
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNodeIndicator(BusStopModel stop) {
    if (stop.isSkipped) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.5), width: 1.5),
        ),
        child: const Icon(
          Icons.redo_rounded,
          size: 10,
          color: AppColors.textSecondary,
        ),
      );
    }

    if (stop.isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.accentGold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGold.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.directions_bus_rounded,
          size: 14,
          color: Colors.white,
        ),
      );
    }

    if (stop.isCompleted) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 12,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 2),
      ),
    );
  }
}
