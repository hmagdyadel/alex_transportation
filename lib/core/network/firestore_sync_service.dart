import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:alex_transportation/core/network/firebase_client.dart';

/// Resilient Firestore cloud sync service.
///
/// Attempts to read/write data to Cloud Firestore when Firebase is initialized
/// and online. Silently falls back to local-only mode when Firebase is
/// unavailable (placeholder keys, no network, etc.).
class FirestoreSyncService {
  FirestoreSyncService._();
  static final FirestoreSyncService instance = FirestoreSyncService._();

  FirebaseFirestore? _db;
  bool _available = false;

  /// Whether Firestore is actively connected.
  bool get isAvailable => _available;

  /// Initialize Firestore connection. Safe to call multiple times.
  Future<void> initialize() async {
    if (_available) return;
    if (!FirebaseClient.isInitialized) {
      debugPrint('[FirestoreSync] Firebase not initialized — running local-only.');
      return;
    }

    try {
      _db = FirebaseFirestore.instance;
      // Enable offline persistence for resilient caching
      _db!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _available = true;
      debugPrint('[FirestoreSync] ✓ Firestore connected with offline persistence.');
    } catch (e) {
      debugPrint('[FirestoreSync] ✕ Firestore init failed: $e — running local-only.');
      _available = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Generic CRUD helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Write or merge a document. Returns `true` on success.
  Future<bool> upsert(String collection, String docId, Map<String, dynamic> data) async {
    if (!_available || _db == null) return false;
    try {
      await _db!.collection(collection).doc(docId).set(
        {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[FirestoreSync] ✓ Upserted $collection/$docId');
      return true;
    } catch (e) {
      debugPrint('[FirestoreSync] ✕ Upsert $collection/$docId failed: $e');
      return false;
    }
  }

  /// Read a single document. Returns `null` on failure or when unavailable.
  Future<Map<String, dynamic>?> read(String collection, String docId) async {
    if (!_available || _db == null) return null;
    try {
      final snap = await _db!.collection(collection).doc(docId).get();
      return snap.data();
    } catch (e) {
      debugPrint('[FirestoreSync] ✕ Read $collection/$docId failed: $e');
      return null;
    }
  }

  /// Listen to a document in real-time. Returns a broadcast stream.
  Stream<Map<String, dynamic>?> listen(String collection, String docId) {
    if (!_available || _db == null) return const Stream.empty();
    return _db!
        .collection(collection)
        .doc(docId)
        .snapshots()
        .map((snap) => snap.data())
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
    if (!_available || _db == null) return [];
    try {
      Query<Map<String, dynamic>> query = _db!.collection(collection);
      if (whereField != null && isEqualTo != null) {
        query = query.where(whereField, isEqualTo: isEqualTo);
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      final snap = await query.get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('[FirestoreSync] ✕ List $collection failed: $e');
      return [];
    }
  }

  /// Delete a document.
  Future<bool> delete(String collection, String docId) async {
    if (!_available || _db == null) return false;
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
  // Domain-specific sync helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Sync a user account to Firestore `users` collection.
  Future<bool> syncUserAccount({
    required String isl,
    required String name,
    required String department,
    required String role,
  }) {
    return upsert('users', isl, {
      'name': name,
      'department': department,
      'role': role,
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  /// Sync a garage subscription event.
  Future<bool> syncGarageEvent({
    required String isl,
    required String eventType,
    String? slotLabel,
  }) {
    return upsert('garage_events', '${isl}_${DateTime.now().millisecondsSinceEpoch}', {
      'isl': isl,
      'eventType': eventType, // 'subscribe', 'check_in', 'check_out', 'cancel'
      'slotLabel': slotLabel,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Sync a bus seat booking.
  Future<bool> syncBusBooking({
    required String passId,
    required String routeId,
    required String employeeName,
    required String stopName,
    required int seatNumber,
    required String status,
  }) {
    return upsert('bus_bookings', passId, {
      'routeId': routeId,
      'employeeName': employeeName,
      'stopName': stopName,
      'seatNumber': seatNumber,
      'status': status,
    });
  }

  /// Sync an errand car request.
  Future<bool> syncErrandRequest({
    required String requestId,
    required String employeeName,
    required String pickupLocation,
    required String destination,
    required String purpose,
    required String status,
  }) {
    return upsert('errand_requests', requestId, {
      'employeeName': employeeName,
      'pickupLocation': pickupLocation,
      'destination': destination,
      'purpose': purpose,
      'status': status,
    });
  }

  /// Sync system configuration (admin-controlled settings).
  Future<bool> syncSystemConfig(Map<String, dynamic> config) {
    return upsert('system', 'config', config);
  }

  /// Listen to system configuration changes in real-time.
  Stream<Map<String, dynamic>?> listenSystemConfig() {
    return listen('system', 'config');
  }
}
