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

/// Bank Staff ISL + Password login screen with role selection.
/// Strictly segregates access between Normal User, Driver, and Admin.
class AccessGatePage extends StatefulWidget {
  const AccessGatePage({super.key});

  @override
  State<AccessGatePage> createState() => _AccessGatePageState();
}

class _AccessGatePageState extends State<AccessGatePage> {
  final TextEditingController _islController = TextEditingController(text: '10492');
  final TextEditingController _passwordController = TextEditingController(text: 'alex123');
  String _selectedRole = 'employee'; // 'employee', 'driver', 'admin'
  bool _obscurePassword = true;

  @override
  void dispose() {
    _islController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    final isl = _islController.text.trim();
    final password = _passwordController.text.trim();

    if (isl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Bank Staff ISL'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthCubit>().loginWithIsl(
          isl: isl,
          password: password,
          role: _selectedRole,
        );
  }

  void _applyDemoCredentials({
    required String isl,
    required String password,
    required String role,
  }) {
    setState(() {
      _islController.text = isl;
      _passwordController.text = password;
      _selectedRole = role;
    });
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
                          'Staff Transportation & Corporate Fleet Management',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Form Card
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Sign In to Transit Portal',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                'Select your role and enter your Bank ISL & Password.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMid,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Role Selection
                              Text(
                                'SELECT PORTAL ROLE',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textMid,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'employee',
                                    icon: Icon(Icons.person_rounded, size: 16),
                                    label: Text('Normal User'),
                                  ),
                                  ButtonSegment(
                                    value: 'driver',
                                    icon: Icon(Icons.directions_bus_rounded, size: 16),
                                    label: Text('Driver'),
                                  ),
                                  ButtonSegment(
                                    value: 'admin',
                                    icon: Icon(Icons.admin_panel_settings_rounded, size: 16),
                                    label: Text('Admin'),
                                  ),
                                ],
                                selected: {_selectedRole},
                                onSelectionChanged: (Set<String> newSelection) {
                                  setState(() {
                                    _selectedRole = newSelection.first;
                                  });
                                },
                                style: ButtonStyle(
                                  textStyle: WidgetStateProperty.all(
                                    AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Bank Staff ISL Input
                              AppTextField(
                                controller: _islController,
                                label: 'BANK STAFF ISL',
                                hint: 'e.g. 10492 or ADM-9001',
                                prefixIcon: const Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.accentGold,
                                  size: 20,
                                ),
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  UpperCaseTextFormatter(),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Password Input
                              AppTextField(
                                controller: _passwordController,
                                label: 'PASSWORD',
                                hint: '••••••••',
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.accentGold,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submitLogin(),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Quick demo helper chips for instant role testing
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Quick Fill:',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  ActionChip(
                                    label: const Text('Normal User (10492)'),
                                    onPressed: () {
                                      _applyDemoCredentials(
                                        isl: '10492',
                                        password: 'alex123',
                                        role: 'employee',
                                      );
                                    },
                                    backgroundColor: AppColors.greenLight,
                                    labelStyle: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primaryMid,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  ActionChip(
                                    label: const Text('Driver (DRV-2001)'),
                                    onPressed: () {
                                      _applyDemoCredentials(
                                        isl: 'DRV-2001',
                                        password: 'alex123',
                                        role: 'driver',
                                      );
                                    },
                                    backgroundColor: AppColors.greenLight,
                                    labelStyle: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  ActionChip(
                                    label: const Text('Admin (ADM-9001)'),
                                    onPressed: () {
                                      _applyDemoCredentials(
                                        isl: 'ADM-9001',
                                        password: 'alex123',
                                        role: 'admin',
                                      );
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
                                label: 'Sign In to Transit',
                                variant: AppButtonVariant.primary,
                                onPressed: _submitLogin,
                                leadingIcon: const Icon(
                                  Icons.login_rounded,
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
