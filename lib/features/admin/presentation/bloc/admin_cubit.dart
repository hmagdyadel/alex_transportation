import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alex_transportation/core/extensions/safe_emit_extension.dart';
import 'package:alex_transportation/features/admin/data/models/invite_code_model.dart';
import 'package:alex_transportation/features/admin/presentation/bloc/admin_states.dart';
import 'package:alex_transportation/features/driver/data/models/driver_profile_model.dart';

/// Central Admin Portal Cubit managing tabs, invite codes, driver rosters,
/// and global transport operations stats.
class AdminCubit extends Cubit<AdminStates> {
  int _selectedTab = 0;
  List<InviteCodeModel> _inviteCodes = [];
  List<DriverProfileModel> _captains = [];

  AdminCubit() : super(const AdminStates.initial()) {
    _initAdminData();
  }

  int get selectedTab => _selectedTab;
  List<InviteCodeModel> get inviteCodes => List.unmodifiable(_inviteCodes);
  List<DriverProfileModel> get captains => List.unmodifiable(_captains);

  void setTab(int index) {
    _selectedTab = index;
    safeEmit(const AdminStates.loaded());
  }

  void _initAdminData() {
    _inviteCodes = [
      InviteCodeModel(
        id: 'COD-101',
        code: 'ADM-7788',
        role: 'admin',
        department: 'Operations & IT',
        createdAt: DateTime(2026, 9, 1),
        isActive: true,
        useCount: 14,
        note: 'Executive Transportation Admin Team',
      ),
      InviteCodeModel(
        id: 'COD-102',
        code: 'DRV-5521',
        role: 'driver',
        department: 'Fleet Transport',
        createdAt: DateTime(2026, 9, 2),
        isActive: true,
        useCount: 28,
        note: 'Authorized Captains & Chauffeurs',
      ),
      InviteCodeModel(
        id: 'COD-103',
        code: 'EMP-2026',
        role: 'employee',
        department: 'All Departments',
        createdAt: DateTime(2026, 9, 5),
        isActive: true,
        useCount: 142,
        note: 'General Employee Mobility Pass',
      ),
      InviteCodeModel(
        id: 'COD-104',
        code: 'ALEX26',
        role: 'employee',
        department: 'HQ Smart Village',
        createdAt: DateTime(2026, 9, 10),
        isActive: true,
        useCount: 89,
        note: 'Smart Village Headquarters Pass',
      ),
    ];

    _captains = [
      const DriverProfileModel(
        id: 'DRV-881',
        name: 'Captain Mahmoud Sayed',
        phone: '+20 100 123 4567',
        licenseNumber: 'EGY-COMM-99411',
        assignedBusPlate: 'أ ب ج 1234',
        assignedBusNumber: 'Bus #14',
        assignedRouteId: 'R101',
        assignedRouteName: 'Route 101: Maadi — Smart Village HQ',
        rating: 4.96,
        totalTripsCompleted: 412,
      ),
      const DriverProfileModel(
        id: 'DRV-882',
        name: 'Captain Tarek Fawzy',
        phone: '+20 102 987 6543',
        licenseNumber: 'EGY-COMM-99412',
        assignedBusPlate: 'د هـ و 5678',
        assignedBusNumber: 'Bus #22',
        assignedRouteId: 'R102',
        assignedRouteName: 'Route 102: New Cairo — Smart Village HQ',
        rating: 4.92,
        totalTripsCompleted: 356,
      ),
      const DriverProfileModel(
        id: 'DRV-883',
        name: 'Captain Essam Nabil',
        phone: '+20 111 555 8899',
        licenseNumber: 'EGY-COMM-99413',
        assignedBusPlate: 'س ع ص 9012',
        assignedBusNumber: 'Bus #08',
        assignedRouteId: 'R103',
        assignedRouteName: 'Route 103: Heliopolis — Smart Village HQ',
        rating: 4.88,
        totalTripsCompleted: 298,
      ),
      const DriverProfileModel(
        id: 'DRV-884',
        name: 'Captain Sameh Refaat',
        phone: '+20 122 333 4411',
        licenseNumber: 'EGY-COMM-99414',
        assignedBusPlate: 'ط ي ك 3456',
        assignedBusNumber: 'Bus #31',
        assignedRouteId: 'R104',
        assignedRouteName: 'Route 104: 6th October — Smart Village HQ',
        rating: 4.94,
        totalTripsCompleted: 430,
      ),
      const DriverProfileModel(
        id: 'DRV-885',
        name: 'Chauffeur Khaled Nasser',
        phone: '+20 101 222 3344',
        licenseNumber: 'EGY-COMM-99415',
        assignedBusPlate: 'أ ب ج 4567',
        assignedBusNumber: 'Mercedes-Benz E-Class',
        assignedRouteId: 'ERRAND-01',
        assignedRouteName: 'Executive Errand Fleet (CAR-001)',
        rating: 4.98,
        totalTripsCompleted: 520,
      ),
      const DriverProfileModel(
        id: 'DRV-886',
        name: 'Chauffeur Yasser Galal',
        phone: '+20 106 777 8899',
        licenseNumber: 'EGY-COMM-99416',
        assignedBusPlate: 'ر ز س 7890',
        assignedBusNumber: 'BMW 5 Series',
        assignedRouteId: 'ERRAND-02',
        assignedRouteName: 'Executive Errand Fleet (CAR-002)',
        rating: 4.91,
        totalTripsCompleted: 215,
      ),
    ];
  }

