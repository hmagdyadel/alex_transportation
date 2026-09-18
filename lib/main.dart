import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/design_system/theme.dart';
import 'package:alex_transportation/core/di/injector.dart';
import 'package:alex_transportation/core/localization/locale_cubit.dart';
import 'package:alex_transportation/core/network/firebase_client.dart';
import 'package:alex_transportation/core/routing/app_router.dart';
import 'package:alex_transportation/core/services/network_connectivity_service.dart';
import 'package:alex_transportation/core/services/secure_prefs.dart';
import 'package:alex_transportation/core/widgets/no_internet_screen.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:alex_transportation/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase — fails gracefully without config files (Phase 0 stub mode)
  await FirebaseClient.initialize();

  // Secure storage initialization for biometrics & credentials
  await SecurePrefs.init();

  // Real-time network connectivity monitor initialization
  await NetworkConnectivityService.instance.initialize();

  // Dependency injection
  await setupInjector();

  runApp(const TransitApp());
}

class TransitApp extends StatelessWidget {
  const TransitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (_) => sl<LocaleCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>(),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'AlexBank Transit',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return StreamBuilder<bool>(
                stream: NetworkConnectivityService.instance.connectionStream,
                initialData: NetworkConnectivityService.instance.isConnected,
                builder: (context, snapshot) {
                  final isConnected = snapshot.data ?? true;
                  return Stack(
                    children: [
                      ?child,
                      if (!isConnected) const NoInternetScreen(),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
