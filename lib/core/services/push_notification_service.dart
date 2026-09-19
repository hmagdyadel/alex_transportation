import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:alex_transportation/core/network/firebase_client.dart';

/// Notification event payload for in-app display.
class TransitNotification {
  final String title;
  final String body;
  final String? route; // Optional deep-link route path
  final DateTime timestamp;

  const TransitNotification({
    required this.title,
    required this.body,
    this.route,
    required this.timestamp,
  });
}

/// Manages FCM push notification registration, permissions, foreground handling,
/// and exposes a stream for in-app notification banners.
///
/// Falls back gracefully when Firebase is not initialized.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  FirebaseMessaging? _messaging;
  bool _initialized = false;
  String? _fcmToken;

  /// FCM device token (null if not available).
  String? get fcmToken => _fcmToken;

  /// Whether the service was successfully initialized.
  bool get isInitialized => _initialized;

  /// Broadcast stream of notifications for in-app banner display.
  final _notificationController =
      StreamController<TransitNotification>.broadcast();
  Stream<TransitNotification> get notificationStream =>
      _notificationController.stream;

  /// Initialize FCM. Safe to call multiple times; idempotent.
  Future<void> initialize() async {
    if (_initialized) return;
    if (!FirebaseClient.isInitialized) {
      debugPrint(
        '[PushNotification] Firebase not initialized — push disabled.',
      );
      return;
    }

    try {
      _messaging = FirebaseMessaging.instance;

      // Request permissions (iOS will show a prompt; Android auto-grants)
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[PushNotification] User denied notification permissions.');
        return;
      }

      // Get FCM token
      _fcmToken = await _messaging!.getToken();
      debugPrint(
        '[PushNotification] ✓ FCM Token: ${_fcmToken?.substring(0, 20)}...',
      );

      // Listen for token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('[PushNotification] Token refreshed.');
      });

      // Foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was launched from a notification
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _initialized = true;
      debugPrint('[PushNotification] ✓ Push notification service initialized.');
    } catch (e) {
      debugPrint('[PushNotification] ✕ Init failed: $e — push disabled.');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _notificationController.add(
        TransitNotification(
          title: notification.title ?? 'AlexBank Transit',
          body: notification.body ?? '',
          route: message.data['route'] as String?,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[PushNotification] Notification tapped: ${message.data}');
    // Deep-link routing can be handled here
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Demo / Simulated Notifications (for development and testing)
  // ──────────────────────────────────────────────────────────────────────────

  /// Simulate a bus arrival push notification.
  void demoBusArrival() {
    _notificationController.add(
      TransitNotification(
        title: '🚌 Bus Approaching',
        body: 'Route 101 (Maadi → Smart Village) is 5 minutes away from your pickup stop.',
        route: '/home',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Simulate an errand request approval.
  void demoErrandApproval() {
    _notificationController.add(
      TransitNotification(
        title: '🚗 Errand Approved',
        body: 'Your vehicle request has been approved. BMW 520i (D-H-W 8901) assigned for your mission.',
        route: '/home',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Simulate a garage subscription confirmation.
  void demoGarageConfirmed() {
    _notificationController.add(
      TransitNotification(
        title: '🅿️ Parking Pass Confirmed',
        body: 'Your monthly parking subscription is active. Assigned bay: P1-018. Monthly deduction: 1,200 EGP.',
        route: '/home',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Simulate a driver shift reminder.
  void demoDriverShiftReminder() {
    _notificationController.add(
      TransitNotification(
        title: '🔔 Shift Reminder',
        body: 'Your morning shift starts in 30 minutes. Route 101 (Maadi → Smart Village). Please start your pre-trip inspection.',
        route: '/driver',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Dispose the notification stream.
  void dispose() {
    _notificationController.close();
  }
}
