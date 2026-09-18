import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/app_text_field.dart';
import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_states.dart';

/// Invite-code gate screen verifying employee credentials.
/// Implements the user's required ModalProgressHUD + CustomLoadingIndicator loading standard.
class AccessGatePage extends StatefulWidget {
  const AccessGatePage({super.key});

  @override
  State<AccessGatePage> createState() => _AccessGatePageState();
}

class _AccessGatePageState extends State<AccessGatePage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    context.read<AuthCubit>().verifyInviteCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          switch (state) {
            case Success(:final data):
              if (data == 'admin') {
                context.go('/admin');
              } else if (data == 'driver') {
                context.go('/driver');
              } else {
                context.go('/home');
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
          final isLoading = state is Loading || state is VerifyingCode;

          return ModalProgressHUD(
            inAsyncCall: isLoading,
            progressIndicator: const CustomLoadingIndicator(size: 64),
            color: Colors.black,
            opacity: 0.5,
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Official AlexBank Logo
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const AlexLogo(size: 72),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Title
                        Text(
                          'ALEXBANK TRANSIT',
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Employee Transport & Mobility Portal',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Form Card
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Employee Verification',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                'Enter your invite code provided by Fleet Management to unlock parking, buses, and errand dispatch.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMid,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Invite Code Input
                              AppTextField(
                                controller: _codeController,
                                label: 'INVITE CODE',
                                hint: 'e.g. ALEX26',
                                prefixIcon: const Icon(
                                  Icons.vpn_key_rounded,
                                  color: AppColors.accentGold,
                                  size: 20,
                                ),
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]'),
                                  ),
                                  UpperCaseTextFormatter(),
                                ],
                                onSubmitted: (_) => _submitCode(),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Quick demo helper chips for testing
                              Wrap(
                                spacing: AppSpacing.xs,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Demo codes:',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  ActionChip(
                                    label: const Text('ALEX26 (Employee)'),
                                    onPressed: () {
                                      _codeController.text = 'ALEX26';
                                    },
                                    backgroundColor: AppColors.greenLight,
                                    labelStyle: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primaryMid,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  ActionChip(
                                    label: const Text('DRIVER'),
                                    onPressed: () {
                                      _codeController.text = 'DRIVER';
                                    },
                                    backgroundColor: AppColors.greenLight,
                                    labelStyle: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  ActionChip(
                                    label: const Text('ADMIN'),
                                    onPressed: () {
                                      _codeController.text = 'ADMIN';
                                    },
                                    backgroundColor: AppColors.goldLight,
                                    labelStyle: AppTypography.labelSmall.copyWith(
                                      color: AppColors.accentGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Submit Button
                              AppButton(
                                label: 'Verify Code',
                                variant: AppButtonVariant.primary,
                                onPressed: _submitCode,
                                leadingIcon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.headset_mic_outlined,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Fleet Admin Helpdesk: ext. 4200',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
