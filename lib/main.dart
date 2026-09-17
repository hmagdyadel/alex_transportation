import 'package:flutter/material.dart';

import 'package:alex_transportation/core/design_system/theme.dart';
import 'package:alex_transportation/core/di/injector.dart';
import 'package:alex_transportation/core/network/firebase_client.dart';
import 'package:alex_transportation/core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase — fails gracefully without config files (Phase 0 stub mode)
  await FirebaseClient.initialize();

  // Dependency injection
  await setupInjector();

  runApp(const TransitApp());
}

class TransitApp extends StatelessWidget {
  const TransitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Transit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: AppRouter.router,
    );
  }
}
