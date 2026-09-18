import 'package:json_annotation/json_annotation.dart';

part 'driver_profile_model.g.dart';

/// Driver identity, vehicle license, and route assignment.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable()
class DriverProfileModel {
  final String id;
  final String name;
  final String phone;
  final String licenseNumber;
  final String assignedBusPlate;
  final String assignedBusNumber;
  final String assignedRouteId;
  final String assignedRouteName;
  final double rating;
  final int totalTripsCompleted;

  const DriverProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.assignedBusPlate,
    required this.assignedBusNumber,
    required this.assignedRouteId,
    required this.assignedRouteName,
    this.rating = 4.9,
    this.totalTripsCompleted = 328,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverProfileModelToJson(this);

  DriverProfileModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? licenseNumber,
    String? assignedBusPlate,
    String? assignedBusNumber,
    String? assignedRouteId,
    String? assignedRouteName,
    double? rating,
    int? totalTripsCompleted,
  }) {
    return DriverProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      assignedBusPlate: assignedBusPlate ?? this.assignedBusPlate,
      assignedBusNumber: assignedBusNumber ?? this.assignedBusNumber,
      assignedRouteId: assignedRouteId ?? this.assignedRouteId,
      assignedRouteName: assignedRouteName ?? this.assignedRouteName,
      rating: rating ?? this.rating,
      totalTripsCompleted: totalTripsCompleted ?? this.totalTripsCompleted,
    );
  }
}
