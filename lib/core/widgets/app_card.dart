import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';

/// Card container styled with Transit design tokens.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final BorderSide borderSide;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.backgroundColor = AppColors.surface,
    this.borderSide = const BorderSide(color: AppColors.border),
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.borderLg,
      side: borderSide,
    );

    return Material(
      color: backgroundColor,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
