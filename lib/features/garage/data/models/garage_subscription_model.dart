import 'package:json_annotation/json_annotation.dart';

part 'garage_subscription_model.g.dart';

/// Represents an employee garage parking subscription record.
/// Pure JsonSerializable model (without Freezed).
@JsonSerializable()
class GarageSubscriptionModel {
  final String id;
  final String name;
  final String nationalId;
  final String isl;
  final String dept;
  final String email;
  final String priorityTier;
  final String? slotLabel;
  final String status;
  final int? waitingPosition;
  final bool checkedIn;
  final DateTime? checkedInAt;
  final DateTime submittedAt;
  final String? licenseUrl;

  const GarageSubscriptionModel({
    required this.id,
    required this.name,
    required this.nationalId,
    required this.isl,
    required this.dept,
    required this.email,
    this.priorityTier = 'standard',
    this.slotLabel,
    this.status = 'active',
    this.waitingPosition,
    this.checkedIn = false,
    this.checkedInAt,
    required this.submittedAt,
    this.licenseUrl,
  });

  factory GarageSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$GarageSubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$GarageSubscriptionModelToJson(this);

  GarageSubscriptionModel copyWith({
    String? id,
    String? name,
    String? nationalId,
    String? isl,
    String? dept,
    String? email,
    String? priorityTier,
    String? slotLabel,
    String? status,
    int? waitingPosition,
    bool? checkedIn,
    DateTime? checkedInAt,
    DateTime? submittedAt,
    String? licenseUrl,
  }) {
    return GarageSubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nationalId: nationalId ?? this.nationalId,
      isl: isl ?? this.isl,
      dept: dept ?? this.dept,
      email: email ?? this.email,
      priorityTier: priorityTier ?? this.priorityTier,
      slotLabel: slotLabel ?? this.slotLabel,
      status: status ?? this.status,
      waitingPosition: waitingPosition ?? this.waitingPosition,
      checkedIn: checkedIn ?? this.checkedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      submittedAt: submittedAt ?? this.submittedAt,
      licenseUrl: licenseUrl ?? this.licenseUrl,
    );
  }
}
