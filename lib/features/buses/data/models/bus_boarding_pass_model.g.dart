// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_boarding_pass_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusBoardingPassModel _$BusBoardingPassModelFromJson(
  Map<String, dynamic> json,
) => BusBoardingPassModel(
  id: json['id'] as String,
  routeId: json['routeId'] as String,
  routeName: json['routeName'] as String,
  routeNumber: json['routeNumber'] as String,
  busNumber: json['busNumber'] as String,
  stopName: json['stopName'] as String,
  seatNumber: (json['seatNumber'] as num).toInt(),
  employeeName: json['employeeName'] as String,
  departureTime: json['departureTime'] as String,
  status: json['status'] as String? ?? 'active',
  qrPayload: json['qrPayload'] as String,
  bookedAt: DateTime.parse(json['bookedAt'] as String),
);

Map<String, dynamic> _$BusBoardingPassModelToJson(
  BusBoardingPassModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'routeId': instance.routeId,
  'routeName': instance.routeName,
  'routeNumber': instance.routeNumber,
  'busNumber': instance.busNumber,
  'stopName': instance.stopName,
  'seatNumber': instance.seatNumber,
  'employeeName': instance.employeeName,
  'departureTime': instance.departureTime,
  'status': instance.status,
  'qrPayload': instance.qrPayload,
  'bookedAt': instance.bookedAt.toIso8601String(),
};
