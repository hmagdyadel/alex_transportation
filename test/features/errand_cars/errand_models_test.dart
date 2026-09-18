import 'package:flutter_test/flutter_test.dart';

import 'package:alex_transportation/features/errand_cars/data/models/errand_car_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_request_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_dispatch_pass_model.dart';

void main() {
  group('ErrandCarModel', () {
    final json = {
      'id': 'CAR-001',
      'plateNumber': 'أ ب ج 4567',
      'make': 'Mercedes-Benz E-Class',
      'color': 'Black',
      'status': 'available',
      'currentMileage': 34520,
      'lastServiceDate': '2026-09-01T00:00:00.000',
    };

    test('fromJson creates valid model', () {
      final model = ErrandCarModel.fromJson(json);
      expect(model.id, 'CAR-001');
      expect(model.plateNumber, 'أ ب ج 4567');
      expect(model.make, 'Mercedes-Benz E-Class');
      expect(model.color, 'Black');
      expect(model.status, 'available');
      expect(model.currentMileage, 34520);
      expect(model.lastServiceDate, isNotNull);
    });

    test('toJson produces valid JSON', () {
      final model = ErrandCarModel.fromJson(json);
      final output = model.toJson();
      expect(output['id'], 'CAR-001');
      expect(output['plateNumber'], 'أ ب ج 4567');
      expect(output['make'], 'Mercedes-Benz E-Class');
      expect(output['currentMileage'], 34520);
    });

    test('copyWith overrides fields', () {
      final model = ErrandCarModel.fromJson(json);
      final updated = model.copyWith(status: 'in_use', currentMileage: 35000);
      expect(updated.status, 'in_use');
      expect(updated.currentMileage, 35000);
      expect(updated.id, model.id); // Unchanged
      expect(updated.make, model.make); // Unchanged
    });
  });

  group('ErrandRequestModel', () {
    final json = {
      'id': 'ERQ-3942',
      'employeeName': 'Ahmed Hassan',
      'employeeIsl': '10234',
      'department': 'IT',
      'destination': 'Finance Hub Branch',
      'purpose': 'Deliver documents',
      'requestedDate': '18 Sep 2026',
      'requestedTime': '10:00 AM',
      'estimatedReturnTime': '02:00 PM',
      'supervisorName': 'Dr. Hany Fouad',
      'status': 'approved',
      'assignedCarId': 'CAR-001',
      'assignedCarPlate': 'أ ب ج 4567',
      'assignedCarMake': 'Mercedes-Benz E-Class',
      'assignedDriverName': 'Khaled Nasser',
      'submittedAt': '2026-09-17T14:30:00.000',
      'approvedAt': '2026-09-17T15:45:00.000',
    };

    test('fromJson creates valid model', () {
      final model = ErrandRequestModel.fromJson(json);
      expect(model.id, 'ERQ-3942');
      expect(model.employeeName, 'Ahmed Hassan');
      expect(model.employeeIsl, '10234');
      expect(model.department, 'IT');
      expect(model.destination, 'Finance Hub Branch');
      expect(model.purpose, 'Deliver documents');
      expect(model.status, 'approved');
      expect(model.assignedCarId, 'CAR-001');
      expect(model.assignedCarPlate, 'أ ب ج 4567');
      expect(model.assignedDriverName, 'Khaled Nasser');
      expect(model.submittedAt, isNotNull);
      expect(model.approvedAt, isNotNull);
    });

    test('toJson produces valid JSON', () {
      final model = ErrandRequestModel.fromJson(json);
      final output = model.toJson();
      expect(output['id'], 'ERQ-3942');
      expect(output['employeeName'], 'Ahmed Hassan');
      expect(output['status'], 'approved');
      expect(output['assignedCarId'], 'CAR-001');
    });

    test('copyWith overrides status', () {
      final model = ErrandRequestModel.fromJson(json);
      final cancelled = model.copyWith(status: 'cancelled');
      expect(cancelled.status, 'cancelled');
      expect(cancelled.id, model.id);
      expect(cancelled.destination, model.destination);
    });

    test('fromJson with null optional fields', () {
      final minJson = {
        'id': 'ERQ-0001',
        'employeeName': 'Test',
        'employeeIsl': '99999',
        'department': 'HR',
        'destination': 'Branch X',
        'purpose': 'Delivery',
        'requestedDate': '01 Jan 2026',
        'requestedTime': '09:00 AM',
        'estimatedReturnTime': '12:00 PM',
        'supervisorName': 'Manager',
        'status': 'pending',
        'submittedAt': '2026-01-01T09:00:00.000',
      };
      final model = ErrandRequestModel.fromJson(minJson);
      expect(model.assignedCarId, isNull);
      expect(model.assignedCarPlate, isNull);
      expect(model.assignedDriverName, isNull);
      expect(model.approvedAt, isNull);
    });
  });

  group('ErrandDispatchPassModel', () {
    final json = {
      'id': 'ABX-3942',
      'requestId': 'ERQ-3942',
      'missionCode': 'CPT-912',
      'employeeName': 'Ahmed Hassan',
      'destination': 'Finance Hub Branch',
      'carPlate': 'أ ب ج 4567',
      'carMake': 'Mercedes-Benz E-Class',
      'departureTime': '10:00 AM',
      'estimatedReturn': '02:00 PM',
      'status': 'active',
      'startMileage': 34520,
      'qrPayload': 'ALEXBANK:ERRAND:ABX-3942:CPT-912:AHMED-HASSAN:FINANCE-HUB',
    };

    test('fromJson creates valid model', () {
      final model = ErrandDispatchPassModel.fromJson(json);
      expect(model.id, 'ABX-3942');
      expect(model.requestId, 'ERQ-3942');
      expect(model.missionCode, 'CPT-912');
      expect(model.employeeName, 'Ahmed Hassan');
      expect(model.destination, 'Finance Hub Branch');
      expect(model.carPlate, 'أ ب ج 4567');
      expect(model.carMake, 'Mercedes-Benz E-Class');
      expect(model.status, 'active');
      expect(model.startMileage, 34520);
      expect(model.endMileage, isNull);
      expect(model.qrPayload, contains('ALEXBANK:ERRAND'));
    });

    test('toJson produces valid JSON', () {
      final model = ErrandDispatchPassModel.fromJson(json);
      final output = model.toJson();
      expect(output['id'], 'ABX-3942');
      expect(output['missionCode'], 'CPT-912');
      expect(output['startMileage'], 34520);
    });

    test('distanceDriven returns null when endMileage is null', () {
      final model = ErrandDispatchPassModel.fromJson(json);
      expect(model.distanceDriven, isNull);
    });

    test('distanceDriven computes correctly with endMileage', () {
      final model = ErrandDispatchPassModel.fromJson(json);
      final completed = model.copyWith(
        status: 'completed',
        endMileage: 34580,
      );
      expect(completed.distanceDriven, 60);
    });

    test('copyWith overrides status and mileage', () {
      final model = ErrandDispatchPassModel.fromJson(json);
      final updated = model.copyWith(
        status: 'completed',
        endMileage: 34600,
      );
      expect(updated.status, 'completed');
      expect(updated.endMileage, 34600);
      expect(updated.startMileage, 34520);
      expect(updated.id, model.id);
    });
  });
}
