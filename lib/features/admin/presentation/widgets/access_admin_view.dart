import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/app_text_field.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/admin_states.dart';

/// Access & Security administration view.
/// Allows generating secure invite codes, managing user roles,
/// toggling code validity, and instant role switching for tests.
class AccessAdminView extends StatefulWidget {
  const AccessAdminView({super.key});

  @override
  State<AccessAdminView> createState() => _AccessAdminViewState();
}

class _AccessAdminViewState extends State<AccessAdminView> {
  final _deptController = TextEditingController(text: 'General');
  final _noteController = TextEditingController();
  String _selectedRole = 'employee';

  @override
  void dispose() {
    _deptController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminStates>(
      builder: (context, state) {
        final adminCubit = context.read<AdminCubit>();
        final codes = adminCubit.inviteCodes;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Role Switcher Test Bar
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TEST ROLE SWITCHER',
                      style: AppTypography.labelSmall.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Instantly preview the app as different enterprise roles:',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Employee',
                            leadingIcon: const Icon(Icons.person_rounded, size: 16),
                            variant: AppButtonVariant.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                            onPressed: () => context.go('/home'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: AppButton(
                            label: 'Driver',
                            leadingIcon: const Icon(Icons.directions_bus_rounded, size: 16),
                            variant: AppButtonVariant.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                            onPressed: () => context.go('/driver'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: AppButton(
                            label: 'Admin',
                            leadingIcon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
                            variant: AppButtonVariant.primary,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                            onPressed: () => context.go('/admin'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Code Generator Form
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'GENERATE ACCESS INVITE CODE',
                      style: AppTypography.labelSmall.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Role Selector
                    Text(
                      'TARGET ROLE',
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'employee', label: Text('Employee')),
                        ButtonSegment(value: 'driver', label: Text('Driver')),
                        ButtonSegment(value: 'admin', label: Text('Admin')),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (val) {
                        setState(() => _selectedRole = val.first);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    AppTextField(
                      controller: _deptController,
                      label: 'DEPARTMENT / DIVISION',
                      hint: 'e.g. Operations Hub',
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    AppTextField(
                      controller: _noteController,
                      label: 'NOTES / MEMO',
                      hint: 'e.g. Q4 Regional Onboarding Batch',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppButton(
                      label: 'Generate Secure Code',
                      leadingIcon: const Icon(Icons.vpn_key_rounded, size: 18),
                      onPressed: () {
                        adminCubit.generateInviteCode(
                          role: _selectedRole,
                          department: _deptController.text.trim(),
                          note: _noteController.text.trim().isNotEmpty
                              ? _noteController.text.trim()
                              : null,
                        );
                        _noteController.clear();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Existing Invite Codes
              Text(
                'ACTIVE INVITE CODES (${codes.length})',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              ...codes.map((code) {
                final rolePillType = code.role == 'admin'
                    ? StatusPillType.gold
                    : (code.role == 'driver' ? StatusPillType.active : StatusPillType.neutral);

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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    code.code,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  StatusPill(
                                    label: code.role.toUpperCase(),
                                    type: rolePillType,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dept: ${code.department} • Uses: ${code.useCount}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                              if (code.note != null)
                                Text(
                                  code.note!,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textMid,
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: code.isActive,
                          activeTrackColor: AppColors.primary,
                          onChanged: (_) => adminCubit.toggleInviteCode(code.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          color: AppColors.danger,
                          onPressed: () => adminCubit.revokeInviteCode(code.id),
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
}
