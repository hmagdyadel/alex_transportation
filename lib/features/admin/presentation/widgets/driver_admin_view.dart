import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/admin_states.dart';

/// Driver & Chauffeur operations administration view.
/// Displays driver roster, safety ratings, route & vehicle assignments,
/// and contact quick actions.
class DriverAdminView extends StatelessWidget {
  const DriverAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminStates>(
      builder: (context, state) {
        final adminCubit = context.read<AdminCubit>();
        final captains = adminCubit.captains;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Captain Fleet Summary Card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: AppColors.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(
                      context.l10n.adminTotalCaptains,
                      '${captains.length}',
                      AppColors.primary,
                    ),
                    Container(height: 36, width: 1, color: AppColors.border),
                    _buildStatCol(
                      context.l10n.adminOnActiveDuty,
                      '${captains.length}',
                      AppColors.primaryMid,
                    ),
                    Container(height: 36, width: 1, color: AppColors.border),
                    _buildStatCol(
                      context.l10n.adminAvgRating,
                      '4.93 ★',
                      AppColors.accentGold,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Text(
                '${context.l10n.adminOfficialCaptains} (${captains.length})',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Roster Cards
              ...captains.map((driver) {
                final isErrandChauffeur = driver.assignedRouteId.startsWith(
                  'ERRAND',
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    backgroundColor: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isErrandChauffeur
                                        ? AppColors.goldLight
                                        : AppColors.greenLight,
                                    child: Icon(
                                      isErrandChauffeur
                                          ? Icons.drive_eta_rounded
                                          : Icons.directions_bus_rounded,
                                      size: 20,
                                      color: isErrandChauffeur
                                          ? AppColors.accentGold
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          driver.name,
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          context.l10n.driverLicensePhone(
                                            driver.licenseNumber,
                                            driver.phone,
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
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.goldLight,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                              ),
                              child: Text(
                                '${driver.rating} ★',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accentGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(),
                        const SizedBox(height: AppSpacing.xs),

                        // Assignment & Vehicle info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.adminAssignment,
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 8,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    driver.assignedRouteName,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  context.l10n.adminAssignedVehicle,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 8,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  driver.assignedBusPlate,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
