import 'package:json_annotation/json_annotation.dart';

import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/driver/data/models/trip_manifest_item_model.dart';

part 'driver_trip_model.g.dart';

/// Active or scheduled trip session managed by the driver.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable(explicitToJson: true)
class DriverTripModel {
  final String tripId;
  final String routeId;
  final String routeNumber;
  final String routeName;
  final String shift;
  final String busPlate;
  final String status; // 'scheduled', 'in_progress', 'completed'
  final int currentStopIndex;
  final List<BusStopModel> stops;
  final List<TripManifestItemModel> passengers;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const DriverTripModel({
    required this.tripId,
    required this.routeId,
    required this.routeNumber,
    required this.routeName,
    required this.shift,
    required this.busPlate,
    this.status = 'scheduled',
    this.currentStopIndex = 0,
    required this.stops,
    required this.passengers,
    this.startedAt,
    this.completedAt,
  });

  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isScheduled => status == 'scheduled';

  int get boardedCount => passengers.where((p) => p.isBoarded).length;
  int get totalPassengers => passengers.length;

  BusStopModel? get currentStop {
    if (currentStopIndex >= 0 && currentStopIndex < stops.length) {
      return stops[currentStopIndex];
    }
    return null;
  }

  BusStopModel? get nextStop {
    final nextIdx = currentStopIndex + 1;
    if (nextIdx < stops.length) {
      return stops[nextIdx];
    }
    return null;
  }

  factory DriverTripModel.fromJson(Map<String, dynamic> json) =>
      _$DriverTripModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverTripModelToJson(this);

  DriverTripModel copyWith({
    String? tripId,
    String? routeId,
    String? routeNumber,
    String? routeName,
    String? shift,
    String? busPlate,
    String? status,
    int? currentStopIndex,
    List<BusStopModel>? stops,
    List<TripManifestItemModel>? passengers,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return DriverTripModel(
      tripId: tripId ?? this.tripId,
      routeId: routeId ?? this.routeId,
      routeNumber: routeNumber ?? this.routeNumber,
      routeName: routeName ?? this.routeName,
      shift: shift ?? this.shift,
      busPlate: busPlate ?? this.busPlate,
      status: status ?? this.status,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      stops: stops ?? this.stops,
      passengers: passengers ?? this.passengers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
