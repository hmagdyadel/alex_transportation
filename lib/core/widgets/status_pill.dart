import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';

enum StatusPillType { active, pending, danger, neutral, gold }

/// Status badge pill styled with Transit design tokens.
class StatusPill extends StatelessWidget {
  final String label;
  final StatusPillType type;
  final Widget? icon;

  const StatusPill({
    super.key,
    required this.label,
    this.type = StatusPillType.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case StatusPillType.active:
        bg = AppColors.greenLight;
        fg = AppColors.primaryMid;
        break;
      case StatusPillType.pending:
        bg = AppColors.goldLight;
        fg = AppColors.accentGold;
        break;
      case StatusPillType.danger:
        bg = AppColors.dangerLight;
        fg = AppColors.danger;
        break;
      case StatusPillType.gold:
        bg = AppColors.goldLight;
        fg = AppColors.accentGold;
        break;
      case StatusPillType.neutral:
        bg = AppColors.blueLight;
        fg = AppColors.accentBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
