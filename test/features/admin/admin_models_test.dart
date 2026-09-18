import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/features/admin/data/models/invite_code_model.dart';

void main() {
  group('InviteCodeModel', () {
    final json = {
      'id': 'COD-101',
      'code': 'ADM-7788',
      'role': 'admin',
      'department': 'Operations & IT',
      'createdAt': '2026-09-01T00:00:00.000',
      'isActive': true,
      'useCount': 14,
      'note': 'Executive Transportation Admin Team',
    };

    test('fromJson creates valid model', () {
      final model = InviteCodeModel.fromJson(json);
      expect(model.id, 'COD-101');
      expect(model.code, 'ADM-7788');
      expect(model.role, 'admin');
      expect(model.department, 'Operations & IT');
      expect(model.isActive, true);
      expect(model.useCount, 14);
      expect(model.note, 'Executive Transportation Admin Team');
    });

    test('toJson produces valid JSON', () {
      final model = InviteCodeModel.fromJson(json);
      final out = model.toJson();
      expect(out['id'], 'COD-101');
      expect(out['code'], 'ADM-7788');
      expect(out['role'], 'admin');
      expect(out['isActive'], true);
    });

    test('copyWith overrides fields', () {
      final model = InviteCodeModel.fromJson(json);
      final toggled = model.copyWith(isActive: false, useCount: 15);
      expect(toggled.isActive, false);
      expect(toggled.useCount, 15);
      expect(toggled.code, model.code);
    });
  });
}
