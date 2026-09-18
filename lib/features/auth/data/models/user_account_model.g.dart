// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAccountModel _$UserAccountModelFromJson(Map<String, dynamic> json) =>
    UserAccountModel(
      isl: json['isl'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      role: json['role'] as String,
      password: json['password'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$UserAccountModelToJson(UserAccountModel instance) =>
    <String, dynamic>{
      'isl': instance.isl,
      'name': instance.name,
      'department': instance.department,
      'role': instance.role,
      'password': instance.password,
      'createdAt': instance.createdAt?.toIso8601String(),
      'isActive': instance.isActive,
    };
