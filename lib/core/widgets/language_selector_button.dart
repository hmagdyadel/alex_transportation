import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/localization/locale_cubit.dart';
class _LanguageOption {
  final String code;
  final String flag;
  final String shortLabel;
  final String title;
  final String subtitle;

  const _LanguageOption({
    required this.code,
    required this.flag,
    required this.shortLabel,
    required this.title,
    required this.subtitle,
  });
}

const List<_LanguageOption> _kLanguages = [
  _LanguageOption(
    code: 'en',
    flag: '🇬🇧',
    shortLabel: 'EN',
    title: 'English',
    subtitle: 'English',
  ),
  _LanguageOption(
    code: 'ar',
    flag: '🇪🇬',
    shortLabel: 'عربي',
    title: 'العربية',
    subtitle: 'Arabic',
  ),
  _LanguageOption(
    code: 'it',
    flag: '🇮🇹',
    shortLabel: 'IT',
    title: 'Italiano',
    subtitle: 'Italian',
  ),
];

/// Interactive fintech capsule pill to switch between English, Arabic, and Italian.
/// Replaces the generic world/globe icon with an active country flag, locale code,
/// and smooth dropdown menu.
class LanguageSelectorButton extends StatelessWidget {
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final EdgeInsetsGeometry? margin;
  final bool showText;

  const LanguageSelectorButton({
    super.key,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.margin,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final activeOption = _kLanguages.firstWhere(
      (lang) => lang.code == currentLocale.languageCode,
      orElse: () => _kLanguages.first,
    );

    final effectiveTextColor = textColor ?? iconColor ?? AppColors.textPrimary;
    final effectiveBorderColor = borderColor ?? AppColors.border;
    final effectiveBgColor = backgroundColor ?? AppColors.surface;

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.xxs),
      child: PopupMenuButton<String>(
        tooltip: 'Change Language / تغيير اللغة / Cambia Lingua',
        borderRadius: AppRadius.borderPill,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        position: PopupMenuPosition.under,
        offset: const Offset(0, 8),
        onSelected: (langCode) {
          context.read<LocaleCubit>().setLanguageCode(langCode);
        },
        itemBuilder: (ctx) => _kLanguages.map((lang) {
          final isSelected = lang.code == currentLocale.languageCode;
          return PopupMenuItem<String>(
            value: lang.code,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang.title,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        lang.subtitle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: AppRadius.borderPill,
            border: Border.all(color: effectiveBorderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                activeOption.flag,
                style: const TextStyle(fontSize: 14, height: 1.1),
              ),
              if (showText) ...[
                const SizedBox(width: 5),
                Text(
                  activeOption.shortLabel,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: effectiveTextColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
              const SizedBox(width: 3),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: effectiveTextColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
