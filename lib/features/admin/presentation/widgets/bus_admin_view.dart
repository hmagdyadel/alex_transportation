import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/app_text_field.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_cubit.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_states.dart';

/// Bus Transit operations administration view.
/// Allows managing route stations, timings, driver assignments,
/// and 1-tap generation of mirrored evening return routes.
class BusAdminView extends StatefulWidget {
  const BusAdminView({super.key});

  @override
  State<BusAdminView> createState() => _BusAdminViewState();
}

class _BusAdminViewState extends State<BusAdminView> {
  String _selectedRouteId = 'R101';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusCubit, BusStates>(
      builder: (context, state) {
        final busCubit = context.read<BusCubit>();
        final routes = busCubit.routes;
        final selectedRoute = routes.firstWhere(
          (r) => r.id == _selectedRouteId,
          orElse: () => routes.first,
        );

        final isMorningRoute = selectedRoute.shift == 'Morning';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Route Selector Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: routes.map((r) {
                    final isSelected = r.id == _selectedRouteId;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(
                          '${r.routeNumber} (${r.shift})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onSelected: (val) {
                          if (val) setState(() => _selectedRouteId = r.id);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Route Details Header Card
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
                              selectedRoute.routeNumber.toUpperCase(),
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedRoute.name,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        StatusPill(
                          label: selectedRoute.shift.toUpperCase(),
                          type: isMorningRoute ? StatusPillType.gold : StatusPillType.active,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xs),

                    // Route Metadata Grid
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SCHEDULE',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '${selectedRoute.departureTime} → ${selectedRoute.estimatedArrival}',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CAPTAIN & VEHICLE',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '${selectedRoute.driverName} (${selectedRoute.busPlate})',
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Actions Bar: Mirror Route to Evening (if morning)
                    if (isMorningRoute)
                      AppButton(
                        label: 'Sync Mirrored Return Evening Line',
                        leadingIcon: const Icon(Icons.sync_alt_rounded, size: 18),
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          busCubit.generateReverseEveningRoute(selectedRoute.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Generated mirrored return route starting from Smart Village (HQ) back to departure stops.',
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Station Manifest Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STATIONS & TIMETABLE (${selectedRoute.stops.length})',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddStationDialog(context, selectedRoute),
                    icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                    label: const Text('Add Station'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              // Stops List
              ...selectedRoute.stops.map((stop) {
                final isTerminus = stop.order == selectedRoute.stops.length;
                final isStart = stop.order == 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    backgroundColor: AppColors.surface,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isStart
                              ? AppColors.accentGold.withValues(alpha: 0.2)
                              : isTerminus
                                  ? AppColors.primaryLight.withValues(alpha: 0.2)
                                  : AppColors.background,
                          child: Text(
                            '${stop.order}',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isStart
                                  ? AppColors.accentGold
                                  : isTerminus
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop.name,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (stop.nameAr != null)
                                Text(
                                  stop.nameAr!,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textMid,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            stop.scheduledTime,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          icon: const Icon(Icons.schedule_rounded, size: 18),
                          color: AppColors.textSecondary,
                          onPressed: () => _showEditTimeDialog(context, selectedRoute.id, stop),
                        ),
                        if (selectedRoute.stops.length > 2)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            color: AppColors.danger,
                            onPressed: () => busCubit.removeStationFromRoute(selectedRoute.id, stop.id),
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

  void _showAddStationDialog(BuildContext context, BusRouteModel route) {
    final nameController = TextEditingController();
    final nameArController = TextEditingController();
    final timeController = TextEditingController(text: '07:45 AM');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Add Station to ${route.routeNumber}', style: AppTypography.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: nameController, label: 'Station Name (EN)', hint: 'e.g. Ring Road Exit'),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(controller: nameArController, label: 'Station Name (AR)', hint: 'e.g. مخرج الدائري'),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(controller: timeController, label: 'Scheduled Time', hint: '07:45 AM'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final newStop = BusStopModel(
                  id: 'STOP-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  nameAr: nameArController.text.trim().isNotEmpty ? nameArController.text.trim() : null,
                  scheduledTime: timeController.text.trim(),
                  order: route.stops.length + 1,
                );
                context.read<BusCubit>().addStationToRoute(route.id, newStop);
                Navigator.pop(ctx);
              },
              child: const Text('Add Station', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showEditTimeDialog(BuildContext context, String routeId, BusStopModel stop) {
    final controller = TextEditingController(text: stop.scheduledTime);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit Timing for ${stop.name}', style: AppTypography.titleMedium),
          content: AppTextField(
            controller: controller,
            label: 'Scheduled Time',
            hint: '08:00 AM',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                context.read<BusCubit>().updateStationTime(routeId, stop.id, controller.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
