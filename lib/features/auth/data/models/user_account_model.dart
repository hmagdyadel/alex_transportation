import 'package:json_annotation/json_annotation.dart';

part 'user_account_model.g.dart';

/// User account model for ISL + Password authentication and role-based access.
@JsonSerializable()
class UserAccountModel {
  final String isl;
  final String name;
  final String department;
  final String role; // 'employee', 'driver', 'admin'
  final String password;
  final DateTime? createdAt;
  final bool isActive;

  const UserAccountModel({
    required this.isl,
    required this.name,
    required this.department,
    required this.role,
    required this.password,
    this.createdAt,
    this.isActive = true,
  });

  factory UserAccountModel.fromJson(Map<String, dynamic> json) =>
      _$UserAccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAccountModelToJson(this);

  UserAccountModel copyWith({
    String? isl,
    String? name,
    String? department,
    String? role,
    String? password,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserAccountModel(
      isl: isl ?? this.isl,
      name: name ?? this.name,
      department: department ?? this.department,
      role: role ?? this.role,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
