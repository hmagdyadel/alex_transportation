import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_request_model.dart';

/// Compact request history card showing mission details and status.
class ErrandRequestHistoryCard extends StatelessWidget {
  final ErrandRequestModel request;
  final VoidCallback? onCancel;

  const ErrandRequestHistoryCard({
    super.key,
    required this.request,
    this.onCancel,
  });

  StatusPillType _statusPillType(String status) {
    switch (status) {
      case 'pending':
        return StatusPillType.pending;
      case 'approved':
      case 'in_progress':
        return StatusPillType.active;
      case 'completed':
        return StatusPillType.neutral;
      case 'rejected':
      case 'cancelled':
        return StatusPillType.danger;
      default:
        return StatusPillType.neutral;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'in_progress':
        return Icons.directions_car_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.block_rounded;
      default:
        return Icons.help_outline;
    }
  }

  String _localizedStatus(BuildContext context, String status) {
    final l10n = context.l10n;
    switch (status) {
      case 'pending':
        return l10n.pending.toUpperCase();
      case 'approved':
        return l10n.approved.toUpperCase();
      case 'in_progress':
        return l10n.active.toUpperCase();
      case 'completed':
        return l10n.completed.toUpperCase();
      case 'rejected':
        return l10n.rejected.toUpperCase();
      case 'cancelled':
        return l10n.cancelled.toUpperCase();
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canCancel =
        request.status == 'pending' || request.status == 'approved';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top: Request ID + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _statusIcon(request.status),
                    size: 18,
                    color:
                        request.status == 'completed' ||
                            request.status == 'approved' ||
                            request.status == 'in_progress'
                        ? AppColors.primaryMid
                        : request.status == 'pending'
                        ? AppColors.accentGold
                        : AppColors.danger,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    request.id,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              StatusPill(
                label: _localizedStatus(context, request.status),
                type: _statusPillType(request.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Pickup -> Destination + Purpose
          Row(
            children: [
              const Icon(
                Icons.trip_origin_rounded,
                size: 14,
                color: AppColors.accentGold,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  request.pickupLocation,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMid,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  request.destination,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            request.purpose,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: AppColors.textMid),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Date + Time Row
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                request.requestedDate,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${request.requestedTime} → ${request.estimatedReturnTime}',
                style: AppTypography.caption.copyWith(color: AppColors.textMid),
              ),
            ],
          ),

          // Assigned vehicle (if any)
          if (request.assignedCarMake != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.directions_car_filled_rounded,
                  size: 14,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  '${request.assignedCarMake} — ${request.assignedCarPlate}',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryMid,
                  ),
                ),
              ],
            ),
          ],

          // Cancel button for pending/approved
          if (canCancel && onCancel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: Text(l10n.errandCancelRequestAction),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                ),
                onPressed: onCancel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
