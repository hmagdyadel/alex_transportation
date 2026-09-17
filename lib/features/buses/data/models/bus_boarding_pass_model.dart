import 'package:json_annotation/json_annotation.dart';

part 'bus_boarding_pass_model.g.dart';

/// Employee digital bus boarding pass.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable()
class BusBoardingPassModel {
  final String id;
  final String routeId;
  final String routeName;
  final String routeNumber;
  final String busNumber;
  final String stopName;
  final int seatNumber;
  final String employeeName;
  final String departureTime;
  final String status;
  final String qrPayload;
  final DateTime bookedAt;

  const BusBoardingPassModel({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.routeNumber,
    required this.busNumber,
    required this.stopName,
    required this.seatNumber,
    required this.employeeName,
    required this.departureTime,
    this.status = 'active',
    required this.qrPayload,
    required this.bookedAt,
  });

  factory BusBoardingPassModel.fromJson(Map<String, dynamic> json) =>
      _$BusBoardingPassModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusBoardingPassModelToJson(this);

  BusBoardingPassModel copyWith({
    String? id,
    String? routeId,
    String? routeName,
    String? routeNumber,
    String? busNumber,
    String? stopName,
    int? seatNumber,
    String? employeeName,
    String? departureTime,
    String? status,
    String? qrPayload,
    DateTime? bookedAt,
  }) {
    return BusBoardingPassModel(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      routeNumber: routeNumber ?? this.routeNumber,
      busNumber: busNumber ?? this.busNumber,
      stopName: stopName ?? this.stopName,
      seatNumber: seatNumber ?? this.seatNumber,
      employeeName: employeeName ?? this.employeeName,
      departureTime: departureTime ?? this.departureTime,
      status: status ?? this.status,
      qrPayload: qrPayload ?? this.qrPayload,
      bookedAt: bookedAt ?? this.bookedAt,
    );
  }
}
