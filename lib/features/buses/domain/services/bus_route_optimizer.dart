import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';

/// Encapsulates the result of dynamic route optimization for a bus line.
class OptimizedRoutePlan {
  final List<BusStopModel> optimizedStops;
  final int startingStopIndex;
  final int skippedStopsCount;
  final int totalRiders;
  final bool hasRiders;

  const OptimizedRoutePlan({
    required this.optimizedStops,
    required this.startingStopIndex,
    required this.skippedStopsCount,
    required this.totalRiders,
    required this.hasRiders,
  });

  BusStopModel get startingStop => optimizedStops[startingStopIndex];

  List<BusStopModel> get activeStops =>
      optimizedStops.where((s) => !s.isSkipped).toList();
}

/// Optimizes bus route stops dynamically based on passenger bookings for the day.
///
/// Rule:
/// - If stops 1..5 have 0 riders, the bus starts directly at stop 6.
/// - If an intermediate stop (like stop 7) has 0 riders, it is skipped.
/// - The terminal destination stop (AlexBank HQ / destination) is always preserved.
class BusRouteOptimizer {
  const BusRouteOptimizer._();

  /// Optimizes a list of route stops given the list of booked pickup stops for today.
  ///
  /// [bookedPickupStops] can be stop names or stop IDs of confirmed bookings.
  static OptimizedRoutePlan optimizeRoute({
    required List<BusStopModel> stops,
    required List<String> bookedPickupStops,
  }) {
    if (stops.isEmpty) {
      return const OptimizedRoutePlan(
        optimizedStops: [],
        startingStopIndex: 0,
        skippedStopsCount: 0,
        totalRiders: 0,
        hasRiders: false,
      );
    }

    // 1. Calculate rider counts per stop
    final stopRiderCounts = <int>[];
    int totalRiders = 0;

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final count = bookedPickupStops.where((b) {
        final clean = b.trim().toLowerCase();
        return clean == stop.id.toLowerCase() ||
            clean == stop.name.trim().toLowerCase() ||
            (stop.nameAr != null && clean == stop.nameAr!.trim().toLowerCase());
      }).length;

      stopRiderCounts.add(count);
      totalRiders += count;
    }

    // 2. If nobody has booked any stop today, keep all stops as default scheduled
    if (totalRiders == 0) {
      final defaultStops = List.generate(stops.length, (i) {
        return stops[i].copyWith(
          isSkipped: false,
          riderCount: 0,
          isCurrent: i == 0,
        );
      });
      return OptimizedRoutePlan(
        optimizedStops: defaultStops,
        startingStopIndex: 0,
        skippedStopsCount: 0,
        totalRiders: 0,
        hasRiders: false,
      );
    }

    // 3. Find first stop with riders (leading stops with 0 riders are skipped)
    int firstActiveIndex = 0;
    for (int i = 0; i < stops.length; i++) {
      if (stopRiderCounts[i] > 0) {
        firstActiveIndex = i;
        break;
      }
    }

    // 4. Build optimized stops
    final optimized = <BusStopModel>[];
    int skippedCount = 0;
    final lastIndex = stops.length - 1;

    for (int i = 0; i < stops.length; i++) {
      final original = stops[i];
      final count = stopRiderCounts[i];

      if (i < firstActiveIndex) {
        // Leading stop with no riders -> Skip
        optimized.add(original.copyWith(
          isSkipped: true,
          riderCount: 0,
          isCurrent: false,
          isCompleted: true, // Marked as bypassed
        ));
        skippedCount++;
      } else if (i == firstActiveIndex) {
        // First active pickup stop -> Bus starts here
        optimized.add(original.copyWith(
          isSkipped: false,
          riderCount: count,
          isCurrent: true,
          isCompleted: false,
        ));
      } else if (i == lastIndex) {
        // Terminal destination stop -> Always active for passenger drop-off
        optimized.add(original.copyWith(
          isSkipped: false,
          riderCount: count,
          isCurrent: false,
          isCompleted: false,
        ));
      } else {
        // Intermediate stops between first stop and destination
        if (count == 0) {
          // No passengers waiting at this stop -> Skip
          optimized.add(original.copyWith(
            isSkipped: true,
            riderCount: 0,
            isCurrent: false,
            isCompleted: true,
          ));
          skippedCount++;
        } else {
          // Has passengers waiting -> Active stop
          optimized.add(original.copyWith(
            isSkipped: false,
            riderCount: count,
            isCurrent: false,
            isCompleted: false,
          ));
        }
      }
    }

    return OptimizedRoutePlan(
      optimizedStops: optimized,
      startingStopIndex: firstActiveIndex,
      skippedStopsCount: skippedCount,
      totalRiders: totalRiders,
      hasRiders: true,
    );
  }
}
