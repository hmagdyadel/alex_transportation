import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/language_selector_button.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';

class OnboardingSlideItem {
  final String lottieAsset;
  final String Function(BuildContext) getTag;
  final String Function(BuildContext) getTitle;
  final String Function(BuildContext) getDescription;

  const OnboardingSlideItem({
    required this.lottieAsset,
    required this.getTag,
    required this.getTitle,
    required this.getDescription,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static final List<OnboardingSlideItem> _slides = [
    OnboardingSlideItem(
      lottieAsset: 'assets/lottie/garage_parking.json',
      getTag: (ctx) => ctx.l10n.moduleGarage.toUpperCase(),
      getTitle: (ctx) => ctx.l10n.onboardingSlide1Title,
      getDescription: (ctx) => ctx.l10n.onboardingSlide1Desc,
    ),
    OnboardingSlideItem(
      lottieAsset: 'assets/lottie/bus_shuttle.json',
      getTag: (ctx) => ctx.l10n.moduleBuses.toUpperCase(),
      getTitle: (ctx) => ctx.l10n.onboardingSlide2Title,
      getDescription: (ctx) => ctx.l10n.onboardingSlide2Desc,
    ),
    OnboardingSlideItem(
      lottieAsset: 'assets/lottie/errand_dispatch.json',
      getTag: (ctx) => ctx.l10n.moduleErrandCars.toUpperCase(),
      getTitle: (ctx) => ctx.l10n.onboardingSlide3Title,
      getDescription: (ctx) => ctx.l10n.onboardingSlide3Desc,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final authCubit = context.read<AuthCubit>();
    await authCubit.markOnboardingCompleted();
    if (!mounted) return;
    context.go('/access');
  }

  void _nextPage() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLast = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AlexLogo(size: 32),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.alexBank,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const LanguageSelectorButton(),
                      if (!isLast)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            l10n.onboardingSkip,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 3D Fintech Lottie Animation Container
                        Container(
                          width: double.infinity,
                          height: 270,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Lottie.asset(
                            slide.lottieAsset,
                            fit: BoxFit.cover,
                            repeat: true,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: AppRadius.borderPill,
                          ),
                          child: Text(
                            slide.getTag(context),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryMid,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Title
                        Text(
                          slide.getTitle(context),
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Description
                        Text(
                          slide.getDescription(context),
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textMid,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action Button
                  AppButton(
                    label: isLast
                        ? l10n.onboardingGetStarted
                        : l10n.onboardingNext,
                    variant: AppButtonVariant.primary,
                    onPressed: _nextPage,
                    leadingIcon: isLast
                        ? const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.accentGold,
                            size: 20,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
