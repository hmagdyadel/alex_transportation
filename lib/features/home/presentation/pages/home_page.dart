import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/di/injector.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';
import 'package:alex_transportation/features/garage/presentation/pages/garage_page.dart';

/// Employee Home shell providing access to:
/// 1. Garage Parking Pass & Management (Phase 2 - Active)
/// 2. Bus Routes & Tracking (Phase 3 - Coming Soon)
/// 3. Errand Car Request (Phase 4 - Coming Soon)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedModuleIndex = 0;

  static const List<_ModuleInfo> _modules = [
    _ModuleInfo(
      title: 'Garage',
      icon: Icons.local_parking_rounded,
      badge: 'Active',
    ),
    _ModuleInfo(
      title: 'Buses',
      icon: Icons.directions_bus_rounded,
      badge: 'Phase 3',
    ),
    _ModuleInfo(
      title: 'Errand Cars',
      icon: Icons.directions_car_rounded,
      badge: 'Phase 4',
    ),
  ];

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Sign Out',
          style: AppTypography.titleLarge,
        ),
        content: Text(
          'Are you sure you want to end your current session?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textMid,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthCubit>().signOut();
              context.go('/access');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black12,
        titleSpacing: AppSpacing.md,
        title: Row(
          children: [
            const AlexLogo(size: 34),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALEXBANK',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Transit — Employee Portal',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMid,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          const StatusPill(
            label: 'EMPLOYEE',
            type: StatusPillType.active,
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: 'Sign Out',
            onPressed: _showLogoutDialog,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: List.generate(_modules.length, (index) {
                final module = _modules[index];
                final isSelected = _selectedModuleIndex == index;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _selectedModuleIndex = index),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              module.icon,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textMid,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                module.title,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelMedium.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedModuleIndex,
        children: [
          // Module 0: Garage Parking (Phase 2 - Live)
          BlocProvider<GarageCubit>(
            create: (_) => sl<GarageCubit>()..loadGarageData(),
            child: const GaragePage(),
          ),

          // Module 1: Bus Transit (Phase 3 - Coming Soon)
          _buildComingSoonView(
            title: 'Bus Transit System',
            phase: 'Phase 3',
            icon: Icons.directions_bus_rounded,
            description:
                'Real-time AlexBank employee shuttle tracking, route schedules, stop manifests, and digital boarding passes.',
          ),

          // Module 2: Errand Car Request (Phase 4 - Coming Soon)
          _buildComingSoonView(
            title: 'Official Errand Cars',
            phase: 'Phase 4',
            icon: Icons.directions_car_rounded,
            description:
                'On-demand official bank vehicle booking for daytime corporate tasks, supervisor approvals, and mileage logs.',
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonView({
    required String title,
    required String phase,
    required IconData icon,
    required String description,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          backgroundColor: AppColors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              StatusPill(
                label: phase.toUpperCase(),
                type: StatusPillType.gold,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                icon: const Icon(Icons.local_parking_rounded, size: 18),
                label: const Text('Go to Garage Module'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onPressed: () => setState(() => _selectedModuleIndex = 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleInfo {
  final String title;
  final IconData icon;
  final String badge;

  const _ModuleInfo({
    required this.title,
    required this.icon,
    required this.badge,
  });
}
