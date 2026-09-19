import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/features/driver/data/models/driver_trip_model.dart';

/// Active Trip HUD Card showing route details, live stop status,
/// GPS geofencing telemetry, and primary trip progression controls.
class DriverTripHudCard extends StatelessWidget {
  final DriverTripModel trip;
  final VoidCallback? onStartTrip;
  final VoidCallback? onAdvanceStop;
  final VoidCallback? onCompleteTrip;
  final bool isAutoGeofenceEnabled;
  final VoidCallback? onToggleAutoGeofence;
  final String? distanceToNextStop;
  final bool isGpsActive;
  final VoidCallback? onSimulateGpsArrival;

  const DriverTripHudCard({
    super.key,
    required this.trip,
    this.onStartTrip,
    this.onAdvanceStop,
    this.onCompleteTrip,
    this.isAutoGeofenceEnabled = true,
    this.onToggleAutoGeofence,
    this.distanceToNextStop,
    this.isGpsActive = false,
    this.onSimulateGpsArrival,
  });

  @override
  Widget build(BuildContext context) {
    final currentStop = trip.currentStop;
    final isLastStop = trip.isAtLastActiveStop;

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
                        context.l10n.driverRouteNumber(trip.routeNumber),
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
                      ? context.l10n.driverStatusCompleted
                      : trip.isInProgress
                      ? context.l10n.driverStatusInProgress
                      : context.l10n.driverStatusScheduled,
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
                // Route Optimization Notice Banner
                if (trip.isRouteOptimized && currentStop != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.route_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '⚡ Route Optimized: Starts at ${currentStop.name} • ${trip.skippedStopsCount} empty stops skipped',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                                context.l10n.driverPlate(trip.busPlate),
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
                            context.l10n.driverBoardedBadge,
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
                                    context.l10n.driverStopOfTotal(
                                      trip.currentStopIndex + 1,
                                      trip.stops.length,
                                    ),
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
                                      '• ${context.l10n.driverFinalDestination}',
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
                  const SizedBox(height: AppSpacing.sm),

                  // GPS Telemetry & Auto Geofence Pill Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isGpsActive
                          ? AppColors.greenLight
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isGpsActive
                            ? AppColors.primaryLight.withValues(alpha: 0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.satellite_alt_rounded,
                              size: 16,
                              color: isGpsActive
                                  ? AppColors.primaryLight
                                  : AppColors.textMid,
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.gpsTrackingActive,
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    color: isGpsActive
                                        ? AppColors.primary
                                        : AppColors.textMid,
                                  ),
                                ),
                                if (distanceToNextStop != null && !isLastStop)
                                  Text(
                                    context.l10n.gpsDistanceToNextStop(
                                      distanceToNextStop!,
                                    ),
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: onToggleAutoGeofence,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAutoGeofenceEnabled
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isAutoGeofenceEnabled
                                      ? Icons.gps_fixed_rounded
                                      : Icons.gps_off_rounded,
                                  size: 13,
                                  color: isAutoGeofenceEnabled
                                      ? Colors.white
                                      : AppColors.textMid,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isAutoGeofenceEnabled
                                      ? context.l10n.gpsAutoGeofenceOn
                                      : context.l10n.gpsAutoGeofenceOff,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isAutoGeofenceEnabled
                                        ? Colors.white
                                        : AppColors.textMid,
                                  ),
                                ),
                              ],
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
                    label: context.l10n.driverStartTripOpenManifest,
                    leadingIcon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onStartTrip,
                  ),

                if (trip.isInProgress) ...[
                  Row(
                    children: [
                      if (!isLastStop) ...[
                        Expanded(
                          flex: 3,
                          child: AppButton(
                            label: context.l10n.driverArrivedAtNextStop,
                            leadingIcon: const Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: onAdvanceStop,
                          ),
                        ),
                        if (onSimulateGpsArrival != null) ...[
                          const SizedBox(width: AppSpacing.xs),
                          InkWell(
                            onTap: onSimulateGpsArrival,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.goldLight,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: AppColors.accentGold.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.radar_rounded,
                                    size: 16,
                                    color: AppColors.accentGold,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.l10n.gpsSimulateArrival,
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: AppColors.accentGold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                      if (isLastStop)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                            ),
                            label: Text(context.l10n.driverCompleteTripAction),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            onPressed: onCompleteTrip,
                          ),
                        ),
                    ],
                  ),
                ],

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
                          context.l10n.driverRouteCompletedSuccess,
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
