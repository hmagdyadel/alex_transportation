import 'package:json_annotation/json_annotation.dart';

part 'invite_code_model.g.dart';

@JsonSerializable()
class InviteCodeModel {
  final String id;
  final String code;
  final String role; // 'employee', 'driver', 'admin'
  final String department;
  final DateTime createdAt;
  final bool isActive;
  final int useCount;
  final String? note;

  const InviteCodeModel({
    required this.id,
    required this.code,
    required this.role,
    required this.department,
    required this.createdAt,
    this.isActive = true,
    this.useCount = 0,
    this.note,
  });

  factory InviteCodeModel.fromJson(Map<String, dynamic> json) =>
      _$InviteCodeModelFromJson(json);

  Map<String, dynamic> toJson() => _$InviteCodeModelToJson(this);

  InviteCodeModel copyWith({
    String? id,
    String? code,
    String? role,
    String? department,
    DateTime? createdAt,
    bool? isActive,
    int? useCount,
    String? note,
  }) {
    return InviteCodeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      role: role ?? this.role,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      useCount: useCount ?? this.useCount,
      note: note ?? this.note,
    );
  }
}
