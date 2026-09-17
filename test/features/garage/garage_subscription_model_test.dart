import 'package:flutter_test/flutter_test.dart';
import 'package:alex_transportation/features/garage/data/models/garage_subscription_model.dart';

void main() {
  group('GarageSubscriptionModel JSON Serialization', () {
    final now = DateTime.parse('2026-09-17T20:00:00.000Z');

    final testModel = GarageSubscriptionModel(
      id: 'sub-001',
      name: 'Ahmed Hassan',
      nationalId: '29001011234567',
      isl: 'ISL-8821',
      dept: 'Corporate Banking',
      email: 'ahmed.hassan@alexbank.com',
      priorityTier: 'standard',
      slotLabel: 'P1-014',
      status: 'active',
      waitingPosition: null,
      checkedIn: true,
      checkedInAt: now,
      submittedAt: now,
      licenseUrl: 'https://example.com/license.jpg',
    );

    test('toJson serializes correctly with pure json_serializable', () {
      final json = testModel.toJson();

      expect(json['id'], 'sub-001');
      expect(json['name'], 'Ahmed Hassan');
      expect(json['nationalId'], '29001011234567');
      expect(json['isl'], 'ISL-8821');
      expect(json['dept'], 'Corporate Banking');
      expect(json['email'], 'ahmed.hassan@alexbank.com');
      expect(json['priorityTier'], 'standard');
      expect(json['slotLabel'], 'P1-014');
      expect(json['status'], 'active');
      expect(json['checkedIn'], true);
      expect(json['checkedInAt'], now.toIso8601String());
      expect(json['submittedAt'], now.toIso8601String());
      expect(json['licenseUrl'], 'https://example.com/license.jpg');
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'sub-002',
        'name': 'Sara Ibrahim',
        'nationalId': '29505051234568',
        'isl': 'ISL-4412',
        'dept': 'Retail Risk',
        'email': 'sara.ibrahim@alexbank.com',
        'priorityTier': 'vip',
        'slotLabel': 'VIP-002',
        'status': 'active',
        'waitingPosition': null,
        'checkedIn': false,
        'checkedInAt': null,
        'submittedAt': '2026-09-17T18:00:00.000Z',
        'licenseUrl': null,
      };

      final model = GarageSubscriptionModel.fromJson(json);

      expect(model.id, 'sub-002');
      expect(model.name, 'Sara Ibrahim');
      expect(model.priorityTier, 'vip');
      expect(model.slotLabel, 'VIP-002');
      expect(model.status, 'active');
      expect(model.checkedIn, false);
      expect(model.checkedInAt, isNull);
      expect(model.licenseUrl, isNull);
    });

    test('copyWith updates specified fields correctly', () {
      final updated = testModel.copyWith(
        checkedIn: false,
        slotLabel: 'P2-105',
      );

      expect(updated.id, testModel.id);
      expect(updated.name, testModel.name);
      expect(updated.checkedIn, false);
      expect(updated.slotLabel, 'P2-105');
    });
  });
}
