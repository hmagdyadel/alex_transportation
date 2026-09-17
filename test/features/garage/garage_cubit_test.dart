import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alex_transportation/features/garage/presentation/bloc/garage_cubit.dart';
import 'package:alex_transportation/features/garage/presentation/bloc/garage_states.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GarageCubit', () {
    late GarageCubit cubit;

    setUp(() {
      cubit = GarageCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is GarageStates.initial()', () {
      expect(cubit.state, const GarageStates.initial());
      expect(cubit.availableSlots, 42);
      expect(GarageCubit.totalCapacity, 300);
    });

    test('loadGarageData populates active subscription and sets state to loaded', () async {
      await cubit.loadGarageData();

      expect(cubit.state, const GarageStates.loaded());
      expect(cubit.currentSubscription, isNotNull);
      expect(cubit.currentSubscription!.name, 'Sara Hassan');
      expect(cubit.currentSubscription!.slotLabel, 'P1-014');
    });

    test('checkInOut toggles checkIn state and decrements/increments available bays', () async {
      await cubit.loadGarageData();
      final initialSlots = cubit.availableSlots;
      final initialCheckedIn = cubit.currentSubscription!.checkedIn;

      await cubit.checkInOut();

      expect(cubit.currentSubscription!.checkedIn, !initialCheckedIn);
      if (!initialCheckedIn) {
        expect(cubit.availableSlots, initialSlots - 1);
      } else {
        expect(cubit.availableSlots, initialSlots + 1);
      }
    });

    test('findSubscription finds subscription by ISL and email', () async {
      await cubit.loadGarageData();

      final found = cubit.findSubscription('10234', 's.hassan@alexbank.com');
      expect(found, isNotNull);
      expect(found!.name, 'Sara Hassan');

      final notFound = cubit.findSubscription('00000', 'unknown@alexbank.com');
      expect(notFound, isNull);
    });

    test('requestCancellation sets active subscription status to cancellation_pending', () async {
      await cubit.loadGarageData();

      await cubit.requestCancellation(
        isl: '10234',
        email: 's.hassan@alexbank.com',
      );

      expect(cubit.currentSubscription!.status, 'cancellation_pending');
    });
  });
}
