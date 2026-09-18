// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'errand_dispatch_pass_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrandDispatchPassModel _$ErrandDispatchPassModelFromJson(
  Map<String, dynamic> json,
) => ErrandDispatchPassModel(
  id: json['id'] as String,
  requestId: json['requestId'] as String,
  missionCode: json['missionCode'] as String,
  employeeName: json['employeeName'] as String,
  destination: json['destination'] as String,
  carPlate: json['carPlate'] as String,
  carMake: json['carMake'] as String,
  departureTime: json['departureTime'] as String,
  estimatedReturn: json['estimatedReturn'] as String,
  status: json['status'] as String? ?? 'active',
  startMileage: (json['startMileage'] as num?)?.toInt(),
  endMileage: (json['endMileage'] as num?)?.toInt(),
  qrPayload: json['qrPayload'] as String,
);

Map<String, dynamic> _$ErrandDispatchPassModelToJson(
  ErrandDispatchPassModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'requestId': instance.requestId,
  'missionCode': instance.missionCode,
  'employeeName': instance.employeeName,
  'destination': instance.destination,
  'carPlate': instance.carPlate,
  'carMake': instance.carMake,
  'departureTime': instance.departureTime,
  'estimatedReturn': instance.estimatedReturn,
  'status': instance.status,
  'startMileage': instance.startMileage,
  'endMileage': instance.endMileage,
  'qrPayload': instance.qrPayload,
};
