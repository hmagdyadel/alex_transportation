import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/app_text_field.dart';
import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_cubit.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_states.dart';
import 'package:alex_transportation/features/errand_cars/presentation/widgets/errand_dispatch_pass_card.dart';
import 'package:alex_transportation/features/errand_cars/presentation/widgets/errand_request_history_card.dart';

/// Employee Errand Cars Screen:
/// - Fleet overview with availability banner
/// - Active dispatch pass with mission actions
/// - Request new vehicle for corporate missions
/// - Track request history and status
class ErrandCarsPage extends StatefulWidget {
  const ErrandCarsPage({super.key});

  @override
  State<ErrandCarsPage> createState() => _ErrandCarsPageState();
}

class _ErrandCarsPageState extends State<ErrandCarsPage> {
  int _selectedSubTab = 0; // 0: My Missions, 1: Request Vehicle, 2: Track Status

  // Request Form Controllers
  final _nameController = TextEditingController();
  final _islController = TextEditingController();
  final _pickupController = TextEditingController(text: 'Smart Village Operations Hub');
  final _destinationController = TextEditingController();
  final _purposeController = TextEditingController();
  final _supervisorController = TextEditingController();
  final _endMileageController = TextEditingController();
  String _selectedDept = 'IT';
  String _requestedDate = '';
  String _requestedTime = '10:00 AM';
  String _estimatedReturn = '02:00 PM';

  static const List<String> _commonLocations = [
    'Smart Village Operations Hub',
    'AlexBank Downtown Cairo HQ',
    'New Cairo Branch Hub',
    'Alexandria Main Branch',
  ];

  static const List<String> _departments = [
    'IT',
    'Finance',
    'HR',
    'Operations',
    'Risk',
    'Legal',
    'Treasury',
    'Retail',
    'Compliance',
    'Internal Audit',
  ];

