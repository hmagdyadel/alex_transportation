import 'package:flutter/foundation.dart';

import 'package:alex_transportation/core/network/firestore_sync_service.dart';
import 'package:alex_transportation/features/admin/data/models/invite_code_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_boarding_pass_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_stop_model.dart';
import 'package:alex_transportation/features/driver/data/models/driver_profile_model.dart';
import 'package:alex_transportation/features/driver/data/models/driver_trip_model.dart';
import 'package:alex_transportation/features/driver/data/models/trip_manifest_item_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_car_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_dispatch_pass_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_request_model.dart';
import 'package:alex_transportation/features/garage/data/models/garage_subscription_model.dart';

/// Official Transit Data Seeder for Cloud Firestore.
///
/// Seeds the official AlexBank transportation system master data into Cloud
/// Firestore collections if the database is newly initialized or empty.
class FirestoreDataSeeder {
  const FirestoreDataSeeder._();

  static List<BusRouteModel> get initialRoutes => _initialRoutes;
  static List<ErrandCarModel> get initialFleet => _initialFleet;
  static List<ErrandRequestModel> get initialRequests => _initialRequests;
  static ErrandDispatchPassModel get initialErrandPass => _initialErrandPass;
  static List<InviteCodeModel> get initialCodes => _initialCodes;
  static List<GarageSubscriptionModel> get initialSubscriptions => _initialSubscriptions;
  static BusBoardingPassModel get initialBusPass => _initialBusPass;
  static List<BusBoardingPassModel> get initialBusBookings => _initialBusBookings;
  static DriverProfileModel get initialDriverProfile => _initialDriverProfile;
  static DriverTripModel get initialDriverTrip => _initialDriverTrip;

