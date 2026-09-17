// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusRouteModel _$BusRouteModelFromJson(Map<String, dynamic> json) =>
    BusRouteModel(
      id: json['id'] as String,
      routeNumber: json['routeNumber'] as String,
      name: json['name'] as String,
      shift: json['shift'] as String,
      departureTime: json['departureTime'] as String,
      estimatedArrival: json['estimatedArrival'] as String,
      totalSeats: (json['totalSeats'] as num).toInt(),
      availableSeats: (json['availableSeats'] as num).toInt(),
      driverName: json['driverName'] as String,
      driverPhone: json['driverPhone'] as String,
      busPlate: json['busPlate'] as String,
      status: json['status'] as String? ?? 'on_time',
      stops: (json['stops'] as List<dynamic>)
          .map((e) => BusStopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BusRouteModelToJson(BusRouteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routeNumber': instance.routeNumber,
      'name': instance.name,
      'shift': instance.shift,
      'departureTime': instance.departureTime,
      'estimatedArrival': instance.estimatedArrival,
      'totalSeats': instance.totalSeats,
      'availableSeats': instance.availableSeats,
      'driverName': instance.driverName,
      'driverPhone': instance.driverPhone,
      'busPlate': instance.busPlate,
      'status': instance.status,
      'stops': instance.stops.map((e) => e.toJson()).toList(),
    };
