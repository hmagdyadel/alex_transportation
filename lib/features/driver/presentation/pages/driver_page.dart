import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:alex_transportation/features/driver/presentation/bloc/driver_cubit.dart';
import 'package:alex_transportation/features/driver/presentation/bloc/driver_states.dart';
import 'package:alex_transportation/features/driver/presentation/widgets/driver_trip_hud_card.dart';
import 'package:alex_transportation/features/driver/presentation/widgets/passenger_manifest_tile.dart';

/// Main screen for the AlexBank Driver Operations Portal.
/// Includes live trip execution HUD, passenger roster check-in & QR scanner,
/// and pre-trip vehicle safety inspection.
class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int _selectedTab = 0; // 0: Live HUD, 1: Passenger Manifest, 2: Inspection
  int _manifestFilter = 0; // 0: All, 1: Awaiting, 2: Boarded

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Shift & Sign Out'),
        content: const Text(
          'Are you sure you want to end your driver shift and return to the access gate?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthCubit>().signOut();
              if (context.mounted) {
                context.go('/access');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverCubit, DriverStates>(
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
        final cubit = context.read<DriverCubit>();
        final profile = cubit.profile;
        final trip = cubit.activeTrip;
        final isLoading = state is Loading ||
            state is StartingTrip ||
            state is AdvancingStop ||
            state is BoardingPassenger ||
            state is CompletingTrip;

        return ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: const CustomLoadingIndicator(size: 64),
          color: Colors.black,
          opacity: 0.5,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              titleSpacing: AppSpacing.md,
              title: Row(
                children: [
                  const AlexLogo(size: 26),
                  const SizedBox(width: AppSpacing.xs),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALEXBANK',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Transit — Driver Portal',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMid,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: StatusPill(
                    label: 'CAPTAIN',
                    type: StatusPillType.gold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textMid,
                    size: 20,
                  ),
                  tooltip: 'Sign Out',
                  onPressed: () => _showSignOutDialog(context),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
            body: Column(
              children: [
                // Driver Profile Bar
                if (profile != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    color: AppColors.greenLight,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.badge_rounded,
                          size: 16,
                          color: AppColors.primaryMid,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${profile.name} • Bus: ${profile.assignedBusNumber} (${profile.assignedBusPlate})',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.accentGold,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${profile.rating}',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Sub-Tab Navigation Bar
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      _buildSubTabButton(
                        index: 0,
                        icon: Icons.navigation_rounded,
                        label: 'Trip HUD',
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildSubTabButton(
                        index: 1,
                        icon: Icons.people_alt_rounded,
                        label: 'Manifest (${cubit.boardedCount}/${cubit.totalPassengers})',
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildSubTabButton(
                        index: 2,
                        icon: Icons.checklist_rounded,
                        label: 'Inspection',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // Tab View Content
                Expanded(
                  child: trip == null
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : IndexedStack(
                          index: _selectedTab,
                          children: [
                            _buildTripHudView(cubit, trip),
                            _buildManifestView(cubit, trip),
                            _buildInspectionView(cubit),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubTabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textMid,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.textMid,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TAB 0: LIVE TRIP HUD ──────────────────────────────────────────────────
  Widget _buildTripHudView(DriverCubit cubit, dynamic trip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DriverTripHudCard(
            trip: trip,
            onStartTrip: () => cubit.startTrip(),
            onAdvanceStop: () => cubit.advanceToNextStop(),
            onCompleteTrip: () => cubit.completeTrip(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Route Timeline Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ROUTE TIMELINE',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '${trip.stops.length} STOPS',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                ...trip.stops.asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final stop = entry.value;
                  final isCurrent = stop.isCurrent;
                  final isCompleted = stop.isCompleted;
                  final isLast = index == trip.stops.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Node & Connector
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? AppColors.primaryLight
                                  : isCurrent
                                      ? AppColors.accentGold
                                      : Colors.white,
                              border: Border.all(
                                color: isCompleted || isCurrent
                                    ? Colors.transparent
                                    : AppColors.border,
                                width: 2,
                              ),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accentGold
                                            .withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check
                                  : isCurrent
                                      ? Icons.navigation_rounded
                                      : Icons.circle,
                              size: isCompleted || isCurrent ? 14 : 8,
                              color: isCompleted || isCurrent
                                  ? Colors.white
                                  : AppColors.border,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 36,
                              color: isCompleted
                                  ? AppColors.primaryLight
                                  : AppColors.border,
                            ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Stop Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stop.name,
                                      style: AppTypography.bodySmall.copyWith(
                                        fontWeight: isCurrent
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isCurrent
                                            ? AppColors.textPrimary
                                            : isCompleted
                                                ? AppColors.textMid
                                                : AppColors.textSecondary,
                                      ),
                                    ),
                                    if (stop.nameAr != null)
                                      Text(
                                        stop.nameAr!,
                                        style: AppTypography.caption.copyWith(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppColors.goldLight
                                      : AppColors.background,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  stop.scheduledTime,
                                  style: AppTypography.caption.copyWith(
                                    color: isCurrent
                                        ? AppColors.accentGold
                                        : AppColors.textMid,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 1: PASSENGER MANIFEST & SCANNER ──────────────────────────────────
  Widget _buildManifestView(DriverCubit cubit, dynamic trip) {
    final filteredPassengers = trip.passengers.where((p) {
      if (_manifestFilter == 1) return !p.isBoarded;
      if (_manifestFilter == 2) return p.isBoarded;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Boarding Progress Overview Card
          AppCard(
            backgroundColor: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'BOARDING STATUS',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${cubit.boardedCount} of ${cubit.totalPassengers} Boarded',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryMid,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: cubit.totalPassengers > 0
                        ? cubit.boardedCount / cubit.totalPassengers
                        : 0.0,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tap the BOARD button next to each employee to check them in upon boarding the bus.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMid,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Manifest Counter & Filter Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PASSENGER MANIFEST',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${cubit.boardedCount} / ${cubit.totalPassengers} Boarded',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Filter Segment
          Row(
            children: [
              _buildFilterChip(0, 'All (${trip.totalPassengers})'),
              const SizedBox(width: AppSpacing.xs),
              _buildFilterChip(1, 'Awaiting (${trip.totalPassengers - trip.boardedCount})'),
              const SizedBox(width: AppSpacing.xs),
              _buildFilterChip(2, 'Boarded (${trip.boardedCount})'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Passenger Roster List
          ...filteredPassengers.map((passenger) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: PassengerManifestTile(
                  passenger: passenger,
                  onToggleBoarding: () => cubit.boardPassenger(passenger.id),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _manifestFilter == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _manifestFilter = index),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isSelected ? Colors.white : AppColors.textMid,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  // ─── TAB 2: PRE-TRIP VEHICLE INSPECTION ────────────────────────────────────
  Widget _buildInspectionView(DriverCubit cubit) {
    final checklist = cubit.inspectionChecklist;
    final isReady = cubit.isInspectionComplete;
    final checkedCount = checklist.values.where((v) => v).length;
    final totalCount = checklist.length;

    final inspectionItems = [
      {
        'id': 'tires',
        'title': 'Tires & Pressure',
        'desc': 'All tires inspected for pressure, tread depth, and wheel lug nuts.',
        'icon': Icons.album_rounded,
      },
      {
        'id': 'fuel_battery',
        'title': 'Fuel / Battery Level',
        'desc': 'Fuel tank above 75% or EV battery adequately charged for route.',
        'icon': Icons.local_gas_station_rounded,
      },
      {
        'id': 'first_aid',
        'title': 'Emergency First Aid Kit & Extinguisher',
        'desc': 'Fire extinguisher certified, first aid medical pouch fully stocked.',
        'icon': Icons.medical_services_rounded,
      },
      {
        'id': 'ac_ventilation',
        'title': 'Climate Control & AC',
        'desc': 'Cabin air conditioning and ventilation functioning at 21°C.',
        'icon': Icons.ac_unit_rounded,
      },
      {
        'id': 'mirrors_cameras',
        'title': 'Mirrors & Rearview Cameras',
        'desc': 'Side view mirrors adjusted, backup camera sensor clean.',
        'icon': Icons.remove_red_eye_rounded,
      },
      {
        'id': 'cleanliness',
        'title': 'Interior Cleanliness & Sanitization',
        'desc': 'Passenger seats sanitized, aisles clean, waste receptacles emptied.',
        'icon': Icons.cleaning_services_rounded,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Readiness Banner
          AppCard(
            backgroundColor: isReady ? AppColors.greenLight : AppColors.goldLight,
            borderSide: BorderSide(
              color: isReady
                  ? AppColors.primaryLight.withValues(alpha: 0.4)
                  : AppColors.accentGold.withValues(alpha: 0.4),
            ),
            child: Row(
              children: [
                Icon(
                  isReady
                      ? Icons.verified_rounded
                      : Icons.warning_amber_rounded,
                  color: isReady ? AppColors.primary : AppColors.accentGold,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReady
                            ? 'VEHICLE READY FOR DISPATCH'
                            : 'INSPECTION IN PROGRESS',
                        style: AppTypography.labelLarge.copyWith(
                          color: isReady ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '$checkedCount of $totalCount checks passed. Complete safety protocol before departure.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMid,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'PRE-TRIP SAFETY CHECKLIST',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...inspectionItems.map((item) {
            final id = item['id'] as String;
            final isChecked = checklist[id] ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                backgroundColor: isChecked ? AppColors.surface : AppColors.background,
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isChecked ? AppColors.primary : AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            item['desc'] as String,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMid,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isChecked,
                      activeThumbColor: AppColors.primary,
                      onChanged: (_) => cubit.toggleInspectionItem(id),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
