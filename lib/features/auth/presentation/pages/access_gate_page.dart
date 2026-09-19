import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/services/biometric_helper.dart';
import 'package:alex_transportation/core/services/secure_prefs.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/app_text_field.dart';
import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';
import 'package:alex_transportation/core/widgets/language_selector_button.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_states.dart';
import 'package:alex_transportation/features/auth/presentation/widgets/enable_biometric_bottom_sheet.dart';

/// Bank Staff ISL + Password login and registration screen with role selection and Biometric login.
/// Strictly segregates access between Normal User, Driver, and Admin.
class AccessGatePage extends StatefulWidget {
  const AccessGatePage({super.key});

  @override
  State<AccessGatePage> createState() => _AccessGatePageState();
}

class _AccessGatePageState extends State<AccessGatePage> {
  bool _isRegisterMode = false;

  // Sign In Controllers
  final TextEditingController _islController = TextEditingController(
    text: '10492',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'alex123',
  );
  String _selectedRole = 'employee'; // 'employee', 'driver', 'admin'
  bool _obscurePassword = true;

  // Registration Controllers
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regIslController = TextEditingController();
  final TextEditingController _regDeptController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regConfirmPasswordController =
      TextEditingController();
  String _regSelectedRole = 'employee';

  bool _hasBiometrics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricStatus();
      _checkAndTriggerBiometric();
    });
  }

  @override
  void dispose() {
    _islController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regIslController.dispose();
    _regDeptController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricStatus() async {
    final isSupported = await BiometricHelper.isBiometricSupported();
    if (!mounted) return;
    final hasCreds = await context
        .read<AuthCubit>()
        .hasSavedBiometricCredentials();
    if (mounted) {
      setState(() {
        _hasBiometrics = isSupported && hasCreds;
      });
    }
  }

  /// Automatically trigger biometric prompt if user previously enabled it
  Future<void> _checkAndTriggerBiometric() async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    final cubit = context.read<AuthCubit>();
    final isEnabled = await SecurePrefs.isBiometricEnabled();
    final hasCreds = await cubit.hasSavedBiometricCredentials();

    if (isEnabled && hasCreds && mounted) {
      await cubit.loginWithBiometrics();
    }
  }

  void _submitLogin() {
    final l10n = context.l10n;
    final isl = _islController.text.trim();
    final password = _passwordController.text.trim();

    if (isl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterIslError),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterPasswordError),
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

  void _submitRegister() {
    final l10n = context.l10n;
    final name = _regNameController.text.trim();
    final isl = _regIslController.text.trim();
    final dept = _regDeptController.text.trim();
    final password = _regPasswordController.text.trim();
    final confirm = _regConfirmPasswordController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Full Name'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (isl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterIslError),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterPasswordError),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordsDoNotMatch),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthCubit>().registerAccount(
      isl: isl,
      name: name,
      department: dept.isEmpty ? 'General' : dept,
      role: _regSelectedRole,
      password: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) async {
          switch (state) {
            case Success(:final data):
              void navigate() {
                if (data == 'admin') {
                  context.go('/admin');
                } else if (data == 'driver') {
                  context.go('/driver');
                } else {
                  context.go('/home');
                }
              }

              final isBiometricSupported =
                  await BiometricHelper.isBiometricSupported();
              final isBiometricEnabled = await SecurePrefs.isBiometricEnabled();
              final biometricAction = await SecurePrefs.getBiometricAction();

              // Prompt for biometric setup if device supports it and user hasn't decided yet
              if (isBiometricSupported &&
                  !isBiometricEnabled &&
                  biometricAction == null &&
                  context.mounted) {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  enableDrag: false,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BlocProvider.value(
                    value: context.read<AuthCubit>(),
                    child: EnableBiometricBottomSheet(onContinue: navigate),
                  ),
                );
              } else {
                navigate();
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
                        // Top row with Language Selector
                        const Align(
                          alignment: Alignment.topRight,
                          child: LanguageSelectorButton(),
                        ),
                        const SizedBox(height: AppSpacing.sm),

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

                        // Title & Subtitle
                        Text(
                          l10n.accessGateTitle,
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          l10n.accessGateSubtitle,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Form Card (Sign In OR Register Mode)
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: _isRegisterMode
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: _buildSignInForm(context, l10n),
                            secondChild: _buildRegisterForm(context, l10n),
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
                              l10n.helpdeskFooter,
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

  // ==================== SIGN IN FORM ====================

  Widget _buildSignInForm(BuildContext context, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.signInCardTitle,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l10n.signInCardSubtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMid,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Role Selection
        Text(
          l10n.selectRoleLabel,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMid,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'employee',
              icon: const Icon(Icons.person_rounded, size: 16),
              label: Text(l10n.roleNormalUser),
            ),
            ButtonSegment(
              value: 'driver',
              icon: const Icon(Icons.directions_bus_rounded, size: 16),
              label: Text(l10n.roleDriver),
            ),
            ButtonSegment(
              value: 'admin',
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
              label: Text(l10n.roleAdmin),
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
          label: l10n.staffIslLabel,
          hint: l10n.staffIslHint,
          prefixIcon: const Icon(
            Icons.badge_outlined,
            color: AppColors.accentGold,
            size: 20,
          ),
          textInputAction: TextInputAction.next,
          inputFormatters: [UpperCaseTextFormatter()],
        ),
        const SizedBox(height: AppSpacing.md),

        // Password Input
        AppTextField(
          controller: _passwordController,
          label: l10n.passwordLabel,
          hint: l10n.passwordHint,
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
        const SizedBox(height: AppSpacing.lg),

        // Submit Button
        AppButton(
          label: l10n.signInButton,
          variant: AppButtonVariant.primary,
          onPressed: _submitLogin,
          leadingIcon: const Icon(
            Icons.login_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),

        // Biometric Quick Action Button (if supported & configured)
        if (_hasBiometrics) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.loginWithBiometrics,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.read<AuthCubit>().loginWithBiometrics(),
            leadingIcon: const Icon(
              Icons.fingerprint_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        // Toggle to Registration Mode
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isRegisterMode = true),
            child: Text(
              l10n.notHaveAccountPrompt,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== REGISTRATION FORM ====================

  Widget _buildRegisterForm(BuildContext context, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.registerCardTitle,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l10n.registerCardSubtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMid,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Role Selection
        Text(
          l10n.selectRoleLabel,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMid,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'employee',
              icon: const Icon(Icons.person_rounded, size: 16),
              label: Text(l10n.roleNormalUser),
            ),
            ButtonSegment(
              value: 'driver',
              icon: const Icon(Icons.directions_bus_rounded, size: 16),
              label: Text(l10n.roleDriver),
            ),
            ButtonSegment(
              value: 'admin',
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
              label: Text(l10n.roleAdmin),
            ),
          ],
          selected: {_regSelectedRole},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _regSelectedRole = newSelection.first;
            });
          },
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Full Name
        AppTextField(
          controller: _regNameController,
          label: l10n.fullNameLabel,
          hint: l10n.fullNameHint,
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.accentGold,
            size: 20,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Bank Staff ISL Input
        AppTextField(
          controller: _regIslController,
          label: l10n.staffIslLabel,
          hint: l10n.staffIslHint,
          prefixIcon: const Icon(
            Icons.badge_outlined,
            color: AppColors.accentGold,
            size: 20,
          ),
          textInputAction: TextInputAction.next,
          inputFormatters: [UpperCaseTextFormatter()],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Department
        AppTextField(
          controller: _regDeptController,
          label: l10n.adminDeptLabel,
          hint: 'e.g. Retail Banking, Operations, IT',
          prefixIcon: const Icon(
            Icons.business_rounded,
            color: AppColors.accentGold,
            size: 20,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Password Input
        AppTextField(
          controller: _regPasswordController,
          label: l10n.passwordLabel,
          hint: l10n.passwordHint,
          obscureText: _obscurePassword,
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.accentGold,
            size: 20,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Confirm Password Input
        AppTextField(
          controller: _regConfirmPasswordController,
          label: l10n.confirmPasswordLabel,
          hint: l10n.confirmPasswordHint,
          obscureText: _obscurePassword,
          prefixIcon: const Icon(
            Icons.lock_reset_rounded,
            color: AppColors.accentGold,
            size: 20,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitRegister(),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Register Button
        AppButton(
          label: l10n.registerButton,
          variant: AppButtonVariant.primary,
          onPressed: _submitRegister,
          leadingIcon: const Icon(
            Icons.person_add_alt_1_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Toggle back to Sign In
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isRegisterMode = false),
            child: Text(
              l10n.haveAccountPrompt,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
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
