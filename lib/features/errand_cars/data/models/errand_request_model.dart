import 'package:json_annotation/json_annotation.dart';

part 'errand_request_model.g.dart';

/// Employee mission request for an official bank errand car.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable()
class ErrandRequestModel {
  final String id;
  final String employeeName;
  final String employeeIsl;
  final String department;
  final String pickupLocation;
  final String destination;
  final String purpose;
  final String requestedDate;
  final String requestedTime;
  final String estimatedReturnTime;
  final String supervisorName;
  final String
  status; // pending, approved, rejected, in_progress, completed, cancelled
  final String? assignedCarId;
  final String? assignedCarPlate;
  final String? assignedCarMake;
  final String? assignedDriverName;
  final DateTime submittedAt;
  final DateTime? approvedAt;

  const ErrandRequestModel({
    required this.id,
    required this.employeeName,
    required this.employeeIsl,
    required this.department,
    required this.pickupLocation,
    required this.destination,
    required this.purpose,
    required this.requestedDate,
    required this.requestedTime,
    required this.estimatedReturnTime,
    required this.supervisorName,
    this.status = 'pending',
    this.assignedCarId,
    this.assignedCarPlate,
    this.assignedCarMake,
    this.assignedDriverName,
    required this.submittedAt,
    this.approvedAt,
  });

  factory ErrandRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ErrandRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ErrandRequestModelToJson(this);

  ErrandRequestModel copyWith({
    String? id,
    String? employeeName,
    String? employeeIsl,
    String? department,
    String? pickupLocation,
    String? destination,
    String? purpose,
    String? requestedDate,
    String? requestedTime,
    String? estimatedReturnTime,
    String? supervisorName,
    String? status,
    String? assignedCarId,
    String? assignedCarPlate,
    String? assignedCarMake,
    String? assignedDriverName,
    DateTime? submittedAt,
    DateTime? approvedAt,
  }) {
    return ErrandRequestModel(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeIsl: employeeIsl ?? this.employeeIsl,
      department: department ?? this.department,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destination: destination ?? this.destination,
      purpose: purpose ?? this.purpose,
      requestedDate: requestedDate ?? this.requestedDate,
      requestedTime: requestedTime ?? this.requestedTime,
      estimatedReturnTime: estimatedReturnTime ?? this.estimatedReturnTime,
      supervisorName: supervisorName ?? this.supervisorName,
      status: status ?? this.status,
      assignedCarId: assignedCarId ?? this.assignedCarId,
      assignedCarPlate: assignedCarPlate ?? this.assignedCarPlate,
      assignedCarMake: assignedCarMake ?? this.assignedCarMake,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
