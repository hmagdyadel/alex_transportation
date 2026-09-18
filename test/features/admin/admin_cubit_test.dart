import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/features/admin/presentation/bloc/admin_cubit.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/admin_states.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/garage_admin_cubit.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';
import 'package:alex_transportation/features/buses/presentation/bloc/bus_cubit.dart';

void main() {
  group('AdminCubit', () {
    late AdminCubit cubit;

    setUp(() {
      cubit = AdminCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initializes with tabs, invite codes, and driver roster', () {
      expect(cubit.state, const AdminStates.initial());
      expect(cubit.selectedTab, 0);
      expect(cubit.inviteCodes.length, 4);
      expect(cubit.captains.length, 6);

      // Verify captain details
      final firstCaptain = cubit.captains.first;
      expect(firstCaptain.name, 'Captain Mahmoud Sayed');
      expect(firstCaptain.rating, greaterThan(4.8));
    });

    test('setTab updates selected tab index', () {
      cubit.setTab(2);
      expect(cubit.selectedTab, 2);
    });

    test('generateInviteCode generates new code for employee', () async {
      final initialCount = cubit.inviteCodes.length;
      await cubit.generateInviteCode(
        role: 'employee',
        department: 'Treasury',
        note: 'Treasury department onboarding',
      );

      expect(cubit.inviteCodes.length, initialCount + 1);
      final newCode = cubit.inviteCodes.first;
      expect(newCode.role, 'employee');
      expect(newCode.department, 'Treasury');
      expect(newCode.code.startsWith('EMP-'), isTrue);
    });

    test('toggleInviteCode toggles active state of code', () {
      final code = cubit.inviteCodes.first;
      final initialActive = code.isActive;

      cubit.toggleInviteCode(code.id);
      final updated = cubit.inviteCodes.firstWhere((c) => c.id == code.id);
      expect(updated.isActive, !initialActive);
    });

    test('revokeInviteCode removes code from list', () {
      final codeToRevoke = cubit.inviteCodes.last;
      cubit.revokeInviteCode(codeToRevoke.id);

      expect(cubit.inviteCodes.any((c) => c.id == codeToRevoke.id), isFalse);
    });

    test('reassignDriver updates driver route assignment', () {
      final driver = cubit.captains.first;
      cubit.reassignDriver(
        driver.id,
        newRouteId: 'R104',
        newRouteName: 'Route 104: 6th October — Smart Village HQ',
      );

      final updated = cubit.captains.firstWhere((d) => d.id == driver.id);
      expect(updated.assignedRouteId, 'R104');
    });
  });

  group('Admin Dynamic Parking Fee (GarageAdminCubit & GarageCubit)', () {
    late GarageAdminCubit adminCubit;
    late GarageCubit garageCubit;

    setUp(() {
      adminCubit = GarageAdminCubit();
      garageCubit = GarageCubit();
      // Reset default
      GarageCubit.monthlyFee = 1200;
    });

    tearDown(() {
      adminCubit.close();
      garageCubit.close();
    });

    test('default monthly parking fee is 1200 EGP', () {
      expect(garageCubit.currentMonthlyFee, 1200);
      expect(adminCubit.monthlyFee, 1200);
    });

    test('increaseMonthlyFee increases by 100 EGP', () {
      adminCubit.increaseMonthlyFee(100);
      expect(garageCubit.currentMonthlyFee, 1300);
      expect(adminCubit.monthlyFee, 1300);
    });

    test('decreaseMonthlyFee decreases by 100 EGP down to minimum', () {
      adminCubit.decreaseMonthlyFee(200);
      expect(garageCubit.currentMonthlyFee, 1000);
      expect(adminCubit.monthlyFee, 1000);
    });

    test('setMonthlyFee sets exact rate', () {
      adminCubit.setMonthlyFee(1500);
      expect(garageCubit.currentMonthlyFee, 1500);
    });
  });

  group('Admin Bus Mirrored Route Generation', () {
    late BusCubit busCubit;

    setUp(() {
      busCubit = BusCubit();
    });

    tearDown(() {
      busCubit.close();
    });

    test('generateReverseEveningRoute mirrors morning stations in reverse starting at Smart Village HQ', () {
      final mirrored = busCubit.generateReverseEveningRoute('R101');
      expect(mirrored.shift, 'Evening');
      expect(mirrored.stops.first.name, 'Smart Village (AlexBank HQ)');
      expect(mirrored.stops.last.name, 'Victoria Square');
    });
  });
}
