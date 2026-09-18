import 'package:flutter_test/flutter_test.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/buses/domain/services/bus_route_optimizer.dart';

void main() {
  group('BusRouteOptimizer Tests', () {
    final tenStops = List.generate(10, (index) {
      final stopNumber = index + 1;
      return BusStopModel(
        id: 'stop-$stopNumber',
        name: 'Stop $stopNumber',
        nameAr: 'محطة $stopNumber',
        scheduledTime: '07:${(index * 10).toString().padLeft(2, '0')} AM',
        order: stopNumber,
        latitude: 30.0 + (index * 0.01),
        longitude: 31.0 + (index * 0.01),
      );
    });

    test('Exact User Scenario: Stops 1-5 have 0 riders, Stop 7 has 0 riders -> starts at Stop 6, skips Stop 7', () {
      // Stops with riders: Stop 6 (index 5), Stop 8 (index 7), Stop 9 (index 8), Stop 10 (index 9)
      final bookedStops = [
        'Stop 6',
        'Stop 6', // 2 riders at Stop 6
        'Stop 8', // 1 rider at Stop 8
        'Stop 9', // 1 rider at Stop 9
      ];

      final plan = BusRouteOptimizer.optimizeRoute(
        stops: tenStops,
        bookedPickupStops: bookedStops,
      );

      // 1. Starts directly from Stop 6 (index 5)
      expect(plan.startingStopIndex, equals(5));
      expect(plan.startingStop.name, equals('Stop 6'));
      expect(plan.startingStop.isCurrent, isTrue);
      expect(plan.startingStop.riderCount, equals(2));
      expect(plan.startingStop.isSkipped, isFalse);

      // 2. Stops 1 to 5 are skipped
      for (int i = 0; i < 5; i++) {
        expect(plan.optimizedStops[i].isSkipped, isTrue, reason: 'Stop ${i + 1} should be skipped');
        expect(plan.optimizedStops[i].riderCount, equals(0));
        expect(plan.optimizedStops[i].isCompleted, isTrue);
      }

      // 3. Stop 7 (index 6) has 0 riders -> Skipped
      expect(plan.optimizedStops[6].name, equals('Stop 7'));
      expect(plan.optimizedStops[6].isSkipped, isTrue);
      expect(plan.optimizedStops[6].riderCount, equals(0));

      // 4. Stop 8 (index 7) has 1 rider -> Active
      expect(plan.optimizedStops[7].name, equals('Stop 8'));
      expect(plan.optimizedStops[7].isSkipped, isFalse);
      expect(plan.optimizedStops[7].riderCount, equals(1));

      // 5. Stop 9 (index 8) has 1 rider -> Active
      expect(plan.optimizedStops[8].name, equals('Stop 9'));
      expect(plan.optimizedStops[8].isSkipped, isFalse);
      expect(plan.optimizedStops[8].riderCount, equals(1));

      // 6. Stop 10 (index 9, terminal destination) -> Active
      expect(plan.optimizedStops[9].name, equals('Stop 10'));
      expect(plan.optimizedStops[9].isSkipped, isFalse);

      // Total counts
      expect(plan.totalRiders, equals(4));
      expect(plan.skippedStopsCount, equals(6)); // Stops 1, 2, 3, 4, 5, 7
      expect(plan.activeStops.map((s) => s.name).toList(), equals([
        'Stop 6',
        'Stop 8',
        'Stop 9',
        'Stop 10',
      ]));
    });

    test('Edge Case: No riders booked anywhere today keeps schedule on default start', () {
      final plan = BusRouteOptimizer.optimizeRoute(
        stops: tenStops,
        bookedPickupStops: [],
      );

      expect(plan.hasRiders, isFalse);
      expect(plan.startingStopIndex, equals(0));
      expect(plan.skippedStopsCount, equals(0));
      expect(plan.optimizedStops.first.isCurrent, isTrue);
    });

    test('Normal case: First stop has riders -> starts at Stop 1', () {
      final plan = BusRouteOptimizer.optimizeRoute(
        stops: tenStops,
        bookedPickupStops: ['Stop 1', 'Stop 2'],
      );

      expect(plan.startingStopIndex, equals(0));
      expect(plan.startingStop.name, equals('Stop 1'));
      expect(plan.optimizedStops[0].isSkipped, isFalse);
      expect(plan.optimizedStops[1].isSkipped, isFalse);
      expect(plan.optimizedStops[2].isSkipped, isTrue); // Stop 3 has 0 riders -> skipped
    });
  });
}
