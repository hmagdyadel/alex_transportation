import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/services/secure_prefs.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';

/// Modal bottom sheet prompting the user to activate biometric authentication.
class EnableBiometricBottomSheet extends StatelessWidget {
  final VoidCallback onContinue;

  const EnableBiometricBottomSheet({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Close / Skip top row
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await SecurePrefs.setBiometricAction('skipped');
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      onContinue();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.enableBiometricTitle,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Icon Graphic
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 42,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              context.l10n.enableBiometricMessage,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Enable Primary Action
            AppButton(
              label: context.l10n.enableButton,
              leadingIcon: const Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
              ),
              onPressed: () async {
                final isl = cubit.lastIsl;
                final password = cubit.lastPassword;
                final role = cubit.lastRole;
                final name = cubit.lastName;

                if (isl != null && password != null) {
                  await cubit.enableBiometricLogin(
                    isl: isl,
                    password: password,
                    role: role ?? 'employee',
                    name: name ?? 'Bank Employee',
                  );
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                  onContinue();
                }
              },
            ),
            const SizedBox(height: AppSpacing.xs),

            // Skip Secondary Action
            TextButton(
              onPressed: () async {
                await SecurePrefs.setBiometricAction('skipped');
                if (context.mounted) {
                  Navigator.of(context).pop();
                  onContinue();
                }
              },
              child: Text(
                context.l10n.skipButton,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMid,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
