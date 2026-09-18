import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_cubit.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_states.dart';
import 'package:alex_transportation/features/buses/presentation/widgets/bus_boarding_pass_card.dart';
import 'package:alex_transportation/features/buses/presentation/widgets/bus_stop_timeline.dart';

/// Employee Bus Transit Screen:
/// - Real-time route schedules (Morning & Evening shifts)
/// - Digital boarding pass with one-tap boarding
/// - Interactive stop timelines and driver information
/// - Seat booking and cancellation with ModalProgressHUD
class BusesPage extends StatefulWidget {
  const BusesPage({super.key});

  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  String? _expandedRouteId;
  String? _selectedPickupStopId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusCubit, BusStates>(
      listener: (context, state) {
        switch (state) {
          case Success(:final data):
            if (data is String) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          case Error(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          default:
            break;
        }
      },
      builder: (context, state) {
        final cubit = context.read<BusCubit>();
        final isLoading = state is Loading ||
            state is BookingSeat ||
            state is CancellingBooking ||
            state is CheckingInToday;

        final routes = cubit.filteredRoutes;
        final activePass = cubit.activePass;
        final selectedShift = cubit.selectedShift;

        return ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: const CustomLoadingIndicator(size: 64),
          color: Colors.black,
          opacity: 0.5,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => cubit.loadBuses(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active Boarding Pass Section (if employee booked a seat)
                  if (activePass != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'YOUR ACTIVE BOARDING PASS',
                          style: AppTypography.labelSmall.copyWith(
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const StatusPill(
                          label: 'TODAY',
                          type: StatusPillType.gold,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    BusBoardingPassCard(
                      pass: activePass,
                      onCheckIn: () => cubit.checkInForToday(),
                      onCancel: () => _confirmCancelBooking(context, activePass.id),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Shift Filter Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AVAILABLE SHUTTLE ROUTES',
                        style: AppTypography.labelSmall.copyWith(
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: ['All', 'Morning', 'Evening'].map((shift) {
                          final isSelected = selectedShift == shift;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: InkWell(
                              onTap: () => cubit.filterShift(shift),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  shift,
                                  style: AppTypography.caption.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textMid,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Route Cards List
                  if (routes.isEmpty)
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      backgroundColor: AppColors.surface,
                      child: Center(
                        child: Text(
                          'No routes found for the selected shift',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: routes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final route = routes[index];
                        final isExpanded = _expandedRouteId == route.id;
                        return _buildRouteCard(context, route, isExpanded, activePass != null);
                      },
                    ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    BusRouteModel route,
    bool isExpanded,
    bool hasActivePass,
  ) {
    final isFull = route.availableSeats <= 0;
    final cubit = context.read<BusCubit>();

    return AppCard(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedRouteId = null;
                  _selectedPickupStopId = null;
                } else {
                  _expandedRouteId = route.id;
                  _selectedPickupStopId = route.stops.first.id;
                }
              });
            },
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: AppColors.primaryLight),
                            ),
                            child: Text(
                              route.routeNumber,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          StatusPill(
                            label: route.shift.toUpperCase(),
                            type: route.shift == 'Morning'
                                ? StatusPillType.neutral
                                : StatusPillType.gold,
                          ),
                        ],
                      ),
                      StatusPill(
                        label: isFull ? 'BUS FULL' : '${route.availableSeats} SEATS LEFT',
                        type: isFull ? StatusPillType.danger : StatusPillType.active,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    route.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.textMid,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${route.departureTime} → ${route.estimatedArrival}',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Icon(
                        Icons.pin_drop_outlined,
                        size: 16,
                        color: AppColors.textMid,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${route.stops.length} Stops',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMid,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details: Driver + Stop Manifest + Reservation Button
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Driver & Vehicle Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.person_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route.driverName,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Plate: ${route.busPlate}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMid,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.phone_rounded, size: 14),
                          label: const Text('Call Driver'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling ${route.driverName} (${route.driverPhone})...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'SELECT PICKUP STOP:',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Stop Timeline with interactive selection
                  BusStopTimeline(
                    stops: route.stops,
                    selectedStopId: _selectedPickupStopId,
                    onStopSelected: (stop) {
                      setState(() => _selectedPickupStopId = stop.id);
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Book Seat Action
                  if (hasActivePass)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.goldLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'You already have an active boarding pass for today.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    AppButton(
                      label: isFull ? 'Route Full' : 'Reserve Spot on ${route.routeNumber}',
                      onPressed: isFull
                          ? null
                          : () {
                              if (_selectedPickupStopId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select your pickup stop from the list above'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              cubit.bookSeat(
                                routeId: route.id,
                                stopId: _selectedPickupStopId!,
                                employeeName: 'Ahmed Hassan',
                              );
                            },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmCancelBooking(BuildContext context, String passId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text('Cancel Reservation', style: AppTypography.titleLarge),
        content: Text(
          'Are you sure you want to cancel your shuttle reservation? Your spot will be released to other colleagues.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Keep Reservation',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textMid,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<BusCubit>().cancelBooking(passId);
            },
            child: const Text('Cancel Reservation'),
          ),
        ],
      ),
    );
  }
}
