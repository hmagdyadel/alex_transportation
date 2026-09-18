import 'package:json_annotation/json_annotation.dart';

part 'bus_stop_model.g.dart';

/// Bus stop along an employee transit route.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable()
class BusStopModel {
  final String id;
  final String name;
  final String? nameAr;
  final String scheduledTime;
  final bool isCompleted;
  final bool isCurrent;
  final int order;
  final double? latitude;
  final double? longitude;
  final double radiusMeters;
  final bool isSkipped;
  final int riderCount;

  const BusStopModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.scheduledTime,
    this.isCompleted = false,
    this.isCurrent = false,
    required this.order,
    this.latitude,
    this.longitude,
    this.radiusMeters = 150.0,
    this.isSkipped = false,
    this.riderCount = 0,
  });

  factory BusStopModel.fromJson(Map<String, dynamic> json) =>
      _$BusStopModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusStopModelToJson(this);

  BusStopModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? scheduledTime,
    bool? isCompleted,
    bool? isCurrent,
    int? order,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? isSkipped,
    int? riderCount,
  }) {
    return BusStopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
      order: order ?? this.order,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isSkipped: isSkipped ?? this.isSkipped,
      riderCount: riderCount ?? this.riderCount,
    );
  }
}
