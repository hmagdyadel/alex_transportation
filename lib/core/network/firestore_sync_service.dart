import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:alex_transportation/core/network/firebase_client.dart';
import 'package:alex_transportation/features/admin/data/models/invite_code_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_boarding_pass_model.dart';
import 'package:alex_transportation/features/buses/data/models/bus_route_model.dart';
import 'package:alex_transportation/features/driver/data/models/driver_trip_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_car_model.dart';
import 'package:alex_transportation/features/errand_cars/data/models/errand_request_model.dart';
import 'package:alex_transportation/features/garage/data/models/garage_subscription_model.dart';

import 'package:alex_transportation/core/network/firestore_data_seeder.dart';

/// Resilient Firestore cloud sync service and domain repository.
///
/// Communicates directly with Cloud Firestore when connected, and maintains
/// a responsive local fallback cache for offline resiliency and testing.
class FirestoreSyncService {
  FirestoreSyncService._() {
    _initCacheWithMasterData();
  }
  static final FirestoreSyncService instance = FirestoreSyncService._();

  FirebaseFirestore? _db;
  bool _available = false;

  // Local memory cache for fast offline access and isolated test runners
  final Map<String, Map<String, Map<String, dynamic>>> _cache = {};
  final Map<String, StreamController<List<Map<String, dynamic>>>>
  _streamControllers = {};

  void _initCacheWithMasterData() {
    for (final r in FirestoreDataSeeder.initialRoutes) {
      _cache.putIfAbsent('bus_routes', () => {})[r.id] = r.toJson();
    }
    for (final b in FirestoreDataSeeder.initialBusBookings) {
      _cache.putIfAbsent('bus_bookings', () => {})[b.id] = b.toJson();
    }
    for (final c in FirestoreDataSeeder.initialFleet) {
      _cache.putIfAbsent('errand_fleet', () => {})[c.id] = c.toJson();
    }
    for (final req in FirestoreDataSeeder.initialRequests) {
      _cache.putIfAbsent('errand_requests', () => {})[req.id] = req.toJson();
    }
    for (final code in FirestoreDataSeeder.initialCodes) {
      _cache.putIfAbsent('invite_codes', () => {})[code.id] = code.toJson();
    }
    for (final sub in FirestoreDataSeeder.initialSubscriptions) {
      _cache.putIfAbsent('garage_subscriptions', () => {})[sub.id] = sub
          .toJson();
    }
    _cache.putIfAbsent(
      'driver_trips',
      () => {},
    )[FirestoreDataSeeder.initialDriverTrip.tripId] = FirestoreDataSeeder
        .initialDriverTrip
        .toJson();
  }

  /// Whether Firestore is actively connected.
  bool get isAvailable => _available;

