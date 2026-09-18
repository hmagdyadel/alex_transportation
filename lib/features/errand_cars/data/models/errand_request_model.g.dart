// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'errand_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrandRequestModel _$ErrandRequestModelFromJson(Map<String, dynamic> json) =>
    ErrandRequestModel(
      id: json['id'] as String,
      employeeName: json['employeeName'] as String,
      employeeIsl: json['employeeIsl'] as String,
      department: json['department'] as String,
      pickupLocation: json['pickupLocation'] as String,
      destination: json['destination'] as String,
      purpose: json['purpose'] as String,
      requestedDate: json['requestedDate'] as String,
      requestedTime: json['requestedTime'] as String,
      estimatedReturnTime: json['estimatedReturnTime'] as String,
      supervisorName: json['supervisorName'] as String,
      status: json['status'] as String? ?? 'pending',
      assignedCarId: json['assignedCarId'] as String?,
      assignedCarPlate: json['assignedCarPlate'] as String?,
      assignedCarMake: json['assignedCarMake'] as String?,
      assignedDriverName: json['assignedDriverName'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
    );

Map<String, dynamic> _$ErrandRequestModelToJson(ErrandRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeName': instance.employeeName,
      'employeeIsl': instance.employeeIsl,
      'department': instance.department,
      'pickupLocation': instance.pickupLocation,
      'destination': instance.destination,
      'purpose': instance.purpose,
      'requestedDate': instance.requestedDate,
      'requestedTime': instance.requestedTime,
      'estimatedReturnTime': instance.estimatedReturnTime,
      'supervisorName': instance.supervisorName,
      'status': instance.status,
      'assignedCarId': instance.assignedCarId,
      'assignedCarPlate': instance.assignedCarPlate,
      'assignedCarMake': instance.assignedCarMake,
      'assignedDriverName': instance.assignedDriverName,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
    };
