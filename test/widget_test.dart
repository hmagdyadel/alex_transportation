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
              label: 'INVITE CODE',
              hint: 'Enter code',
            ),
          ),
        ),
      );

      expect(find.text('INVITE CODE'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ALEX26');
      expect(controller.text, 'ALEX26');
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
      // Advance single frame
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('AuthCubit Unit Tests', () {
    test('Verify valid employee code ALEX26 succeeds', () async {
      final cubit = AuthCubit();
      await cubit.verifyInviteCode('ALEX26');
      expect(cubit.state is Success<dynamic>, isTrue);
      if (cubit.state is Success<dynamic>) {
        expect((cubit.state as Success<dynamic>).data, 'employee');
      }
      await cubit.close();
    });

    test('Verify ADMIN code succeeds with admin role', () async {
      final cubit = AuthCubit();
      await cubit.verifyInviteCode('ADMIN');
      expect(cubit.state is Success<dynamic>, isTrue);
      if (cubit.state is Success<dynamic>) {
        expect((cubit.state as Success<dynamic>).data, 'admin');
      }
      await cubit.close();
    });

    test('Short code emits error', () async {
      final cubit = AuthCubit();
      await cubit.verifyInviteCode('AB');
      expect(cubit.state is Error, isTrue);
      await cubit.close();
    });
  });
}
