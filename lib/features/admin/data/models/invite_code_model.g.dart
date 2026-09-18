// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteCodeModel _$InviteCodeModelFromJson(Map<String, dynamic> json) =>
    InviteCodeModel(
      id: json['id'] as String,
      code: json['code'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      useCount: (json['useCount'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$InviteCodeModelToJson(InviteCodeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'role': instance.role,
      'department': instance.department,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
      'useCount': instance.useCount,
      'note': instance.note,
    };