  /// Generates a new access invite code.
  Future<void> generateInviteCode({
    required String role,
    required String department,
    String? note,
  }) async {
    safeEmit(const AdminStates.generatingCode());
    await Future.delayed(const Duration(milliseconds: 600));

    final prefix = role == 'admin' ? 'ADM' : (role == 'driver' ? 'DRV' : 'EMP');
    final randomNum = (1000 + DateTime.now().millisecondsSinceEpoch % 9000);
    final code = '$prefix-$randomNum';

    final newCode = InviteCodeModel(
      id: 'COD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      code: code,
      role: role,
      department: department,
      createdAt: DateTime.now(),
      isActive: true,
      note: note,
    );

    _inviteCodes.insert(0, newCode);
    safeEmit(AdminStates.success('Invite code "$code" created successfully'));
    safeEmit(const AdminStates.loaded());
  }

  /// Toggles the active status of an invite code.
  void toggleInviteCode(String id) {
    final index = _inviteCodes.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final current = _inviteCodes[index];
    _inviteCodes[index] = current.copyWith(isActive: !current.isActive);
    safeEmit(
      AdminStates.success(
        'Code ${current.code} is now ${!current.isActive ? "ACTIVE" : "INACTIVE"}',
      ),
    );
    safeEmit(const AdminStates.loaded());
  }

  /// Revokes / deletes an invite code.
  void revokeInviteCode(String id) {
    final code = _inviteCodes.firstWhere(
      (c) => c.id == id,
      orElse: () => _inviteCodes.first,
    );
    _inviteCodes.removeWhere((c) => c.id == id);
    safeEmit(AdminStates.success('Invite code ${code.code} has been revoked'));
    safeEmit(const AdminStates.loaded());
  }

  /// Reassigns a driver to a bus route or errand duty.
  void reassignDriver(
    String driverId, {
    required String newRouteId,
    required String newRouteName,
  }) {
    final index = _captains.indexWhere((d) => d.id == driverId);
    if (index == -1) return;

    final current = _captains[index];
    _captains[index] = current.copyWith(
      assignedRouteId: newRouteId,
      assignedRouteName: newRouteName,
    );
    safeEmit(
      AdminStates.success('Driver ${current.name} reassigned to $newRouteName'),
    );
    safeEmit(const AdminStates.loaded());
  }
}
