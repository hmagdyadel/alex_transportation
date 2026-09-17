import 'package:json_annotation/json_annotation.dart';

import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';

part 'bus_route_model.g.dart';

/// Bus route with timing, capacity, driver, and stop manifest.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable(explicitToJson: true)
class BusRouteModel {
  final String id;
  final String routeNumber;
  final String name;
  final String shift;
  final String departureTime;
  final String estimatedArrival;
  final int totalSeats;
  final int availableSeats;
  final String driverName;
  final String driverPhone;
  final String busPlate;
  final String status;
  final List<BusStopModel> stops;

  const BusRouteModel({
    required this.id,
    required this.routeNumber,
    required this.name,
    required this.shift,
    required this.departureTime,
    required this.estimatedArrival,
    required this.totalSeats,
    required this.availableSeats,
    required this.driverName,
    required this.driverPhone,
    required this.busPlate,
    this.status = 'on_time',
    required this.stops,
  });

  factory BusRouteModel.fromJson(Map<String, dynamic> json) =>
      _$BusRouteModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusRouteModelToJson(this);

  BusRouteModel copyWith({
    String? id,
    String? routeNumber,
    String? name,
    String? shift,
    String? departureTime,
    String? estimatedArrival,
    int? totalSeats,
    int? availableSeats,
    String? driverName,
    String? driverPhone,
    String? busPlate,
    String? status,
    List<BusStopModel>? stops,
  }) {
    return BusRouteModel(
      id: id ?? this.id,
      routeNumber: routeNumber ?? this.routeNumber,
      name: name ?? this.name,
      shift: shift ?? this.shift,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      busPlate: busPlate ?? this.busPlate,
      status: status ?? this.status,
      stops: stops ?? this.stops,
    );
  }
}
