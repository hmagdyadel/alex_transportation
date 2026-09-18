import 'package:json_annotation/json_annotation.dart';

part 'trip_manifest_item_model.g.dart';

/// Passenger entry on the driver's manifest for a specific trip.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable()
class TripManifestItemModel {
  final String id;
  final String passId;
  final String employeeName;
  final String employeeIsl;
  final String department;
  final int seatNumber;
  final String pickupStop;
  final String status; // 'booked', 'boarded', 'no_show'
  final DateTime? boardedAt;

  const TripManifestItemModel({
    required this.id,
    required this.passId,
    required this.employeeName,
    required this.employeeIsl,
    required this.department,
    required this.seatNumber,
    required this.pickupStop,
    this.status = 'booked',
    this.boardedAt,
  });

  bool get isBoarded => status == 'boarded';

  factory TripManifestItemModel.fromJson(Map<String, dynamic> json) =>
      _$TripManifestItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripManifestItemModelToJson(this);

  TripManifestItemModel copyWith({
    String? id,
    String? passId,
    String? employeeName,
    String? employeeIsl,
    String? department,
    int? seatNumber,
    String? pickupStop,
    String? status,
    DateTime? boardedAt,
  }) {
    return TripManifestItemModel(
      id: id ?? this.id,
      passId: passId ?? this.passId,
      employeeName: employeeName ?? this.employeeName,
      employeeIsl: employeeIsl ?? this.employeeIsl,
      department: department ?? this.department,
      seatNumber: seatNumber ?? this.seatNumber,
      pickupStop: pickupStop ?? this.pickupStop,
      status: status ?? this.status,
      boardedAt: boardedAt ?? this.boardedAt,
    );
  }
}
