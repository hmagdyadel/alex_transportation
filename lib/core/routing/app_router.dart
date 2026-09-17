import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:alex_transportation/core/design_system/tokens.dart';

/// App-wide router configuration.
///
/// Phase 0: all routes point to placeholder screens.
/// Each phase replaces placeholders with real page widgets.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const _PlaceholderScreen(title: 'Splash'),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Onboarding'),
      ),
      GoRoute(
        path: '/access',
        name: 'access',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Invite Code'),
      ),
      // Employee home with module tabs
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Home — Employee'),
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
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Driver Portal'),
      ),
      // Admin panel
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Admin Panel'),
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
