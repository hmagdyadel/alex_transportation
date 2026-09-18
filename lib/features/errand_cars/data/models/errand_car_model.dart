import 'package:json_annotation/json_annotation.dart';

part 'errand_car_model.g.dart';

/// Official fleet vehicle available for corporate errand missions.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable()
class ErrandCarModel {
  final String id;
  final String plateNumber;
  final String make;
  final String color;
  final String status; // available, in_use, maintenance
  final int currentMileage;
  final DateTime? lastServiceDate;

  const ErrandCarModel({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.color,
    this.status = 'available',
    this.currentMileage = 0,
    this.lastServiceDate,
  });

  factory ErrandCarModel.fromJson(Map<String, dynamic> json) =>
      _$ErrandCarModelFromJson(json);

  Map<String, dynamic> toJson() => _$ErrandCarModelToJson(this);

  ErrandCarModel copyWith({
    String? id,
    String? plateNumber,
    String? make,
    String? color,
    String? status,
    int? currentMileage,
    DateTime? lastServiceDate,
  }) {
    return ErrandCarModel(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      make: make ?? this.make,
      color: color ?? this.color,
      status: status ?? this.status,
      currentMileage: currentMileage ?? this.currentMileage,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
    );
  }
}
