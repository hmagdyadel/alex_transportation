import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_cubit.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_states.dart';

/// Errand Cars operations administration view.
/// Allows approving corporate errand missions, vehicle & chauffeur assignments,
/// and reviewing dual-point routes (Pickup Point -> Destination).
class ErrandAdminView extends StatelessWidget {
  const ErrandAdminView({super.key});

  String _formatStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return context.l10n.pending.toUpperCase();
      case 'approved':
        return context.l10n.approved.toUpperCase();
      case 'active':
        return context.l10n.active.toUpperCase();
      case 'completed':
        return context.l10n.completed.toUpperCase();
      case 'rejected':
        return context.l10n.rejected.toUpperCase();
      case 'cancelled':
        return context.l10n.cancelled.toUpperCase();
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ErrandCarCubit, ErrandCarStates>(
      builder: (context, state) {
        final cubit = context.read<ErrandCarCubit>();
        final fleet = cubit.fleet;
        final requests = cubit.myRequests;
        final availableCars = cubit.availableCars;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fleet Status Overview
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            context.l10n.adminExecutiveFleetOverview,
                            style: AppTypography.labelSmall.copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        StatusPill(
                          label: context.l10n.adminAvailableCarsCount(
                            availableCars,
                            fleet.length,
                          ),
                          type: availableCars > 0
                              ? StatusPillType.active
                              : StatusPillType.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: fleet.map((car) {
                          final isAvailable = car.status == 'available';
                          return Container(
                            margin: const EdgeInsets.only(right: AppSpacing.sm),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            width: 140,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isAvailable
                                    ? AppColors.primaryLight.withValues(
                                        alpha: 0.4,
                                      )
                                    : AppColors.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      car.id,
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isAvailable
                                            ? AppColors.primaryMid
                                            : AppColors.accentGold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  car.make,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  car.plateNumber,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${car.currentMileage} km',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 9,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Errand Requests Manifest Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${context.l10n.adminMissionRequestManifest} (${requests.length})',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              // List of Errand Requests with Dual-Point Routing
              ...requests.map((req) {
                final isPending = req.status == 'pending';
                final isApproved = req.status == 'approved';

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    backgroundColor: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Request ID + Employee Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        req.id,
                                        style: AppTypography.labelMedium
                                            .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          '• ${req.employeeName} (${req.employeeIsl})',
                                          style: AppTypography.caption.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    context.l10n.adminDeptSupervisor(
                                      req.department,
                                      req.supervisorName,
                                    ),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            StatusPill(
                              label: _formatStatus(context, req.status),
                              type: isApproved
                                  ? StatusPillType.active
                                  : isPending
                                  ? StatusPillType.pending
                                  : StatusPillType.neutral,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Dual-Point Journey Route (Pickup -> Destination) (User Requirement #10)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.trip_origin_rounded,
                                size: 16,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.adminPickupLabel,
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      req.pickupLocation,
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: AppColors.primaryMid,
                                ),
                              ),
                              const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.adminDestinationLabel,
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      req.destination,
                                      style: AppTypography.bodySmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Purpose & Schedule Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.adminPurposeWithDetails(
                                  req.purpose,
                                ),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMid,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${req.requestedTime} → ${req.estimatedReturnTime}',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Assigned vehicle info (if assigned)
                        if (req.assignedCarMake != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car_rounded,
                                size: 14,
                                color: AppColors.primaryMid,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${req.assignedCarMake} (${req.assignedCarPlate})',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryMid,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
