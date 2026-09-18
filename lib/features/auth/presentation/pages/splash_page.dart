import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';

/// Splash screen showing AlexBank Transit visual identity and directing
/// to Onboarding, Access Gate, or Home based on local session state.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    _handleRouting();
  }

  Future<void> _handleRouting() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final authCubit = context.read<AuthCubit>();
    final hasOnboarded = await authCubit.isOnboardingCompleted();

    if (!mounted) return;

    if (!hasOnboarded) {
      context.go('/onboarding');
      return;
    }

    final hasSession = await authCubit.hasActiveSession();
    if (!mounted) return;

    if (hasSession) {
      final role = await authCubit.getUserRole();
      if (!mounted) return;
      if (role == 'driver') {
        context.go('/driver');
      } else if (role == 'admin') {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    } else {
      context.go('/access');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B4332), // Emerald deep
              Color(0xFF143628),
              Color(0xFF0D251B), // Dark forest
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // Center Branding
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Official AlexBank Logo Container
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const AlexLogo(size: 88),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Brand Name
                      Text(
                        l10n.appName,
                        textAlign: TextAlign.center,
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.accentGold,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.splashSlogan,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.surface.withValues(alpha: 0.8),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Indicator & Footer
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomLoadingIndicator(size: 36),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.accessGateSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
