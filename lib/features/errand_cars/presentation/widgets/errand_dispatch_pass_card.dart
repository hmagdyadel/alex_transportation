import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_dispatch_pass_model.dart';

/// Digital dispatch pass card for an approved errand car mission.
/// Displays mission code, assigned vehicle, destination, authorized schedule,
/// and mileage tracking with start/end mission actions.
class ErrandDispatchPassCard extends StatelessWidget {
  final ErrandDispatchPassModel pass;
  final VoidCallback? onStartMission;
  final VoidCallback? onEndMission;
  final VoidCallback? onCancel;

  const ErrandDispatchPassCard({
    super.key,
    required this.pass,
    this.onStartMission,
    this.onEndMission,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = pass.status == 'completed';

    return AppCard(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Executive Holographic Smart Pass Header (matching fintech design slide)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF091F14),
                  Color(0xFF1B4332),
                  Color(0xFF0F3222),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.accentGold.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Row + Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const AlexLogo(size: 22),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'AlexBank',
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    // Pass ID Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: AppColors.accentGold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'PASS ID: ${pass.id}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'OFFICIAL EXECUTIVE DISPATCH',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'ALEXBANK CORPORATE MISSIONS',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accentGold.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Holographic APPROVED Banner & Mission Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MISSION: ${pass.missionCode}',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            'Destination: ${pass.destination}',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Glowing Approved Pill matching the image
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.grey.withValues(alpha: 0.2)
                            : const Color(0xFF00FF88).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.white38
                              : const Color(0xFF00FF88),
                          width: 1.5,
                        ),
                        boxShadow: isCompleted
                            ? null
                            : [
                                BoxShadow(
                                  color: const Color(0xFF00FF88)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.task_alt_rounded
                                : Icons.check_circle_rounded,
                            color: isCompleted
                                ? Colors.white70
                                : const Color(0xFF00FF88),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted ? 'COMPLETED' : 'APPROVED',
                            style: AppTypography.caption.copyWith(
                              color: isCompleted
                                  ? Colors.white70
                                  : const Color(0xFF00FF88),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Employee Details Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ASSIGNED OFFICER',
                      style: AppTypography.caption.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      pass.employeeName,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Vehicle Assignment Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_car_filled_rounded,
                        color: AppColors.primaryMid,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pass.carMake,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Plate: ${pass.carPlate}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMid,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Departure + Return Time Grid
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
                              Icons.schedule_rounded,
                              size: 20,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DEPARTURE',
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
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 1,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.update_rounded,
                              size: 20,
                              color: AppColors.accentGold,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EST. RETURN',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 9,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    pass.estimatedReturn,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
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
                ),

                const SizedBox(height: AppSpacing.sm),

                // Mileage Tracking
                if (pass.startMileage != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.blueLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.accentBlue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.speed_rounded,
                          size: 20,
                          color: AppColors.accentBlue,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Start: ${pass.startMileage} km',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentBlue,
                          ),
                        ),
                        if (pass.endMileage != null) ...[
                          Text(
                            '  →  End: ${pass.endMileage} km',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentBlue,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '${pass.distanceDriven} km',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // Mission Status & Verification Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.greenLight
                        : ((pass.startMileage != null) ? AppColors.greenLight : AppColors.goldLight),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: (isCompleted || pass.startMileage != null)
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : AppColors.accentGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: (isCompleted || pass.startMileage != null
                                  ? AppColors.primary
                                  : AppColors.accentGold)
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : (pass.startMileage != null
                                  ? Icons.directions_car_rounded
                                  : Icons.verified_user_rounded),
                          color: (isCompleted || pass.startMileage != null)
                              ? AppColors.primary
                              : AppColors.accentGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCompleted
                                  ? 'Mission Completed — Vehicle Returned'
                                  : (pass.startMileage != null
                                      ? 'Mission In Progress — Vehicle Dispatched'
                                      : 'Authorized Official Mission Pass'),
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: (isCompleted || pass.startMileage != null)
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCompleted
                                  ? 'Trip concluded and logged to corporate fleet'
                                  : (pass.startMileage != null
                                      ? 'Heading to ${pass.destination}'
                                      : 'Approved for ${pass.employeeName} (${pass.missionCode})'),
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
                if (!isCompleted)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            onStartMission != null
                                ? Icons.play_arrow_rounded
                                : Icons.stop_rounded,
                            size: 18,
                          ),
                          label: Text(
                            onStartMission != null
                                ? 'Start Mission'
                                : 'End Mission',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          onPressed: onStartMission ?? onEndMission,
                        ),
                      ),
                      if (onCancel != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(color: AppColors.danger),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            onPressed: onCancel,
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ],
                  ),

                if (isCompleted)
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
                          Icons.check_circle_rounded,
                          color: AppColors.primaryLight,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Mission Complete — Vehicle Returned',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
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
