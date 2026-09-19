import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/di/injector.dart';
import 'package:alex_transportation/core/extensions/l10n_extension.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/language_selector_button.dart';
import 'package:alex_transportation/core/widgets/notification_feed_sheet.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:alex_transportation/features/notifications/presentation/bloc/notification_states.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_cubit.dart';
import 'package:alex_transportation/features/buses/presentation/pages/buses_page.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_cubit.dart';
import 'package:alex_transportation/features/errand_cars/presentation/pages/errand_cars_page.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';
import 'package:alex_transportation/features/garage/presentation/pages/garage_page.dart';

/// Employee Home shell providing access to:
/// 1. Garage Parking Pass & Management (Phase 2 - Active)
/// 2. Bus Routes & Tracking (Phase 3 - Active)
/// 3. Errand Car Request (Phase 4 - Active)
class HomePage extends StatefulWidget {
  final int initialModuleIndex;

  const HomePage({super.key, this.initialModuleIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedModuleIndex;

  @override
  void initState() {
    super.initState();
    _selectedModuleIndex = widget.initialModuleIndex;
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialModuleIndex != widget.initialModuleIndex) {
      _selectedModuleIndex = widget.initialModuleIndex;
    }
  }

  void _showLogoutDialog() {
    final l10n = context.l10n;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          l10n.signOutConfirmTitle,
          style: AppTypography.titleLarge,
        ),
        content: Text(
          l10n.signOutConfirmMessage,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.cancel,
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
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authCubit = context.watch<AuthCubit>();
    final userRole = authCubit.currentRole;
    final isAdmin = authCubit.isAdmin;

    final moduleTitles = [
      l10n.moduleGarage,
      l10n.moduleBuses,
      l10n.moduleErrandCars,
    ];

    final moduleIcons = [
      Icons.local_parking_rounded,
      Icons.directions_bus_rounded,
      Icons.directions_car_rounded,
    ];

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
            const AlexLogo(size: 32),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.alexBank,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isAdmin
                        ? l10n.adminEmployeeModeSubtitle
                        : l10n.employeePortalSubtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMid,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          const LanguageSelectorButton(),
          _NotificationBell(),
          StatusPill(
            label: isAdmin
                ? (userRole == 'employee' ? l10n.roleAdminUserMode : l10n.roleAdminBadge)
                : l10n.roleEmployee,
            type: isAdmin ? StatusPillType.gold : StatusPillType.active,
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.accentGold,
                size: 22,
              ),
              tooltip: l10n.returnToAdminTooltip,
              onPressed: () => context.go('/admin'),
            ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: l10n.signOut,
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
              children: List.generate(moduleTitles.length, (index) {
                final isSelected = _selectedModuleIndex == index;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedModuleIndex = index);
                      },
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
                              moduleIcons[index],
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textMid,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                moduleTitles[index],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: AppTypography.labelSmall.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
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
          // Module 1: Garage Parking
          BlocProvider<GarageCubit>(
            create: (_) => sl<GarageCubit>(),
            child: const GaragePage(),
          ),
          // Module 2: Buses Transit
          BlocProvider<BusCubit>(
            create: (_) => sl<BusCubit>(),
            child: const BusesPage(),
          ),
          // Module 3: Errand Cars
          BlocProvider<ErrandCarCubit>(
            create: (_) => sl<ErrandCarCubit>(),
            child: const ErrandCarsPage(),
          ),
        ],
      ),
    );
  }
}

/// Notification bell icon with unread badge opening the interactive NotificationFeedSheet.
class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationStates>(
      builder: (context, _) {
        final cubit = context.read<NotificationCubit>();
        final unread = cubit.unreadCount;

        return IconButton(
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(
              '$unread',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primary,
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textMid,
              size: 22,
            ),
          ),
          tooltip: 'Notifications',
          onPressed: () {
            HapticFeedback.lightImpact();
            NotificationFeedSheet.show(context);
          },
        );
      },
    );
  }
}