  static const List<String> _departureTimes = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
  ];

  static const List<String> _returnTimes = [
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _requestedDate = '${now.day} ${_monthName(now.month)} ${now.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _islController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    _purposeController.dispose();
    _supervisorController.dispose();
    _endMileageController.dispose();
    super.dispose();
  }

  void _submitRequest(BuildContext context) {
    context.read<ErrandCarCubit>().submitRequest(
          employeeName: _nameController.text,
          employeeIsl: _islController.text,
          department: _selectedDept,
          pickupLocation: _pickupController.text,
          destination: _destinationController.text,
          purpose: _purposeController.text,
          requestedDate: _requestedDate,
          requestedTime: _requestedTime,
          estimatedReturnTime: _estimatedReturn,
          supervisorName: _supervisorController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ErrandCarCubit, ErrandCarStates>(
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
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Request approved! Dispatch pass issued.'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              setState(() => _selectedSubTab = 0);
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
        final cubit = context.read<ErrandCarCubit>();
        final isLoading = state is Loading ||
            state is SubmittingRequest ||
            state is CancellingRequest ||
            state is StartingMission ||
            state is EndingMission;

        final availableCars = cubit.availableCars;
        const totalFleet = ErrandCarCubit.totalFleet;
        final inUseCars = totalFleet - availableCars;
        final utilizationRate = (inUseCars / totalFleet).clamp(0.0, 1.0);

        return ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: const CustomLoadingIndicator(size: 64),
          color: Colors.black,
          opacity: 0.5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fleet Overview Banner
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
                                'FLEET AVAILABILITY',
                                style: AppTypography.labelSmall.copyWith(
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$availableCars Cars Available',
                                style: AppTypography.titleLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const StatusPill(
                            label: 'OFFICIAL USE',
                            type: StatusPillType.gold,
                            icon: Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.accentGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: utilizationRate,
                          minHeight: 10,
                          backgroundColor: AppColors.background,
                          color: availableCars < 2
                              ? AppColors.danger
                              : AppColors.primaryMid,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$inUseCars of $totalFleet vehicles dispatched',
                            style: AppTypography.caption,
                          ),
                          Text(
                            '${(utilizationRate * 100).toInt()}% Utilized',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Sub-Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _buildSubTabItem(
                          0, 'My Missions', Icons.assignment_rounded),
                      _buildSubTabItem(
                          1, 'Request', Icons.add_circle_outline_rounded),
                      _buildSubTabItem(
                          2, 'Track', Icons.timeline_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Tab Content
                if (_selectedSubTab == 0)
                  _buildMyMissionsTab(cubit)
                else if (_selectedSubTab == 1)
                  _buildRequestVehicleTab(context)
                else
                  _buildTrackStatusTab(cubit),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubTabItem(int index, String label, IconData icon) {
    final isSelected = _selectedSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textMid,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMid,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 0: My Missions ───────────────────────────────────────────────────
  Widget _buildMyMissionsTab(ErrandCarCubit cubit) {
    final activePass = cubit.activePass;
    final requests = cubit.myRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (activePass != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE DISPATCH PASS',
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
          ErrandDispatchPassCard(
            pass: activePass,
            onStartMission: activePass.status != 'completed'
                ? () => cubit.startMission(activePass.id)
                : null,
            onEndMission: null,
            onCancel: () => _confirmCancelRequest(
              context,
              activePass.requestId,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // End Mission inline (when mission is started)
        if (activePass != null) ...[
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            backgroundColor: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'END MISSION — RECORD RETURN MILEAGE',
                  style: AppTypography.labelSmall.copyWith(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _endMileageController,
                  label: 'ODOMETER READING (KM)',
                  hint: 'e.g. 34560',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Complete Mission & Return Vehicle',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    final mileage =
                        int.tryParse(_endMileageController.text.trim());
                    if (mileage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid mileage reading'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      return;
                    }
                    cubit.endMission(activePass.id, mileage);
                  },
                  leadingIcon: const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        if (activePass == null && requests.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Icon(
                  Icons.directions_car_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No Active Missions',
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Submit a vehicle request to get a dispatch pass for your corporate errand.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Request a Vehicle',
                  onPressed: () =>
                      setState(() => _selectedSubTab = 1),
                ),
              ],
            ),
          ),

        // Recent Request History
        if (requests.isNotEmpty) ...[
          Text(
            'REQUEST HISTORY',
            style: AppTypography.labelSmall.copyWith(
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final request = requests[index];
              return ErrandRequestHistoryCard(
                request: request,
                onCancel: (request.status == 'pending' ||
                        request.status == 'approved')
                    ? () => _confirmCancelRequest(context, request.id)
                    : null,
              );
            },
          ),
        ],

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ── Tab 1: Request Vehicle ───────────────────────────────────────────────
  Widget _buildRequestVehicleTab(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New Vehicle Request',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Request an official bank vehicle for corporate errands.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Employee Name
          AppTextField(
            controller: _nameController,
            label: 'FULL NAME',
            hint: 'e.g. Ahmed Hassan',
          ),
          const SizedBox(height: AppSpacing.sm),

          // ISL
          AppTextField(
            controller: _islController,
            label: 'BANK ISL (4-8 DIGITS)',
            hint: '10234',
            keyboardType: TextInputType.number,
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Department
          Text(
            'DEPARTMENT',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMid,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDept,
                isExpanded: true,
                items: _departments.map((d) {
                  return DropdownMenuItem(value: d, child: Text(d));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedDept = v);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Pickup Location
          AppTextField(
            controller: _pickupController,
            label: 'PICKUP LOCATION',
            hint: 'e.g. Smart Village Operations Hub',
            prefixIcon: const Icon(Icons.trip_origin_rounded, color: AppColors.accentGold, size: 20),
          ),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _commonLocations.map((loc) {
                final isSelected = _pickupController.text == loc;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: ActionChip(
                    label: Text(loc, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textPrimary)),
                    backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _pickupController.text = loc;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Destination
          AppTextField(
            controller: _destinationController,
            label: 'DESTINATION',
            hint: 'e.g. Alexandria Main Branch',
            prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _commonLocations.map((loc) {
                final isSelected = _destinationController.text == loc;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: ActionChip(
                    label: Text(loc, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textPrimary)),
                    backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _destinationController.text = loc;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Purpose
          AppTextField(
            controller: _purposeController,
            label: 'MISSION PURPOSE',
            hint: 'Describe the reason for this errand',
          ),
          const SizedBox(height: AppSpacing.sm),

          // Departure Time
          Text(
            'DEPARTURE TIME',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMid,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _requestedTime,
                isExpanded: true,
                items: _departureTimes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _requestedTime = v);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Estimated Return
          Text(
            'ESTIMATED RETURN',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMid,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _estimatedReturn,
                isExpanded: true,
                items: _returnTimes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _estimatedReturn = v);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Supervisor Name
          AppTextField(
            controller: _supervisorController,
            label: 'SUPERVISOR NAME',
            hint: 'e.g. Dr. Hany Fouad',
          ),
          const SizedBox(height: AppSpacing.md),

          // Info notice
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: AppColors.accentBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.accentBlue,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Your request will be reviewed by the fleet administrator. A vehicle will be assigned based on availability and supervisor approval.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Submit
          AppButton(
            label: 'Submit Vehicle Request',
            variant: AppButtonVariant.primary,
            onPressed: () => _submitRequest(context),
            leadingIcon: const Icon(
              Icons.send_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Track Status ──────────────────────────────────────────────────
  Widget _buildTrackStatusTab(ErrandCarCubit cubit) {
    final requests = cubit.myRequests;

    if (requests.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No Requests Found',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'You have not submitted any errand car requests yet.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      );
    }

    // Status summary chips
    final pending = requests.where((r) => r.status == 'pending').length;
    final approved = requests.where((r) =>
        r.status == 'approved' || r.status == 'in_progress').length;
    final completed = requests.where((r) => r.status == 'completed').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary chips
        Row(
          children: [
            _buildSummaryChip('Pending', pending, AppColors.accentGold,
                AppColors.goldLight),
            const SizedBox(width: AppSpacing.xs),
            _buildSummaryChip('Active', approved, AppColors.primaryMid,
                AppColors.greenLight),
            const SizedBox(width: AppSpacing.xs),
            _buildSummaryChip('Done', completed, AppColors.accentBlue,
                AppColors.blueLight),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // All requests list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final request = requests[index];
            return ErrandRequestHistoryCard(
              request: request,
              onCancel: (request.status == 'pending' ||
                      request.status == 'approved')
                  ? () => _confirmCancelRequest(context, request.id)
                  : null,
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildSummaryChip(
    String label,
    int count,
    Color textColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTypography.titleLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelRequest(BuildContext context, String requestId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text('Cancel Errand Request', style: AppTypography.titleLarge),
        content: Text(
          'Are you sure you want to cancel this vehicle request? If a car has been assigned, it will be released back to the fleet.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Keep Request',
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
              context.read<ErrandCarCubit>().cancelRequest(requestId);
            },
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }
}
