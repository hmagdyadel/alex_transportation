// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverProfileModel _$DriverProfileModelFromJson(Map<String, dynamic> json) =>
    DriverProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      licenseNumber: json['licenseNumber'] as String,
      assignedBusPlate: json['assignedBusPlate'] as String,
      assignedBusNumber: json['assignedBusNumber'] as String,
      assignedRouteId: json['assignedRouteId'] as String,
      assignedRouteName: json['assignedRouteName'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      totalTripsCompleted:
          (json['totalTripsCompleted'] as num?)?.toInt() ?? 328,
    );

Map<String, dynamic> _$DriverProfileModelToJson(DriverProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'licenseNumber': instance.licenseNumber,
      'assignedBusPlate': instance.assignedBusPlate,
      'assignedBusNumber': instance.assignedBusNumber,
      'assignedRouteId': instance.assignedRouteId,
      'assignedRouteName': instance.assignedRouteName,
      'rating': instance.rating,
      'totalTripsCompleted': instance.totalTripsCompleted,
    };
