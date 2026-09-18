import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';

enum AppButtonVariant { primary, secondary, outline, text }

/// Standard button component adhering to Transit design tokens.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? leadingIcon;
  final bool isExpanded;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    this.isExpanded = true,
    this.height = 50,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isEnabled ? AppColors.primary : AppColors.border;
        foregroundColor = isEnabled ? Colors.white : AppColors.textSecondary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isEnabled ? AppColors.greenLight : AppColors.background;
        foregroundColor = isEnabled ? AppColors.primary : AppColors.textSecondary;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? AppColors.primary : AppColors.textSecondary;
        borderSide = BorderSide(
          color: isEnabled ? AppColors.primary : AppColors.border,
          width: 1.5,
        );
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = isEnabled ? AppColors.primaryMid : AppColors.textSecondary;
        break;
    }

    Widget content = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          leadingIcon!,
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: height,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: content,
          ),
        ),
      ),
    );
  }
}
