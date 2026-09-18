import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';
import 'package:alex_transportation/core/di/injector.dart';
import 'package:alex_transportation/features/auth/presentation/pages/access_gate_page.dart';
import 'package:alex_transportation/features/auth/presentation/pages/onboarding_page.dart';
import 'package:alex_transportation/features/auth/presentation/pages/splash_page.dart';
import 'package:alex_transportation/features/driver/presentation/bloc/driver_cubit.dart';
import 'package:alex_transportation/features/driver/presentation/pages/driver_page.dart';
import 'package:alex_transportation/features/admin/presentation/pages/admin_page.dart';
import 'package:alex_transportation/features/home/presentation/pages/home_page.dart';

/// App-wide router configuration.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/access',
        name: 'access',
        builder: (context, state) => const AccessGatePage(),
      ),
      // Employee home with module tabs
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'garage',
            name: 'garage',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Garage'),
          ),
          GoRoute(
            path: 'buses',
            name: 'buses',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Buses'),
            routes: [
              GoRoute(
                path: ':busId',
                name: 'bus-detail',
                builder: (context, state) => _PlaceholderScreen(
                  title: 'Bus ${state.pathParameters['busId']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'errand',
            name: 'errand',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Errand Cars'),
          ),
        ],
      ),
      // Driver portal
      GoRoute(
        path: '/driver',
        name: 'driver',
        builder: (context, state) => BlocProvider<DriverCubit>(
          create: (_) => sl<DriverCubit>(),
          child: const DriverPage(),
        ),
      ),
      // Admin panel
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminPage(),
      ),
    ],
  );
}

/// Temporary placeholder used until real screens are built.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction_rounded,
              size: 48,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
