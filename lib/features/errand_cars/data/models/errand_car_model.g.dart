// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'errand_car_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrandCarModel _$ErrandCarModelFromJson(Map<String, dynamic> json) =>
    ErrandCarModel(
      id: json['id'] as String,
      plateNumber: json['plateNumber'] as String,
      make: json['make'] as String,
      color: json['color'] as String,
      status: json['status'] as String? ?? 'available',
      currentMileage: (json['currentMileage'] as num?)?.toInt() ?? 0,
      lastServiceDate: json['lastServiceDate'] == null
          ? null
          : DateTime.parse(json['lastServiceDate'] as String),
    );

Map<String, dynamic> _$ErrandCarModelToJson(ErrandCarModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plateNumber': instance.plateNumber,
      'make': instance.make,
      'color': instance.color,
      'status': instance.status,
      'currentMileage': instance.currentMileage,
      'lastServiceDate': instance.lastServiceDate?.toIso8601String(),
    };
