import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/di/injector.dart';
import 'package:alex_transportation/core/widgets/alex_logo.dart';
import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/admin_states.dart';
import 'package:alex_transportation/features/admin/presentation/widgets/access_admin_view.dart';
import 'package:alex_transportation/features/admin/presentation/widgets/bus_admin_view.dart';
import 'package:alex_transportation/features/admin/presentation/widgets/driver_admin_view.dart';
import 'package:alex_transportation/features/admin/presentation/widgets/errand_admin_view.dart';
import 'package:alex_transportation/features/admin/presentation/widgets/garage_admin_view.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_cubit.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_cubit.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';

/// Master Admin Portal console page.
/// Coordinates all 5 enterprise transport pillars with live management.
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminCubit>(create: (_) => AdminCubit()),
        BlocProvider<BusCubit>(create: (_) => sl<BusCubit>()),
        BlocProvider<GarageCubit>(create: (_) => sl<GarageCubit>()),
        BlocProvider<ErrandCarCubit>(create: (_) => sl<ErrandCarCubit>()),
      ],
      child: const _AdminPageContent(),
    );
  }
}

class _AdminPageContent extends StatefulWidget {
  const _AdminPageContent();

  @override
  State<_AdminPageContent> createState() => _AdminPageContentState();
}

class _AdminPageContentState extends State<_AdminPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    Tab(icon: Icon(Icons.directions_bus_rounded), text: 'Buses'),
    Tab(icon: Icon(Icons.local_parking_rounded), text: 'Garage'),
    Tab(icon: Icon(Icons.directions_car_rounded), text: 'Errand'),
    Tab(icon: Icon(Icons.badge_rounded), text: 'Drivers'),
    Tab(icon: Icon(Icons.vpn_key_rounded), text: 'Access'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminCubit, AdminStates>(
      listener: (context, state) {
        switch (state) {
          case Success(:final data):
            if (data is String) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
        final isLoading = state is Loading ||
            state is GeneratingCode ||
            state is Approving ||
            state is Rejecting;

        return ModalProgressHUD(
          inAsyncCall: isLoading,
          progressIndicator: const CustomLoadingIndicator(size: 64),
          color: Colors.black,
          opacity: 0.5,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              centerTitle: false,
              title: Row(
                children: [
                  const AlexLogo(size: 26),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AlexBank Operations',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'CENTRAL MOBILITY CONSOLE',
                          style: AppTypography.caption.copyWith(
                            fontSize: 9,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentGold,
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
                IconButton(
                  tooltip: 'Switch to Employee View',
                  icon: const Icon(Icons.home_outlined, color: AppColors.primary),
                  onPressed: () => context.go('/home'),
                ),
                IconButton(
                  tooltip: 'Exit to Access Gate',
                  icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                  onPressed: () => context.go('/access'),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                tabs: _tabs,
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: const [
                BusAdminView(),
                GarageAdminView(),
                ErrandAdminView(),
                DriverAdminView(),
                AccessAdminView(),
              ],
            ),
          ),
        );
      },
    );
  }
}
