// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garage_subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GarageSubscriptionModel _$GarageSubscriptionModelFromJson(
  Map<String, dynamic> json,
) => GarageSubscriptionModel(
  id: json['id'] as String,
  name: json['name'] as String,
  nationalId: json['nationalId'] as String,
  isl: json['isl'] as String,
  dept: json['dept'] as String,
  email: json['email'] as String,
  priorityTier: json['priorityTier'] as String? ?? 'standard',
  slotLabel: json['slotLabel'] as String?,
  status: json['status'] as String? ?? 'active',
  waitingPosition: (json['waitingPosition'] as num?)?.toInt(),
  checkedIn: json['checkedIn'] as bool? ?? false,
  checkedInAt: json['checkedInAt'] == null
      ? null
      : DateTime.parse(json['checkedInAt'] as String),
  submittedAt: DateTime.parse(json['submittedAt'] as String),
  licenseUrl: json['licenseUrl'] as String?,
);

Map<String, dynamic> _$GarageSubscriptionModelToJson(
  GarageSubscriptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nationalId': instance.nationalId,
  'isl': instance.isl,
  'dept': instance.dept,
  'email': instance.email,
  'priorityTier': instance.priorityTier,
  'slotLabel': instance.slotLabel,
  'status': instance.status,
  'waitingPosition': instance.waitingPosition,
  'checkedIn': instance.checkedIn,
  'checkedInAt': instance.checkedInAt?.toIso8601String(),
  'submittedAt': instance.submittedAt.toIso8601String(),
  'licenseUrl': instance.licenseUrl,
};