  /// Whether Firestore is connected AND an authenticated session exists.
  /// Prevents unauthenticated queries on app boot that would violate security rules.
  bool get _canAccessCloud {
    if (!_available || _db == null) return false;
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Initialize Firestore connection. Safe to call multiple times.
  Future<void> initialize() async {
    if (_available) return;
    if (!FirebaseClient.isInitialized) {
      debugPrint(
        '[FirestoreSync] Firebase not initialized — running with local persistence cache.',
      );
      return;
    }

    try {
      _db = FirebaseFirestore.instance;
      _db!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _available = true;
      debugPrint(
        '[FirestoreSync] ✓ Firestore connected with offline persistence.',
      );
    } catch (e) {
      debugPrint(
        '[FirestoreSync] ✕ Firestore init failed: $e — running with local cache.',
      );
      _available = false;
    }
  }

  StreamController<List<Map<String, dynamic>>> _getStreamController(
    String collection,
  ) {
    return _streamControllers.putIfAbsent(
      collection,
      () => StreamController<List<Map<String, dynamic>>>.broadcast(),
    );
  }

  void _notifyCacheUpdate(String collection) {
    if (_streamControllers.containsKey(collection)) {
      final list = _cache[collection]?.values.toList() ?? [];
      _streamControllers[collection]!.add(list);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Generic CRUD helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Write or merge a document. Returns `true` on success.
  Future<bool> upsert(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    // 1. Update local cache
    _cache.putIfAbsent(collection, () => {})[docId] = {'id': docId, ...data};
    _notifyCacheUpdate(collection);

    // 2. Write to Cloud Firestore if connected and authenticated
    if (!_canAccessCloud) return true;

    try {
      await _db!.collection(collection).doc(docId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[FirestoreSync] ✓ Upserted $collection/$docId to Firestore');
      return true;
    } catch (e) {
      debugPrint('[FirestoreSync] ✕ Upsert $collection/$docId failed: $e');
      return false;
    }
  }

  /// Read a single document. Returns `null` on failure or when unavailable.
  Future<Map<String, dynamic>?> read(String collection, String docId) async {
    if (_canAccessCloud) {
      try {
        final snap = await _db!.collection(collection).doc(docId).get();
        if (snap.exists && snap.data() != null) {
          final data = {'id': snap.id, ...snap.data()!};
          _cache.putIfAbsent(collection, () => {})[docId] = data;
          return data;
        }
      } catch (e) {
        debugPrint('[FirestoreSync] ✕ Read $collection/$docId failed: $e');
      }
    }
    return _cache[collection]?[docId];
  }

  /// Listen to a document in real-time. Returns a broadcast stream.
  Stream<Map<String, dynamic>?> listen(String collection, String docId) {
    if (!_canAccessCloud) {
      return Stream.value(_cache[collection]?[docId]);
    }
    return _db!
        .collection(collection)
        .doc(docId)
        .snapshots()
        .map(
          (snap) =>
              snap.data() != null ? {'id': snap.id, ...snap.data()!} : null,
        )
        .handleError((e) {
          debugPrint('[FirestoreSync] ✕ Listener $collection/$docId error: $e');
        });
  }

  /// List all documents in a collection with optional query filters.
  Future<List<Map<String, dynamic>>> list(
    String collection, {
    String? whereField,
    dynamic isEqualTo,
    int? limit,
  }) async {
    if (_canAccessCloud) {
      try {
        Query<Map<String, dynamic>> query = _db!.collection(collection);
        if (whereField != null && isEqualTo != null) {
          query = query.where(whereField, isEqualTo: isEqualTo);
        }
        if (limit != null) {
          query = query.limit(limit);
        }
        final snap = await query.get();
        final docs = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        if (docs.isNotEmpty) {
          for (final d in docs) {
            _cache.putIfAbsent(collection, () => {})[d['id'] as String] = d;
          }
          return docs;
        }
      } catch (e) {
        debugPrint('[FirestoreSync] ✕ List $collection failed: $e');
      }
    }

    // Fallback to cache
    var items = _cache[collection]?.values.toList() ?? [];
    if (whereField != null && isEqualTo != null) {
      items = items.where((item) => item[whereField] == isEqualTo).toList();
    }
    if (limit != null && items.length > limit) {
      items = items.sublist(0, limit);
    }
    return items;
  }

  /// Stream an entire collection in real-time.
  Stream<List<Map<String, dynamic>>> listenCollection(
    String collection, {
    String? whereField,
    dynamic isEqualTo,
  }) {
    if (!_canAccessCloud) {
      return _getStreamController(collection).stream.map((list) {
        if (whereField != null && isEqualTo != null) {
          return list.where((item) => item[whereField] == isEqualTo).toList();
        }
        return list;
      });
    }

    Query<Map<String, dynamic>> query = _db!.collection(collection);
    if (whereField != null && isEqualTo != null) {
      query = query.where(whereField, isEqualTo: isEqualTo);
    }

    return query
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
          for (final item in list) {
            _cache.putIfAbsent(collection, () => {})[item['id'] as String] =
                item;
          }
          return list;
        })
        .handleError((e) {
          debugPrint(
            '[FirestoreSync] ✕ Collection listener $collection error: $e',
          );
        });
  }

  /// Delete a document.
  Future<bool> delete(String collection, String docId) async {
    _cache[collection]?.remove(docId);
    _notifyCacheUpdate(collection);

    if (!_canAccessCloud) return true;

    try {
      await _db!.collection(collection).doc(docId).delete();
      debugPrint('[FirestoreSync] ✓ Deleted $collection/$docId');
      return true;
    } catch (e) {
      debugPrint('[FirestoreSync] ✕ Delete $collection/$docId failed: $e');
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Domain Repositories: Bus Transit
  // ──────────────────────────────────────────────────────────────────────────

  List<BusRouteModel> getCachedBusRoutes() {
    final docs = _cache['bus_routes']?.values.toList() ?? [];
    if (docs.isEmpty) return FirestoreDataSeeder.initialRoutes;
    return docs.map(BusRouteModel.fromJson).toList();
  }

  List<BusBoardingPassModel> getCachedBusBookings() {
    final docs = _cache['bus_bookings']?.values.toList() ?? [];
    if (docs.isEmpty) return FirestoreDataSeeder.initialBusBookings;
    return docs.map(BusBoardingPassModel.fromJson).toList();
  }

  Future<List<BusRouteModel>> getBusRoutes() async {
    final docs = await list('bus_routes');
    if (docs.isEmpty) return getCachedBusRoutes();
    return docs.map(BusRouteModel.fromJson).toList();
  }

  Stream<List<BusRouteModel>> streamBusRoutes() {
    return listenCollection('bus_routes')
        .map((list) => list.map(BusRouteModel.fromJson).toList());
  }

  Future<bool> saveBusRoute(BusRouteModel route) {
    return upsert('bus_routes', route.id, route.toJson());
  }

  Future<List<BusBoardingPassModel>> getBusBookings({
    String? routeId,
    String? employeeName,
  }) async {
    final docs = await list(
      'bus_bookings',
      whereField: routeId != null ? 'routeId' : null,
      isEqualTo: routeId,
    );
    final bookings = docs.isNotEmpty
        ? docs.map(BusBoardingPassModel.fromJson).toList()
        : getCachedBusBookings();
    if (employeeName != null) {
      return bookings
          .where((b) => b.employeeName.trim() == employeeName.trim())
          .toList();
    }
    return bookings;
  }

  Stream<List<BusBoardingPassModel>> streamBusBookings({String? routeId}) {
    return listenCollection(
      'bus_bookings',
      whereField: routeId != null ? 'routeId' : null,
      isEqualTo: routeId,
    ).map((list) => list.map(BusBoardingPassModel.fromJson).toList());
  }

  Future<bool> saveBusBooking(BusBoardingPassModel pass) {
    return upsert('bus_bookings', pass.id, pass.toJson());
  }

  Future<bool> cancelBusBooking(String passId) {
    return delete('bus_bookings', passId);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Domain Repositories: Garage Parking
  // ──────────────────────────────────────────────────────────────────────────

  List<GarageSubscriptionModel> getCachedGarageSubscriptions() {
    final docs = _cache['garage_subscriptions']?.values.toList() ?? [];
    if (docs.isEmpty) return FirestoreDataSeeder.initialSubscriptions;
    return docs.map(GarageSubscriptionModel.fromJson).toList();
  }

  Future<List<GarageSubscriptionModel>> getGarageSubscriptions() async {
    final docs = await list('garage_subscriptions');
    if (docs.isEmpty) return getCachedGarageSubscriptions();
    return docs.map(GarageSubscriptionModel.fromJson).toList();
  }

  Stream<List<GarageSubscriptionModel>> streamGarageSubscriptions() {
    return listenCollection('garage_subscriptions')
        .map((list) => list.map(GarageSubscriptionModel.fromJson).toList());
  }

  Future<bool> saveGarageSubscription(GarageSubscriptionModel sub) {
    return upsert('garage_subscriptions', sub.id, sub.toJson());
  }

  Future<bool> deleteGarageSubscription(String subId) {
    return delete('garage_subscriptions', subId);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Domain Repositories: Errand Fleet & Requests
  // ──────────────────────────────────────────────────────────────────────────

  List<ErrandCarModel> getCachedErrandFleet() {
    final docs = _cache['errand_fleet']?.values.toList() ?? [];
    if (docs.isEmpty) return FirestoreDataSeeder.initialFleet;
    return docs.map(ErrandCarModel.fromJson).toList();
  }

  List<ErrandRequestModel> getCachedErrandRequests() {
    final docs = _cache['errand_requests']?.values.toList() ?? [];
    if (docs.isEmpty) return FirestoreDataSeeder.initialRequests;
    return docs.map(ErrandRequestModel.fromJson).toList();
  }

  Future<List<ErrandCarModel>> getErrandFleet() async {
    final docs = await list('errand_fleet');
    if (docs.isEmpty) return getCachedErrandFleet();
    return docs.map(ErrandCarModel.fromJson).toList();
  }

  Stream<List<ErrandCarModel>> streamErrandFleet() {
    return listenCollection('errand_fleet')
        .map((list) => list.map(ErrandCarModel.fromJson).toList());
  }

  Future<bool> saveErrandCar(ErrandCarModel car) {
    return upsert('errand_fleet', car.id, car.toJson());
  }

  Future<List<ErrandRequestModel>> getErrandRequests({
    String? employeeIsl,
  }) async {
    final docs = await list('errand_requests');
    final reqs = docs.isNotEmpty
        ? docs.map(ErrandRequestModel.fromJson).toList()
        : getCachedErrandRequests();
    if (employeeIsl != null) {
      return reqs.where((r) => r.employeeIsl == employeeIsl).toList();
    }
    return reqs;
  }

  Stream<List<ErrandRequestModel>> streamErrandRequests() {
    return listenCollection('errand_requests')
        .map((list) => list.map(ErrandRequestModel.fromJson).toList());
  }

  Future<bool> saveErrandRequest(ErrandRequestModel req) {
    return upsert('errand_requests', req.id, req.toJson());
  }

  Future<bool> deleteErrandRequest(String reqId) {
    return delete('errand_requests', reqId);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Domain Repositories: Access Invite Codes
  // ──────────────────────────────────────────────────────────────────────────

  List<InviteCodeModel> getCachedInviteCodes() {
    final docs = _cache['invite_codes']?.values.toList() ?? [];
    if (docs.isEmpty) return FirestoreDataSeeder.initialCodes;
    return docs.map(InviteCodeModel.fromJson).toList();
  }

  Future<List<InviteCodeModel>> getInviteCodes() async {
    final docs = await list('invite_codes');
    if (docs.isEmpty) return getCachedInviteCodes();
    return docs.map(InviteCodeModel.fromJson).toList();
  }

  Stream<List<InviteCodeModel>> streamInviteCodes() {
    return listenCollection('invite_codes')
        .map((list) => list.map(InviteCodeModel.fromJson).toList());
  }

  Future<bool> saveInviteCode(InviteCodeModel code) {
    return upsert('invite_codes', code.id, code.toJson());
  }

  Future<bool> deleteInviteCode(String codeId) {
    return delete('invite_codes', codeId);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Domain Repositories: Driver Trips
  // ──────────────────────────────────────────────────────────────────────────

  DriverTripModel? getCachedDriverTrip([String tripId = 'TRIP-20260918-101']) {
    final data = _cache['driver_trips']?[tripId];
    if (data == null) return FirestoreDataSeeder.initialDriverTrip;
    return DriverTripModel.fromJson(data);
  }

  Future<DriverTripModel?> getDriverTrip(String tripId) async {
    final data = await read('driver_trips', tripId);
    if (data == null) return null;
    return DriverTripModel.fromJson(data);
  }

  Stream<DriverTripModel?> streamDriverTrip(String tripId) {
    return listen(
      'driver_trips',
      tripId,
    ).map((data) => data != null ? DriverTripModel.fromJson(data) : null);
  }

  Future<bool> saveDriverTrip(DriverTripModel trip) {
    return upsert('driver_trips', trip.tripId, trip.toJson());
  }

  /// Syncs authenticated user profile to Firestore `users/{uid}`.
  /// Strictly complies with firestore.rules:
  /// - Document creation: NO 'role' key permitted (role is assigned server-side only)
  /// - Document update: 'role' cannot be modified by client
  Future<bool> syncUserAccount({
    required String uid,
    required String isl,
    required String name,
    required String department,
  }) async {
    if (!_canAccessCloud) return false;
    try {
      final docRef = _db!.collection('users').doc(uid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) {
        await docRef.set({
          'uid': uid,
          'isl': isl,
          'name': name,
          'department': department,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.update({
          'isl': isl,
          'name': name,
          'department': department,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('[FirestoreSyncService] syncUserAccount failed: $e');
      return false;
    }
  }

  Future<bool> syncGarageEvent({
    required String isl,
    required String eventType,
    String? slotLabel,
  }) {
    return upsert(
      'garage_events',
      '${isl}_${DateTime.now().millisecondsSinceEpoch}',
      {
        'isl': isl,
        'eventType': eventType,
        'slotLabel': slotLabel,
        'timestamp': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<bool> syncDriverTripStatus(DriverTripModel trip) {
    return saveDriverTrip(trip);
  }

  Future<bool> syncSystemConfig(Map<String, dynamic> config) {
    return upsert('system', 'config', config);
  }

  Stream<Map<String, dynamic>?> listenSystemConfig() {
    return listen('system', 'config');
  }
}
