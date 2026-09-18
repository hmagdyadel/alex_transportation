import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alex_transportation/core/di/injector.dart';
import 'package:alex_transportation/core/widgets/app_button.dart';
import 'package:alex_transportation/core/widgets/app_card.dart';
import 'package:alex_transportation/core/widgets/app_text_field.dart';
import 'package:alex_transportation/core/widgets/custom_loading_indicator.dart';
import 'package:alex_transportation/core/widgets/status_pill.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:alex_transportation/features/auth/presentation/bloc/auth_states.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    if (!sl.isRegistered<AuthCubit>()) {
      await setupInjector();
    }
  });

  group('Design System Widgets', () {
    testWidgets('AppButton renders label and handles tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Verify Code',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Verify Code'), findsOneWidget);
      await tester.tap(find.text('Verify Code'));
      expect(tapped, isTrue);
    });

    testWidgets('AppTextField displays label and enters text', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: controller,
              label: 'BANK STAFF ISL',
              hint: 'Enter ISL',
            ),
          ),
        ),
      );

      expect(find.text('BANK STAFF ISL'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '10492');
      expect(controller.text, '10492');
    });

    testWidgets('AppCard renders child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('StatusPill displays correct label and badge type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusPill(
              label: 'Active Route',
              type: StatusPillType.active,
            ),
          ),
        ),
      );

      expect(find.text('Active Route'), findsOneWidget);
    });

    testWidgets('CustomLoadingIndicator builds and animates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomLoadingIndicator(size: 48),
          ),
        ),
      );

      expect(find.byType(CustomLoadingIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('AuthCubit RBAC & ISL Login Tests', () {
    test('Login as Normal User with ISL 10492 succeeds and locks to employee', () async {
      final cubit = AuthCubit();
      await cubit.loginWithIsl(
        isl: '10492',
        password: 'alex123',
        role: 'employee',
      );
      expect(cubit.state is Success<dynamic>, isTrue);
      expect(cubit.currentRole, 'employee');
      expect(cubit.isAdmin, isFalse);
      await cubit.close();
    });

    test('Normal User ISL attempting to login as Admin is rejected with error', () async {
      final cubit = AuthCubit();
      await cubit.loginWithIsl(
        isl: '10492',
        password: 'alex123',
        role: 'admin',
      );
      expect(cubit.state is Error, isTrue);
      await cubit.close();
    });

    test('Login as Driver Captain with ISL DRV-2001 succeeds', () async {
      final cubit = AuthCubit();
      await cubit.loginWithIsl(
        isl: 'DRV-2001',
        password: 'alex123',
        role: 'driver',
      );
      expect(cubit.state is Success<dynamic>, isTrue);
      expect(cubit.currentRole, 'driver');
      expect(cubit.isAdmin, isFalse);
      await cubit.close();
    });

    test('Login as Admin with ISL ADM-9001 succeeds with admin role', () async {
      final cubit = AuthCubit();
      await cubit.loginWithIsl(
        isl: 'ADM-9001',
        password: 'alex123',
        role: 'admin',
      );
      expect(cubit.state is Success<dynamic>, isTrue);
      expect(cubit.currentRole, 'admin');
      expect(cubit.isAdmin, isTrue);
      await cubit.close();
    });

    test('Admin can log in as Employee to use Garage/Buses while retaining isAdmin', () async {
      final cubit = AuthCubit();
      await cubit.loginWithIsl(
        isl: 'ADM-9001',
        password: 'alex123',
        role: 'employee',
      );
      expect(cubit.state is Success<dynamic>, isTrue);
      expect(cubit.currentRole, 'employee');
      expect(cubit.isAdmin, isTrue);
      await cubit.close();
    });

    test('Admin provisioning registers new admin account and allows authentication', () async {
      final cubit = AuthCubit();
      await cubit.registerNewAdmin(
        isl: 'ADM-9999',
        name: 'New Fleet Admin',
        department: 'Corporate Logistics',
        password: 'alex123',
      );
      expect(cubit.state is Success<dynamic>, isTrue);
      expect(cubit.adminAccounts.any((a) => a.isl == 'ADM-9999'), isTrue);

      // Now authenticate with newly provisioned admin
      await cubit.loginWithIsl(
        isl: 'ADM-9999',
        password: 'alex123',
        role: 'admin',
      );
      expect(cubit.currentRole, 'admin');
      expect(cubit.isAdmin, isTrue);
      await cubit.close();
    });

    test('Unregistered ISL login is rejected and directs user to register', () async {
      final cubit = AuthCubit();
      await cubit.loginWithIsl(
        isl: 'UNKNOWN-999',
        password: 'alex123',
        role: 'employee',
      );
      expect(cubit.state is Error, isTrue);
      final errorState = cubit.state as Error;
      expect(errorState.message.contains('not found. Please register first.'), isTrue);
      await cubit.close();
    });

    test('First-time user registration creates account, logs in, and persists', () async {
      final cubit = AuthCubit();
      await cubit.registerAccount(
        isl: 'EMP-7777',
        name: 'Haitham Adel',
        department: 'IT Architecture',
        role: 'employee',
        password: 'password123',
      );
      expect(cubit.state is Success<dynamic>, isTrue);
      expect(cubit.currentIsl, 'EMP-7777');
      expect(cubit.currentUserName, 'Haitham Adel');
      expect(cubit.currentRole, 'employee');

      // Logout
      await cubit.signOut();

      // Login again with registered credentials
      await cubit.loginWithIsl(
        isl: 'EMP-7777',
        password: 'password123',
        role: 'employee',
      );
      expect(cubit.state is Success<dynamic>, isTrue);
      expect(cubit.currentIsl, 'EMP-7777');
      await cubit.close();
    });

    test('Registering duplicate ISL is rejected with error', () async {
      final cubit = AuthCubit();
      await cubit.registerAccount(
        isl: '10492', // already exists
        name: 'Another Person',
        department: 'Retail Banking',
        role: 'employee',
        password: 'alex123',
      );
      expect(cubit.state is Error, isTrue);
      final errorState = cubit.state as Error;
      expect(errorState.message.contains('already exists'), isTrue);
      await cubit.close();
    });

    test('SignOut clears role and session', () async {
      final cubit = AuthCubit();
      await cubit.loginWithIsl(
        isl: 'ADM-9001',
        password: 'alex123',
        role: 'admin',
      );
      expect(cubit.currentRole, 'admin');
      expect(cubit.isAdmin, isTrue);
      await cubit.signOut();
      expect(cubit.currentRole, 'employee');
      expect(cubit.isAdmin, isFalse);
      await cubit.close();
    });
  });
}