  /// Checks Firestore collections and seeds production data if empty.
  static Future<void> seedInitialDataIfNeeded() async {
    final sync = FirestoreSyncService.instance;

    try {
      // 1. Bus Routes
      final routes = await sync.getBusRoutes();
      if (routes.isEmpty) {
        debugPrint('[FirestoreSeeder] Seeding official bus routes to Firestore...');
        for (final route in _initialRoutes) {
          await sync.saveBusRoute(route);
        }
        debugPrint('[FirestoreSeeder] ✓ Seeded ${_initialRoutes.length} bus routes.');
      }

      // 2. Bus Bookings
      final bookings = await sync.getBusBookings();
      if (bookings.isEmpty) {
        debugPrint('[FirestoreSeeder] Seeding bus bookings to Firestore...');
        for (final b in _initialBusBookings) {
          await sync.saveBusBooking(b);
        }
      }

      // 3. Errand Fleet
      final fleet = await sync.getErrandFleet();
      if (fleet.isEmpty) {
        debugPrint('[FirestoreSeeder] Seeding errand fleet to Firestore...');
        for (final car in _initialFleet) {
          await sync.saveErrandCar(car);
        }
        debugPrint('[FirestoreSeeder] ✓ Seeded ${_initialFleet.length} errand cars.');
      }

      // 4. Errand Requests
      final requests = await sync.getErrandRequests();
      if (requests.isEmpty) {
        debugPrint('[FirestoreSeeder] Seeding errand requests to Firestore...');
        for (final req in _initialRequests) {
          await sync.saveErrandRequest(req);
        }
      }

      // 5. Invite Codes
      final codes = await sync.getInviteCodes();
      if (codes.isEmpty) {
        debugPrint('[FirestoreSeeder] Seeding access invite codes to Firestore...');
        for (final code in _initialCodes) {
          await sync.saveInviteCode(code);
        }
        debugPrint('[FirestoreSeeder] ✓ Seeded ${_initialCodes.length} invite codes.');
      }

      // 6. Garage Subscriptions
      final subscriptions = await sync.getGarageSubscriptions();
      if (subscriptions.isEmpty) {
        debugPrint('[FirestoreSeeder] Seeding garage subscriptions to Firestore...');
        for (final sub in _initialSubscriptions) {
          await sync.saveGarageSubscription(sub);
        }
        debugPrint('[FirestoreSeeder] ✓ Seeded ${_initialSubscriptions.length} garage subscriptions.');
      }

      // 7. Driver Trip
      final trip = await sync.getDriverTrip('TRIP-20260918-101');
      if (trip == null) {
        debugPrint('[FirestoreSeeder] Seeding driver active trip to Firestore...');
        await sync.saveDriverTrip(_initialDriverTrip);
      }
    } catch (e) {
      debugPrint('[FirestoreSeeder] ✕ Seeding error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BUS ROUTES & BOOKINGS
  // ──────────────────────────────────────────────────────────────────────────

  static final List<BusRouteModel> _initialRoutes = [
    // MORNING ROUTES (Cairo / Giza -> Smart Village HQ)
    const BusRouteModel(
      id: 'R101',
      routeNumber: 'Route 101',
      name: 'Maadi — Smart Village HQ',
      shift: 'Morning',
      departureTime: '07:15 AM',
      estimatedArrival: '08:30 AM',
      totalSeats: 28,
      availableSeats: 6,
      driverName: 'Mahmoud Sayed',
      driverPhone: '+20 100 123 4567',
      busPlate: 'أ ب ج 1234',
      status: 'en_route',
      stops: [
        BusStopModel(
          id: 'S101-1',
          name: 'Victoria Square',
          nameAr: 'ميدان فيكتوريا',
          scheduledTime: '07:15 AM',
          isCompleted: true,
          order: 1,
          latitude: 29.9602,
          longitude: 31.2568,
        ),
        BusStopModel(
          id: 'S101-2',
          name: 'Degla Center',
          nameAr: 'سنتر دجلة',
          scheduledTime: '07:30 AM',
          isCompleted: true,
          isCurrent: true,
          order: 2,
          latitude: 29.9575,
          longitude: 31.2750,
        ),
        BusStopModel(
          id: 'S101-3',
          name: 'Arab Intersection',
          nameAr: 'تقاطع العرب',
          scheduledTime: '07:45 AM',
          order: 3,
          latitude: 29.9710,
          longitude: 31.2820,
        ),
        BusStopModel(
          id: 'S101-4',
          name: 'Autostrad / Ring Road',
          nameAr: 'الأوتوستراد والدائري',
          scheduledTime: '08:05 AM',
          order: 4,
          latitude: 29.9850,
          longitude: 31.3050,
        ),
        BusStopModel(
          id: 'S101-5',
          name: 'Smart Village (AlexBank HQ)',
          nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
          scheduledTime: '08:30 AM',
          order: 5,
          latitude: 30.0715,
          longitude: 31.0210,
        ),
      ],
    ),
    const BusRouteModel(
      id: 'R102',
      routeNumber: 'Route 102',
      name: 'New Cairo & Tagamoa — Smart Village HQ',
      shift: 'Morning',
      departureTime: '07:00 AM',
      estimatedArrival: '08:25 AM',
      totalSeats: 28,
      availableSeats: 3,
      driverName: 'Tarek Fawzy',
      driverPhone: '+20 102 987 6543',
      busPlate: 'د هـ و 5678',
      status: 'on_time',
      stops: [
        BusStopModel(
          id: 'S102-1',
          name: '90th Street North',
          nameAr: 'شمال التسعين',
          scheduledTime: '07:00 AM',
          order: 1,
          latitude: 30.0315,
          longitude: 31.4720,
        ),
        BusStopModel(
          id: 'S102-2',
          name: 'Concord Plaza',
          nameAr: 'كونكورد بلازا',
          scheduledTime: '07:20 AM',
          order: 2,
          latitude: 30.0270,
          longitude: 31.4920,
        ),
        BusStopModel(
          id: 'S102-3',
          name: 'Choueifat Junction',
          nameAr: 'تقاطع الشويفات',
          scheduledTime: '07:40 AM',
          order: 3,
          latitude: 30.0120,
          longitude: 31.4350,
        ),
        BusStopModel(
          id: 'S102-4',
          name: 'Ring Road — Katameya',
          nameAr: 'الدائري والقطامية',
          scheduledTime: '08:00 AM',
          order: 4,
          latitude: 29.9980,
          longitude: 31.3850,
        ),
        BusStopModel(
          id: 'S102-5',
          name: 'Smart Village (AlexBank HQ)',
          nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
          scheduledTime: '08:25 AM',
          order: 5,
          latitude: 30.0715,
          longitude: 31.0210,
        ),
      ],
    ),
    const BusRouteModel(
      id: 'R103',
      routeNumber: 'Route 103',
      name: 'Heliopolis & Nasr City — Smart Village HQ',
      shift: 'Morning',
      departureTime: '07:20 AM',
      estimatedArrival: '08:35 AM',
      totalSeats: 28,
      availableSeats: 0,
      driverName: 'Essam Nabil',
      driverPhone: '+20 111 555 8899',
      busPlate: 'س ع ص 9012',
      status: 'on_time',
      stops: [
        BusStopModel(
          id: 'S103-1',
          name: 'Korba Square',
          nameAr: 'ميدان الكوربة',
          scheduledTime: '07:20 AM',
          order: 1,
        ),
        BusStopModel(
          id: 'S103-2',
          name: 'Roxy Plaza',
          nameAr: 'روكسي',
          scheduledTime: '07:35 AM',
          order: 2,
        ),
        BusStopModel(
          id: 'S103-3',
          name: 'Abbas El Akkad',
          nameAr: 'عباس العقاد',
          scheduledTime: '07:55 AM',
          order: 3,
        ),
        BusStopModel(
          id: 'S103-4',
          name: 'Tayaran Intersection',
          nameAr: 'تقاطع الطيران',
          scheduledTime: '08:10 AM',
          order: 4,
        ),
        BusStopModel(
          id: 'S103-5',
          name: 'Smart Village (AlexBank HQ)',
          nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
          scheduledTime: '08:35 AM',
          order: 5,
        ),
      ],
    ),
    const BusRouteModel(
      id: 'R104',
      routeNumber: 'Route 104',
      name: '6th of October & Zayed — Smart Village HQ',
      shift: 'Morning',
      departureTime: '06:45 AM',
      estimatedArrival: '08:20 AM',
      totalSeats: 28,
      availableSeats: 8,
      driverName: 'Sameh Refaat',
      driverPhone: '+20 122 333 4411',
      busPlate: 'ط ي ك 3456',
      status: 'on_time',
      stops: [
        BusStopModel(
          id: 'S104-1',
          name: 'Hosary Mosque',
          nameAr: 'جامع الحصري',
          scheduledTime: '06:45 AM',
          order: 1,
        ),
        BusStopModel(
          id: 'S104-2',
          name: 'Sheikh Zayed Entrance 1',
          nameAr: 'مدخل زايد 1',
          scheduledTime: '07:05 AM',
          order: 2,
        ),
        BusStopModel(
          id: 'S104-3',
          name: 'Hyper One',
          nameAr: 'هايبر وان',
          scheduledTime: '07:25 AM',
          order: 3,
        ),
        BusStopModel(
          id: 'S104-4',
          name: 'Mehwar Axis',
          nameAr: 'محور 26 يوليو',
          scheduledTime: '07:45 AM',
          order: 4,
        ),
        BusStopModel(
          id: 'S104-5',
          name: 'Smart Village (AlexBank HQ)',
          nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
          scheduledTime: '08:20 AM',
          order: 5,
        ),
      ],
    ),

    // MIRRORED EVENING ROUTES (Smart Village HQ -> Cairo / Giza in reverse order)
    const BusRouteModel(
      id: 'R201',
      routeNumber: 'Route 201',
      name: 'Smart Village HQ — Maadi Return',
      shift: 'Evening',
      departureTime: '04:45 PM',
      estimatedArrival: '06:00 PM',
      totalSeats: 28,
      availableSeats: 12,
      driverName: 'Mahmoud Sayed',
      driverPhone: '+20 100 123 4567',
      busPlate: 'أ ب ج 1234',
      status: 'on_time',
      stops: [
        BusStopModel(
          id: 'S201-1',
          name: 'Smart Village (AlexBank HQ)',
          nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
          scheduledTime: '04:45 PM',
          order: 1,
        ),
        BusStopModel(
          id: 'S201-2',
          name: 'Autostrad / Ring Road',
          nameAr: 'الأوتوستراد والدائري',
          scheduledTime: '05:10 PM',
          order: 2,
        ),
        BusStopModel(
          id: 'S201-3',
          name: 'Arab Intersection',
          nameAr: 'تقاطع العرب',
          scheduledTime: '05:30 PM',
          order: 3,
        ),
        BusStopModel(
          id: 'S201-4',
          name: 'Degla Center',
          nameAr: 'سنتر دجلة',
          scheduledTime: '05:45 PM',
          order: 4,
        ),
        BusStopModel(
          id: 'S201-5',
          name: 'Victoria Square',
          nameAr: 'ميدان فيكتوريا',
          scheduledTime: '06:00 PM',
          order: 5,
        ),
      ],
    ),
    const BusRouteModel(
      id: 'R202',
      routeNumber: 'Route 202',
      name: 'Smart Village HQ — New Cairo Return',
      shift: 'Evening',
      departureTime: '04:45 PM',
      estimatedArrival: '06:15 PM',
      totalSeats: 28,
      availableSeats: 15,
      driverName: 'Tarek Fawzy',
      driverPhone: '+20 102 987 6543',
      busPlate: 'د هـ و 5678',
      status: 'on_time',
      stops: [
        BusStopModel(
          id: 'S202-1',
          name: 'Smart Village (AlexBank HQ)',
          nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
          scheduledTime: '04:45 PM',
          order: 1,
        ),
        BusStopModel(
          id: 'S202-2',
          name: 'Ring Road — Katameya',
          nameAr: 'الدائري والقطامية',
          scheduledTime: '05:15 PM',
          order: 2,
        ),
        BusStopModel(
          id: 'S202-3',
          name: 'Choueifat Junction',
          nameAr: 'تقاطع الشويفات',
          scheduledTime: '05:35 PM',
          order: 3,
        ),
        BusStopModel(
          id: 'S202-4',
          name: 'Concord Plaza',
          nameAr: 'كونكورد بلازا',
          scheduledTime: '05:55 PM',
          order: 4,
        ),
        BusStopModel(
          id: 'S202-5',
          name: '90th Street North',
          nameAr: 'شمال التسعين',
          scheduledTime: '06:15 PM',
          order: 5,
        ),
      ],
    ),
    const BusRouteModel(
      id: 'R203',
      routeNumber: 'Route 203',
      name: 'Smart Village HQ — Heliopolis & Nasr City Return',
      shift: 'Evening',
      departureTime: '04:45 PM',
      estimatedArrival: '06:10 PM',
      totalSeats: 28,
      availableSeats: 10,
      driverName: 'Essam Nabil',
      driverPhone: '+20 111 555 8899',
      busPlate: 'س ع ص 9012',
      status: 'on_time',
      stops: [
        BusStopModel(
          id: 'S203-1',
          name: 'Smart Village (AlexBank HQ)',
          nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
          scheduledTime: '04:45 PM',
          order: 1,
        ),
        BusStopModel(
          id: 'S203-2',
          name: 'Tayaran Intersection',
          nameAr: 'تقاطع الطيران',
          scheduledTime: '05:20 PM',
          order: 2,
        ),
        BusStopModel(
          id: 'S203-3',
          name: 'Abbas El Akkad',
          nameAr: 'عباس العقاد',
          scheduledTime: '05:35 PM',
          order: 3,
        ),
        BusStopModel(
          id: 'S203-4',
          name: 'Roxy Plaza',
          nameAr: 'روكسي',
          scheduledTime: '05:50 PM',
          order: 4,
        ),
        BusStopModel(
          id: 'S203-5',
          name: 'Korba Square',
          nameAr: 'ميدان الكوربة',
          scheduledTime: '06:10 PM',
          order: 5,
        ),
      ],
    ),
    const BusRouteModel(
      id: 'R204',
      routeNumber: 'Route 204',
      name: 'Smart Village HQ — 6th of October & Zayed Return',
      shift: 'Evening',
      departureTime: '04:45 PM',
      estimatedArrival: '05:55 PM',
      totalSeats: 28,
      availableSeats: 14,
      driverName: 'Sameh Refaat',
      driverPhone: '+20 122 333 4411',
      busPlate: 'ط ي ك 3456',
      status: 'on_time',
      stops: [
        BusStopModel(
          id: 'S204-1',
          name: 'Smart Village (AlexBank HQ)',
          nameAr: 'القرية الذكية - مقر بنك الإسكندرية',
          scheduledTime: '04:45 PM',
          order: 1,
        ),
        BusStopModel(
          id: 'S204-2',
          name: 'Mehwar Axis',
          nameAr: 'محور 26 يوليو',
          scheduledTime: '05:05 PM',
          order: 2,
        ),
        BusStopModel(
          id: 'S204-3',
          name: 'Hyper One',
          nameAr: 'هايبر وان',
          scheduledTime: '05:20 PM',
          order: 3,
        ),
        BusStopModel(
          id: 'S204-4',
          name: 'Sheikh Zayed Entrance 1',
          nameAr: 'مدخل زايد 1',
          scheduledTime: '05:35 PM',
          order: 4,
        ),
        BusStopModel(
          id: 'S204-5',
          name: 'Hosary Mosque',
          nameAr: 'جامع الحصري',
          scheduledTime: '05:55 PM',
          order: 5,
        ),
      ],
    ),
  ];

  static final BusBoardingPassModel _initialBusPass = BusBoardingPassModel(
    id: 'PASS-88214',
    routeId: 'R101',
    routeName: 'Maadi — HQ Express',
    routeNumber: 'Route 101',
    busNumber: 'Bus #14',
    stopName: 'Victoria Square',
    seatNumber: 14,
    employeeName: 'Ahmed Hassan',
    departureTime: '07:15 AM',
    status: 'active',
    qrPayload: 'ALEXBANK-TRANSIT:Route 101:SEAT-14:Ahmed Hassan:PASS-88214',
    bookedAt: DateTime(2026, 9, 18, 7, 0),
  );

  static final List<BusBoardingPassModel> _initialBusBookings = [
    _initialBusPass,
    BusBoardingPassModel(
      id: 'SUB-101',
      routeId: 'R101',
      routeName: 'Maadi — Smart Village HQ',
      routeNumber: 'Route 101',
      busNumber: 'Bus #1',
      stopName: 'Victoria Square',
      seatNumber: 1,
      employeeName: 'Tarek Mostafa',
      departureTime: '07:15 AM',
      status: 'active',
      qrPayload: 'ALEXBANK-TRANSIT:Route 101:SEAT-1:Tarek Mostafa:SUB-101',
      bookedAt: DateTime(2026, 9, 17, 10, 0),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // ERRAND CAR FLEET & REQUESTS
  // ──────────────────────────────────────────────────────────────────────────

  static final List<ErrandCarModel> _initialFleet = [
    ErrandCarModel(
      id: 'CAR-001',
      plateNumber: 'أ ب ج 4567',
      make: 'Mercedes-Benz E-Class',
      color: 'Black',
      status: 'in_use',
      currentMileage: 34520,
      lastServiceDate: DateTime(2026, 8, 15),
    ),
    ErrandCarModel(
      id: 'CAR-002',
      plateNumber: 'د هـ و 8901',
      make: 'BMW 520i',
      color: 'Dark Grey',
      status: 'available',
      currentMileage: 28310,
      lastServiceDate: DateTime(2026, 9, 1),
    ),
    ErrandCarModel(
      id: 'CAR-003',
      plateNumber: 'س ع ص 2345',
      make: 'Toyota Camry',
      color: 'White',
      status: 'available',
      currentMileage: 41870,
      lastServiceDate: DateTime(2026, 7, 20),
    ),
    ErrandCarModel(
      id: 'CAR-004',
      plateNumber: 'ط ي ك 6789',
      make: 'Hyundai Sonata',
      color: 'Silver',
      status: 'available',
      currentMileage: 19450,
      lastServiceDate: DateTime(2026, 9, 10),
    ),
    ErrandCarModel(
      id: 'CAR-005',
      plateNumber: 'ل م ن 1122',
      make: 'Kia K5',
      color: 'Navy Blue',
      status: 'maintenance',
      currentMileage: 52300,
      lastServiceDate: DateTime(2026, 6, 5),
    ),
  ];

  static final List<ErrandRequestModel> _initialRequests = [
    ErrandRequestModel(
      id: 'ERQ-3942',
      employeeName: 'Ahmed Hassan',
      employeeIsl: '10234',
      department: 'IT',
      pickupLocation: 'Smart Village Operations Hub',
      destination: 'Finance Hub Branch',
      purpose: 'Deliver signed audit documents to Finance Hub for quarterly review',
      requestedDate: '18 Sep 2026',
      requestedTime: '10:00 AM',
      estimatedReturnTime: '02:00 PM',
      supervisorName: 'Dr. Hany Fouad',
      status: 'approved',
      assignedCarId: 'CAR-001',
      assignedCarPlate: 'أ ب ج 4567',
      assignedCarMake: 'Mercedes-Benz E-Class',
      assignedDriverName: 'Khaled Nasser',
      submittedAt: DateTime(2026, 9, 17, 14, 30),
      approvedAt: DateTime(2026, 9, 17, 15, 45),
    ),
    ErrandRequestModel(
      id: 'ERQ-3938',
      employeeName: 'Ahmed Hassan',
      employeeIsl: '10234',
      department: 'IT',
      pickupLocation: 'AlexBank Downtown Cairo HQ',
      destination: 'Central Bank of Egypt',
      purpose: 'Submit regulatory compliance forms',
      requestedDate: '15 Sep 2026',
      requestedTime: '09:30 AM',
      estimatedReturnTime: '12:30 PM',
      supervisorName: 'Dr. Hany Fouad',
      status: 'completed',
      assignedCarId: 'CAR-003',
      assignedCarPlate: 'س ع ص 2345',
      assignedCarMake: 'Toyota Camry',
      submittedAt: DateTime(2026, 9, 14, 16, 0),
      approvedAt: DateTime(2026, 9, 14, 17, 15),
    ),
    ErrandRequestModel(
      id: 'ERQ-3935',
      employeeName: 'Ahmed Hassan',
      employeeIsl: '10234',
      department: 'IT',
      pickupLocation: 'Smart Village Operations Hub',
      destination: 'Nasr City Branch',
      purpose: 'IT equipment delivery and installation',
      requestedDate: '12 Sep 2026',
      requestedTime: '11:00 AM',
      estimatedReturnTime: '03:00 PM',
      supervisorName: 'Dr. Hany Fouad',
      status: 'rejected',
      submittedAt: DateTime(2026, 9, 11, 10, 0),
    ),
    // Requests for Errand Admin tests
    ErrandRequestModel(
      id: 'REQ-101',
      employeeName: 'Nadia Soliman',
      employeeIsl: '10488',
      department: 'Compliance',
      pickupLocation: 'AlexBank Smart Village',
      destination: 'Downtown Operations Center',
      purpose: 'Urgent compliance audit review',
      requestedDate: '18 Sep 2026',
      requestedTime: '11:30 AM',
      estimatedReturnTime: '03:30 PM',
      supervisorName: 'Dr. Hany Fouad',
      status: 'pending',
      submittedAt: DateTime(2026, 9, 18, 8, 30),
    ),
    ErrandRequestModel(
      id: 'REQ-102',
      employeeName: 'Karim Fekry',
      employeeIsl: '10742',
      department: 'Marketing',
      pickupLocation: 'AlexBank Smart Village',
      destination: 'Zamalek Event Hall',
      purpose: 'Promotional material delivery',
      requestedDate: '18 Sep 2026',
      requestedTime: '01:00 PM',
      estimatedReturnTime: '05:00 PM',
      supervisorName: 'Mona Youssef',
      status: 'pending',
      submittedAt: DateTime(2026, 9, 18, 9, 0),
    ),
  ];

  static const ErrandDispatchPassModel _initialErrandPass = ErrandDispatchPassModel(
    id: 'ABX-3942',
    requestId: 'ERQ-3942',
    missionCode: 'CPT-912',
    employeeName: 'Ahmed Hassan',
    pickupLocation: 'Smart Village Operations Hub',
    destination: 'Finance Hub Branch',
    carPlate: 'أ ب ج 4567',
    carMake: 'Mercedes-Benz E-Class',
    departureTime: '10:00 AM',
    estimatedReturn: '02:00 PM',
    status: 'active',
    startMileage: 34520,
    qrPayload: 'ALEXBANK:ERRAND:ABX-3942:CPT-912:AHMED-HASSAN:FINANCE-HUB',
  );

  // ──────────────────────────────────────────────────────────────────────────
  // ACCESS INVITE CODES
  // ──────────────────────────────────────────────────────────────────────────

  static final List<InviteCodeModel> _initialCodes = [
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
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // GARAGE SUBSCRIPTIONS & WAITLIST
  // ──────────────────────────────────────────────────────────────────────────

  static final List<GarageSubscriptionModel> _initialSubscriptions = [
    GarageSubscriptionModel(
      id: 'S001',
      name: 'Sara Hassan',
      nationalId: '29001011234567',
      isl: '10234',
      dept: 'IT',
      email: 's.hassan@alexbank.com',
      priorityTier: 'standard',
      slotLabel: 'P1-014',
      status: 'active',
      checkedIn: false,
      submittedAt: DateTime(2026, 3, 1, 9, 0),
    ),
    GarageSubscriptionModel(
      id: 'S002',
      name: 'Mohamed Ali',
      nationalId: '28808051234567',
      isl: '10512',
      dept: 'Finance',
      email: 'm.ali@alexbank.com',
      priorityTier: 'senior',
      slotLabel: 'P1-002',
      status: 'active',
      checkedIn: true,
      checkedInAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      submittedAt: DateTime(2026, 3, 2, 8, 30),
    ),
    // Waitlist and Cancellation for Admin Tests
    GarageSubscriptionModel(
      id: 'WAIT-001',
      name: 'Rami Galal',
      nationalId: '28905151234567',
      isl: '10991',
      dept: 'Legal',
      email: 'r.galal@alexbank.com',
      priorityTier: 'standard',
      slotLabel: null,
      status: 'waiting',
      waitingPosition: 1,
      submittedAt: DateTime(2026, 9, 10, 11, 0),
    ),
    GarageSubscriptionModel(
      id: 'WAIT-002',
      name: 'Heba Fawzy',
      nationalId: '29202021234567',
      isl: '10992',
      dept: 'Audit',
      email: 'h.fawzy@alexbank.com',
      priorityTier: 'standard',
      slotLabel: null,
      status: 'waiting',
      waitingPosition: 2,
      submittedAt: DateTime(2026, 9, 12, 14, 0),
    ),
    GarageSubscriptionModel(
      id: 'CAN-001',
      name: 'Yasser El-Sayed',
      nationalId: '28503031234567',
      isl: '10993',
      dept: 'Operations',
      email: 'y.sayed@alexbank.com',
      priorityTier: 'standard',
      slotLabel: 'P2-031',
      status: 'cancellation_requested',
      submittedAt: DateTime(2026, 9, 14, 9, 30),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // DRIVER ROSTER & ACTIVE TRIP
  // ──────────────────────────────────────────────────────────────────────────

  static const DriverProfileModel _initialDriverProfile = DriverProfileModel(
    id: 'DRV-882',
    name: 'Captain Tarek Mostafa',
    phone: '+20 100 123 4567',
    licenseNumber: 'EGY-COMM-99412',
    assignedBusPlate: 'س ق د 1892',
    assignedBusNumber: 'BUS-101',
    assignedRouteId: 'BUS-101',
    assignedRouteName: 'AlexBank HQ → Innovation Park',
    rating: 4.95,
    totalTripsCompleted: 342,
  );

  static const DriverTripModel _initialDriverTrip = DriverTripModel(
    tripId: 'TRIP-20260918-101',
    routeId: 'BUS-101',
    routeNumber: '101',
    routeName: 'AlexBank HQ → Innovation Park',
    busPlate: 'س ق د 1892',
    shift: 'Morning',
    currentStopIndex: 0,
    status: 'scheduled',
    stops: [
      BusStopModel(
        id: 'stop-1',
        name: 'AlexBank HQ (Main Gate)',
        nameAr: 'المقر الرئيسي لبنك الإسكندرية',
        scheduledTime: '07:30 AM',
        isCompleted: false,
        isCurrent: true,
        order: 1,
        latitude: 30.0715,
        longitude: 31.0210,
        radiusMeters: 150.0,
      ),
      BusStopModel(
        id: 'stop-2',
        name: 'City Center Hub',
        nameAr: 'محطة سيتي سنتر',
        scheduledTime: '07:50 AM',
        isCompleted: false,
        isCurrent: false,
        order: 2,
        latitude: 30.0520,
        longitude: 31.0530,
        radiusMeters: 150.0,
      ),
      BusStopModel(
        id: 'stop-3',
        name: 'Metro Station — Station 4',
        nameAr: 'محطة المترو — المحطة الرابعة',
        scheduledTime: '08:15 AM',
        isCompleted: false,
        isCurrent: false,
        order: 3,
        latitude: 30.0380,
        longitude: 31.0850,
        radiusMeters: 150.0,
      ),
      BusStopModel(
        id: 'stop-4',
        name: 'Innovation Park Campus',
        nameAr: 'مجمع واحة الابتكار',
        scheduledTime: '08:45 AM',
        isCompleted: false,
        isCurrent: false,
        order: 4,
        latitude: 30.0190,
        longitude: 31.1210,
        radiusMeters: 150.0,
      ),
    ],
    passengers: [
      TripManifestItemModel(
        id: 'MNF-001',
        passId: 'BP-101-08',
        employeeName: 'Ahmed Mansour',
        employeeIsl: '4920',
        department: 'IT Infrastructure',
        seatNumber: 8,
        pickupStop: 'City Center Hub',
        status: 'booked',
      ),
      TripManifestItemModel(
        id: 'MNF-002',
        passId: 'BP-101-12',
        employeeName: 'Sara Khalil',
        employeeIsl: '3811',
        department: 'Finance & Treasury',
        seatNumber: 12,
        pickupStop: 'AlexBank HQ (Main Gate)',
        status: 'boarded',
      ),
      TripManifestItemModel(
        id: 'MNF-003',
        passId: 'BP-101-15',
        employeeName: 'Omar Sherif',
        employeeIsl: '2901',
        department: 'Operations & Logistics',
        seatNumber: 15,
        pickupStop: 'Metro Station — Station 4',
        status: 'booked',
      ),
      TripManifestItemModel(
        id: 'MNF-004',
        passId: 'BP-101-04',
        employeeName: 'Nour El-Din',
        employeeIsl: '5542',
        department: 'Risk Management',
        seatNumber: 4,
        pickupStop: 'AlexBank HQ (Main Gate)',
        status: 'boarded',
      ),
      TripManifestItemModel(
        id: 'MNF-005',
        passId: 'BP-101-19',
        employeeName: 'Dina Adel',
        employeeIsl: '6109',
        department: 'Human Resources',
        seatNumber: 19,
        pickupStop: 'City Center Hub',
        status: 'booked',
      ),
      TripManifestItemModel(
        id: 'MNF-006',
        passId: 'BP-101-22',
        employeeName: 'Mostafa Hassan',
        employeeIsl: '4233',
        department: 'Legal Affairs',
        seatNumber: 22,
        pickupStop: 'Metro Station — Station 4',
        status: 'booked',
      ),
    ],
  );
}
