// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_manifest_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripManifestItemModel _$TripManifestItemModelFromJson(
  Map<String, dynamic> json,
) => TripManifestItemModel(
  id: json['id'] as String,
  passId: json['passId'] as String,
  employeeName: json['employeeName'] as String,
  employeeIsl: json['employeeIsl'] as String,
  department: json['department'] as String,
  seatNumber: (json['seatNumber'] as num).toInt(),
  pickupStop: json['pickupStop'] as String,
  status: json['status'] as String? ?? 'booked',
  boardedAt: json['boardedAt'] == null
      ? null
      : DateTime.parse(json['boardedAt'] as String),
);

Map<String, dynamic> _$TripManifestItemModelToJson(
  TripManifestItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'passId': instance.passId,
  'employeeName': instance.employeeName,
  'employeeIsl': instance.employeeIsl,
  'department': instance.department,
  'seatNumber': instance.seatNumber,
  'pickupStop': instance.pickupStop,
  'status': instance.status,
  'boardedAt': instance.boardedAt?.toIso8601String(),
};
