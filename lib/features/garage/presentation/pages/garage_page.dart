import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/app_text_field.dart';
import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/garage/data/models/garage_subscription_model.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_states.dart';
import 'package:alex_transportation/features/garage/presentation/widgets/garage_pass_card.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  int _selectedSubTab = 0; // 0: My Pass, 1: Subscribe, 2: Status, 3: Cancel

  // Subscribe Form Controllers
  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _islController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedDept = 'IT';
  String _priorityTier = 'standard';
  bool _consent = false;
  String? _licenseFileName;

  // Status Search Controllers
  final _statusIslController = TextEditingController();
  final _statusEmailController = TextEditingController();
  GarageSubscriptionModel? _lookupResult;
  bool _hasSearched = false;

  // Cancel Form Controllers
  final _cancelIslController = TextEditingController();
  final _cancelEmailController = TextEditingController();

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

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _islController.dispose();
    _emailController.dispose();
    _statusIslController.dispose();
    _statusEmailController.dispose();
    _cancelIslController.dispose();
    _cancelEmailController.dispose();
    super.dispose();
  }

  void _submitSubscription(BuildContext context) {
    context.read<GarageCubit>().submitSubscription(
          name: _nameController.text,
          nationalId: _nationalIdController.text,
          isl: _islController.text,
          dept: _selectedDept,
          email: _emailController.text,
          priorityTier: _priorityTier,
          consent: _consent,
          licenseUrl: _licenseFileName,
        );
  }

  void _lookupStatus(BuildContext context) {
    final result = context.read<GarageCubit>().findSubscription(
          _statusIslController.text,
          _statusEmailController.text,
        );
    setState(() {
      _lookupResult = result;
      _hasSearched = true;
    });
  }

  void _submitCancellation(BuildContext context) {
    context.read<GarageCubit>().requestCancellation(
          isl: _cancelIslController.text,
          email: _cancelEmailController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<GarageCubit, GarageStates>(
      listener: (context, state) {
        switch (state) {
          case Success(:final data):
            final message = data is String
                ? data
                : l10n.success;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.primaryMid,
                behavior: SnackBarBehavior.floating,
              ),
            );
            if (data is GarageSubscriptionModel) {
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
        final cubit = context.read<GarageCubit>();
        final isLoading = state is Loading ||
            state is SubmittingSubscription ||
            state is CheckingInOut ||
            state is Cancelling;

        final availableSlots = cubit.availableSlots;
        const totalCapacity = GarageCubit.totalCapacity;
        final occupiedSlots = totalCapacity - availableSlots;
        final occupancyRate = (occupiedSlots / totalCapacity).clamp(0.0, 1.0);

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
                // Live Capacity Banner Card
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
                                l10n.garageLiveOccupancy.toUpperCase(),
                                style: AppTypography.labelSmall.copyWith(
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$availableSlots ${l10n.garageAvailable}',
                                style: AppTypography.titleLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          StatusPill(
                            label: 'EGP ${cubit.currentMonthlyFee} / MO',
                            type: StatusPillType.gold,
                            icon: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 14,
                              color: AppColors.accentGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: occupancyRate,
                          minHeight: 10,
                          backgroundColor: AppColors.background,
                          color: availableSlots < 20
                              ? AppColors.danger
                              : AppColors.primaryMid,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$occupiedSlots / $totalCapacity ${l10n.garageTotalSlots}',
                            style: AppTypography.caption,
                          ),
                          Text(
                            '${(occupancyRate * 100).toInt()}%',
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

                // Sub-Tabs Navigation Bar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _buildSubTabItem(0, l10n.garageTabMyPass, Icons.local_parking_rounded),
                      _buildSubTabItem(1, l10n.garageTabSubscribe, Icons.add_circle_outline_rounded),
                      _buildSubTabItem(2, l10n.garageTabLookup, Icons.search_rounded),
                      _buildSubTabItem(3, l10n.garageTabCancel, Icons.cancel_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Active View Body
                if (_selectedSubTab == 0)
                  _buildMyPassTab(cubit, isLoading, l10n)
                else if (_selectedSubTab == 1)
                  _buildSubscribeTab(context, cubit, l10n)
                else if (_selectedSubTab == 2)
                  _buildStatusLookupTab(context, l10n)
                else
                  _buildCancelTab(context, l10n),
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
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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

  // ── Tab 0: My Pass ──────────────────────────────────────────────────────────
  Widget _buildMyPassTab(GarageCubit cubit, bool isLoading, dynamic l10n) {
    final sub = cubit.currentSubscription;

    if (sub == null) {
      return AppCard(
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
              l10n.garageHeaderTitle,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.garageHeaderSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.garageTabSubscribe,
              onPressed: () => setState(() => _selectedSubTab = 1),
            ),
          ],
        ),
      );
    }

    return GaragePassCard(
      subscription: sub,
      isLoading: isLoading,
      onCheckInOut: () => cubit.checkInOut(),
    );
  }

  // ── Tab 1: Subscribe ────────────────────────────────────────────────────────
  Widget _buildSubscribeTab(BuildContext context, GarageCubit cubit, dynamic l10n) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.garageSubscriptionFormTitle,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.garageMonthlyDeductionNotice,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Name
          AppTextField(
            controller: _nameController,
            label: l10n.garageEmployeeName,
            hint: 'e.g. Sara Hassan',
          ),
          const SizedBox(height: AppSpacing.sm),

          // National ID
          AppTextField(
            controller: _nationalIdController,
            label: l10n.garageNationalId,
            hint: '29001011234567',
            keyboardType: TextInputType.number,
            maxLength: 14,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ISL Number
          AppTextField(
            controller: _islController,
            label: l10n.staffIslLabel,
            hint: '10234',
            keyboardType: TextInputType.number,
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Department Dropdown
          Text(
            l10n.errandDepartmentLabel,
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

          // Email
          AppTextField(
            controller: _emailController,
            label: l10n.garageEmail,
            hint: 's.hassan@alexbank.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Priority Tier Selector
          Text(
            'TIER',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMid,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Standard')),
                  selected: _priorityTier == 'standard',
                  selectedColor: AppColors.greenLight,
                  onSelected: (_) => setState(() => _priorityTier = 'standard'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Senior')),
                  selected: _priorityTier == 'senior',
                  selectedColor: AppColors.goldLight,
                  onSelected: (_) => setState(() => _priorityTier = 'senior'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // License Photo Upload Box
          InkWell(
            onTap: () {
              setState(() {
                _licenseFileName = 'license_front_verified.jpg';
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                  color: _licenseFileName != null
                      ? AppColors.primaryLight
                      : AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _licenseFileName != null
                        ? Icons.check_circle_rounded
                        : Icons.camera_alt_outlined,
                    color: _licenseFileName != null
                        ? AppColors.primaryMid
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _licenseFileName ?? 'Upload Driving License Photo',
                      style: AppTypography.bodySmall.copyWith(
                        color: _licenseFileName != null
                            ? AppColors.primary
                            : AppColors.textMid,
                        fontWeight: _licenseFileName != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Payroll Deduction Agreement Checkbox
          CheckboxListTile(
            value: _consent,
            onChanged: (v) => setState(() => _consent = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
            title: Text(
              l10n.garageConsentCheckbox,
              style: AppTypography.caption.copyWith(color: AppColors.textMid),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Submit Button
          AppButton(
            label: l10n.garageSubmitApplication,
            variant: AppButtonVariant.primary,
            onPressed: () => _submitSubscription(context),
            leadingIcon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Status Lookup ────────────────────────────────────────────────────
  Widget _buildStatusLookupTab(BuildContext context, dynamic l10n) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.garageLookupTitle,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.garageEnterIslSearch,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _statusIslController,
            label: l10n.staffIslLabel,
            hint: 'e.g. 10234',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _statusEmailController,
            label: l10n.garageEmail,
            hint: 's.hassan@alexbank.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.search,
            variant: AppButtonVariant.primary,
            onPressed: () => _lookupStatus(context),
            leadingIcon: const Icon(Icons.search_rounded, size: 18, color: Colors.white),
          ),

          if (_hasSearched) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            if (_lookupResult != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _lookupResult!.name,
                          style: AppTypography.titleMedium,
                        ),
                        StatusPill(
                          label: _lookupResult!.status.toUpperCase(),
                          type: _lookupResult!.status == 'active'
                              ? StatusPillType.active
                              : StatusPillType.pending,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _lookupResult!.status == 'active'
                          ? '${l10n.garageAssignedBay}: ${_lookupResult!.slotLabel ?? "General"}'
                          : 'Waiting List Position: #${_lookupResult!.waitingPosition ?? 1}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: AppRadius.borderMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.danger),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'No parking records found.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ── Tab 3: Cancel Request ───────────────────────────────────────────────────
  Widget _buildCancelTab(BuildContext context, dynamic l10n) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l10n.garageCancelTitle,
                    style: AppTypography.caption.copyWith(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _cancelIslController,
            label: l10n.staffIslLabel,
            hint: 'e.g. 10234',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _cancelEmailController,
            label: l10n.garageEmail,
            hint: 'name@alexbank.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.garageSubmitCancellation,
            variant: AppButtonVariant.outline,
            onPressed: () => _submitCancellation(context),
            leadingIcon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
