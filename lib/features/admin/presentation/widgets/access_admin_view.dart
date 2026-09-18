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
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';

/// Access & Security administration view.
/// Allows provisioning new Admin accounts, toggling to employee mode (dual-access),
/// generating invite codes, and managing security.
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

  void _showAddAdminDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final islCtrl = TextEditingController(text: 'ADM-');
    final deptCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'alex123');

    showDialog<void>(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.accentGold,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text(
                'Provision New Admin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create an authorized administrator account with full console management access.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMid),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: nameCtrl,
                label: 'ADMIN FULL NAME',
                hint: 'e.g. Tamer El-Sayed',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: islCtrl,
                label: 'BANK STAFF ISL',
                hint: 'e.g. ADM-9003',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: deptCtrl,
                label: 'DEPARTMENT / DIVISION',
                hint: 'e.g. Corporate Security & IT',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: passCtrl,
                label: 'INITIAL PASSWORD',
                hint: 'Minimum 4 characters',
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final isl = islCtrl.text.trim();
              final dept = deptCtrl.text.trim();
              final pass = passCtrl.text.trim();

              if (name.isEmpty || isl.isEmpty || pass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in Name, ISL, and Password'),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              await context.read<AuthCubit>().registerNewAdmin(
                    isl: isl,
                    name: name,
                    department: dept.isEmpty ? 'Central Operations' : dept,
                    password: pass,
                  );

              if (context.mounted) {
                Navigator.of(dlgCtx).pop();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Admin $name ($isl) provisioned successfully!'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Provision Admin'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    final adminAccounts = authCubit.adminAccounts;

    return BlocBuilder<AdminCubit, AdminStates>(
      builder: (context, state) {
        final adminCubit = context.read<AdminCubit>();
        final codes = adminCubit.inviteCodes;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Admin Dual Access / Staff Mode Switcher Card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                backgroundColor: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.accentGold,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'ADMIN DUAL ACCESS & MOBILITY',
                          style: AppTypography.labelSmall.copyWith(
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'As an Administrator, you can switch to Employee Mode to park in the garage, book bus lines, or request errand cars — and return to this console anytime.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Open Staff Services (Garage/Buses)',
                            leadingIcon: const Icon(Icons.directions_bus_rounded, size: 16),
                            variant: AppButtonVariant.primary,
                            onPressed: () => context.go('/home'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: 'Inspect Driver HUD',
                          leadingIcon: const Icon(Icons.speed_rounded, size: 16),
                          variant: AppButtonVariant.secondary,
                          onPressed: () => context.go('/driver'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Admin Accounts Management Section
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
                              'ADMINISTRATOR ACCOUNTS (${adminAccounts.length})',
                              style: AppTypography.labelSmall.copyWith(
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Staff members with full fleet administration access',
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.person_add_rounded, size: 16),
                          label: const Text('+ Add Admin'),
                          onPressed: () => _showAddAdminDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xs),
                    ...adminAccounts.map((admin) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.goldLight,
                                child: Text(
                                  admin.name.isNotEmpty ? admin.name[0] : 'A',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          admin.name,
                                          style: AppTypography.bodySmall.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            admin.isl,
                                            style: AppTypography.caption.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Dept: ${admin.department}',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const StatusPill(
                                label: 'ACTIVE ADMIN',
                                type: StatusPillType.gold,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                        ButtonSegment(value: 'employee', label: Text('Normal User')),
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
