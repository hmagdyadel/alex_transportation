import 'package:json_annotation/json_annotation.dart';

part 'errand_dispatch_pass_model.g.dart';

/// Digital dispatch pass for an approved errand car mission.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable()
class ErrandDispatchPassModel {
  final String id;
  final String requestId;
  final String missionCode;
  final String employeeName;
  @JsonKey(defaultValue: 'Smart Village Operations Hub')
  final String pickupLocation;
  final String destination;
  final String carPlate;
  final String carMake;
  final String departureTime;
  final String estimatedReturn;
  final String status; // active, completed
  final int? startMileage;
  final int? endMileage;
  final String qrPayload;

  const ErrandDispatchPassModel({
    required this.id,
    required this.requestId,
    required this.missionCode,
    required this.employeeName,
    this.pickupLocation = 'Smart Village Operations Hub',
    required this.destination,
    required this.carPlate,
    required this.carMake,
    required this.departureTime,
    required this.estimatedReturn,
    this.status = 'active',
    this.startMileage,
    this.endMileage,
    required this.qrPayload,
  });

  factory ErrandDispatchPassModel.fromJson(Map<String, dynamic> json) =>
      _$ErrandDispatchPassModelFromJson(json);

  Map<String, dynamic> toJson() => _$ErrandDispatchPassModelToJson(this);

  /// Total distance driven during this mission (null if not completed).
  int? get distanceDriven {
    if (startMileage != null && endMileage != null) {
      return endMileage! - startMileage!;
    }
    return null;
  }

  ErrandDispatchPassModel copyWith({
    String? id,
    String? requestId,
    String? missionCode,
    String? employeeName,
    String? pickupLocation,
    String? destination,
    String? carPlate,
    String? carMake,
    String? departureTime,
    String? estimatedReturn,
    String? status,
    int? startMileage,
    int? endMileage,
    String? qrPayload,
  }) {
    return ErrandDispatchPassModel(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      missionCode: missionCode ?? this.missionCode,
      employeeName: employeeName ?? this.employeeName,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destination: destination ?? this.destination,
      carPlate: carPlate ?? this.carPlate,
      carMake: carMake ?? this.carMake,
      departureTime: departureTime ?? this.departureTime,
      estimatedReturn: estimatedReturn ?? this.estimatedReturn,
      status: status ?? this.status,
      startMileage: startMileage ?? this.startMileage,
      endMileage: endMileage ?? this.endMileage,
      qrPayload: qrPayload ?? this.qrPayload,
    );
  }
}
