import 'package:get_it/get_it.dart';

import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_cubit.dart';
import 'package:alex_transportation/features/errand_cars/presentation/bloc/errand_car_cubit.dart';
import 'package:alex_transportation/features/driver/presentation/bloc/driver_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/garage_admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/bus_admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/errand_admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/driver_admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/access_admin_cubit.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Register all dependencies. Call once at app startup.
///
/// Phase 0: only Cubit skeletons.
/// Subsequent phases add data sources, repositories, and use cases.
Future<void> setupInjector() async {
  // ─── Auth ──────────────────────────────────────────────────────────────
  sl.registerFactory(() => AuthCubit());

  // ─── Garage ────────────────────────────────────────────────────────────
  sl.registerFactory(() => GarageCubit());

  // ─── Buses ─────────────────────────────────────────────────────────────
  sl.registerFactory(() => BusCubit());

  // ─── Errand Cars ───────────────────────────────────────────────────────
  sl.registerFactory(() => ErrandCarCubit());

  // ─── Driver ────────────────────────────────────────────────────────────
  sl.registerFactory(() => DriverCubit());

  // ─── Admin (one Cubit per tab) ─────────────────────────────────────────
  sl.registerFactory(() => GarageAdminCubit());
  sl.registerFactory(() => BusAdminCubit());
  sl.registerFactory(() => ErrandAdminCubit());
  sl.registerFactory(() => DriverAdminCubit());
  sl.registerFactory(() => AccessAdminCubit());
}
