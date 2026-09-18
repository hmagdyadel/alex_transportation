import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/driver/data/models/driver_trip_model.dart';

/// Active Trip HUD Card showing route details, live stop status,
/// and primary trip progression controls.
class DriverTripHudCard extends StatelessWidget {
  final DriverTripModel trip;
  final VoidCallback? onStartTrip;
  final VoidCallback? onAdvanceStop;
  final VoidCallback? onCompleteTrip;

  const DriverTripHudCard({
    super.key,
    required this.trip,
    this.onStartTrip,
    this.onAdvanceStop,
    this.onCompleteTrip,
  });

  @override
  Widget build(BuildContext context) {
    final currentStop = trip.currentStop;
    final isLastStop = trip.currentStopIndex >= trip.stops.length - 1;

    return AppCard(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar with Route # and Shift
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'ROUTE ${trip.routeNumber}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      trip.shift,
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                StatusPill(
                  label: trip.isCompleted
                      ? 'COMPLETED'
                      : trip.isInProgress
                          ? 'IN PROGRESS'
                          : 'SCHEDULED',
                  type: trip.isCompleted
                      ? StatusPillType.neutral
                      : trip.isInProgress
                          ? StatusPillType.active
                          : StatusPillType.gold,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Route Title + Bus Plate
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.routeName,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_bus_filled_rounded,
                                size: 14,
                                color: AppColors.primaryLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Plate: ${trip.busPlate}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMid,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'BOARDED',
                            style: AppTypography.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${trip.boardedCount}/${trip.totalPassengers}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Current Stop Navigator (when in progress)
                if (trip.isInProgress && currentStop != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.navigation_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'STOP ${trip.currentStopIndex + 1} OF ${trip.stops.length}',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryLight,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (isLastStop) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '• FINAL DESTINATION',
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.accentGold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                currentStop.name,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (currentStop.nameAr != null)
                                Text(
                                  currentStop.nameAr!,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldLight,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            currentStop.scheduledTime,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Action Controls
                if (trip.isScheduled)
                  AppButton(
                    label: 'Start Trip & Open Manifest',
                    leadingIcon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    onPressed: onStartTrip,
                  ),

                if (trip.isInProgress)
                  Row(
                    children: [
                      if (!isLastStop)
                        Expanded(
                          child: AppButton(
                            label: 'Arrived at Next Stop',
                            leadingIcon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 20),
                            onPressed: onAdvanceStop,
                          ),
                        ),
                      if (isLastStop)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('Complete Trip'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            onPressed: onCompleteTrip,
                          ),
                        ),
                    ],
                  ),

                if (trip.isCompleted)
                  Container(
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
                          Icons.task_alt_rounded,
                          color: AppColors.primaryLight,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Route Completed Successfully',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
