import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/app_text_field.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_states.dart';

/// Garage operations administration view.
/// Allows dynamic monthly fee adjustments (default 1,200 EGP, increase/decrease),
/// live parking bay management, and subscription status reviews.
class GarageAdminView extends StatelessWidget {
  const GarageAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarageCubit, GarageStates>(
      builder: (context, state) {
        final garageCubit = context.read<GarageCubit>();
        final fee = garageCubit.currentMonthlyFee;
        final subscription = garageCubit.currentSubscription;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dynamic Monthly Parking Fee Card (User Requirement #7)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                backgroundColor: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MONTHLY PARKING SUBSCRIPTION RATE',
                              style: AppTypography.labelSmall.copyWith(
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Admin Dynamic Pricing',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const StatusPill(
                          label: 'PAYROLL DEDUCTION',
                          type: StatusPillType.gold,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Big Fee Display & Stepper Controls
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT TARIFF',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '$fee',
                                    style: AppTypography.headlineLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'EGP / Month',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Increase / Decrease Stepper Buttons
                          Row(
                            children: [
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.textPrimary,
                                ),
                                icon: const Icon(Icons.remove_rounded),
                                tooltip: 'Decrease by 100 EGP',
                                onPressed: () {
                                  garageCubit.decreaseMonthlyFee(100);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Monthly parking fee updated to ${garageCubit.currentMonthlyFee} EGP'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.add_rounded),
                                tooltip: 'Increase by 100 EGP',
                                onPressed: () {
                                  garageCubit.increaseMonthlyFee(100);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Monthly parking fee updated to ${garageCubit.currentMonthlyFee} EGP'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded),
                                tooltip: 'Set Exact Tariff',
                                onPressed: () => _showEditFeeDialog(context, garageCubit, fee),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '• Note: Rate applies dynamically to upcoming month-end payroll deduction cycles for all active parking subscribers.',
                      style: AppTypography.caption.copyWith(color: AppColors.textMid),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Parking Capacity & Occupancy Matrix
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'FACILITY CAPACITY OVERVIEW',
                      style: AppTypography.labelSmall.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            label: 'TOTAL SLOTS',
                            value: '${GarageCubit.totalCapacity}',
                            icon: Icons.local_parking_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildMetricTile(
                            label: 'AVAILABLE',
                            value: '${garageCubit.availableSlots}',
                            icon: Icons.check_circle_outline_rounded,
                            color: AppColors.primaryMid,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildMetricTile(
                            label: 'WAITLIST',
                            value: '${garageCubit.waitingCount}',
                            icon: Icons.hourglass_top_rounded,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Active Subscription Management Card
              Text(
                'ACTIVE CORPORATE PARKING PASSES',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              if (subscription != null)
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  backgroundColor: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subscription.name,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'ISL: ${subscription.isl} • ${subscription.dept} Dept',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          StatusPill(
                            label: subscription.status.toUpperCase().replaceAll('_', ' '),
                            type: subscription.status == 'active'
                                ? StatusPillType.active
                                : StatusPillType.pending,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Divider(),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ASSIGNED BAY', style: AppTypography.caption),
                              Text(
                                subscription.slotLabel ?? 'P1-014',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PRESENCE STATUS', style: AppTypography.caption),
                              Text(
                                subscription.checkedIn ? 'Inside Facility' : 'Outside',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: subscription.checkedIn
                                      ? AppColors.primaryMid
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CURRENT TARIFF', style: AppTypography.caption),
                              Text(
                                '$fee EGP',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditFeeDialog(BuildContext context, GarageCubit cubit, int currentFee) {
    final controller = TextEditingController(text: '$currentFee');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set Dynamic Monthly Parking Fee'),
          content: AppTextField(
            controller: controller,
            label: 'Monthly Fee (EGP)',
            hint: '1200',
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final val = int.tryParse(controller.text.trim());
                if (val != null && val > 0) {
                  cubit.updateMonthlyFee(val);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Update Rate', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
