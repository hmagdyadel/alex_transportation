// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_stop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusStopModel _$BusStopModelFromJson(Map<String, dynamic> json) => BusStopModel(
  id: json['id'] as String,
  name: json['name'] as String,
  nameAr: json['nameAr'] as String?,
  scheduledTime: json['scheduledTime'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
  isCurrent: json['isCurrent'] as bool? ?? false,
  order: (json['order'] as num).toInt(),
);

Map<String, dynamic> _$BusStopModelToJson(BusStopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'scheduledTime': instance.scheduledTime,
      'isCompleted': instance.isCompleted,
      'isCurrent': instance.isCurrent,
      'order': instance.order,
    };
