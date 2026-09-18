// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverTripModel _$DriverTripModelFromJson(Map<String, dynamic> json) =>
    DriverTripModel(
      tripId: json['tripId'] as String,
      routeId: json['routeId'] as String,
      routeNumber: json['routeNumber'] as String,
      routeName: json['routeName'] as String,
      shift: json['shift'] as String,
      busPlate: json['busPlate'] as String,
      status: json['status'] as String? ?? 'scheduled',
      currentStopIndex: (json['currentStopIndex'] as num?)?.toInt() ?? 0,
      stops: (json['stops'] as List<dynamic>)
          .map((e) => BusStopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      passengers: (json['passengers'] as List<dynamic>)
          .map((e) => TripManifestItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$DriverTripModelToJson(DriverTripModel instance) =>
    <String, dynamic>{
      'tripId': instance.tripId,
      'routeId': instance.routeId,
      'routeNumber': instance.routeNumber,
      'routeName': instance.routeName,
      'shift': instance.shift,
      'busPlate': instance.busPlate,
      'status': instance.status,
      'currentStopIndex': instance.currentStopIndex,
      'stops': instance.stops.map((e) => e.toJson()).toList(),
      'passengers': instance.passengers.map((e) => e.toJson()).toList(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
