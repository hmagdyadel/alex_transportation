import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Real-time network connectivity monitor service.
/// Uses connectivity_plus to observe hardware interfaces and
/// internet_connection_checker to verify active socket internet access.
class NetworkConnectivityService {
  static final NetworkConnectivityService _instance =
      NetworkConnectivityService._internal();

  factory NetworkConnectivityService() => _instance;

  NetworkConnectivityService._internal();

  static NetworkConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker();

  StreamController<bool>? _connectionStreamController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = true;
  bool _isInitialized = false;

  /// Whether the device currently has verified internet access
  bool get isConnected => _isConnected;

  /// Broadcast stream of internet connection status changes (true = online, false = offline)
  Stream<bool> get connectionStream =>
      _connectionStreamController?.stream ?? const Stream.empty();

  /// Initialize connectivity listeners
  Future<void> initialize() async {
    if (_isInitialized) return;

    _connectionStreamController = StreamController<bool>.broadcast();

    // Check initial connection
    try {
      final initialInterface = await _connectivity.checkConnectivity();
      if (initialInterface.contains(ConnectivityResult.none)) {
        _isConnected = false;
      } else {
        _isConnected = await _connectionChecker.hasConnection;
      }
    } catch (e) {
      debugPrint(
        '[NetworkService] Native connectivity plugin unavailable (full restart needed): $e',
      );
      try {
        _isConnected = await _connectionChecker.hasConnection;
      } catch (_) {
        _isConnected = true; // Fallback to avoid false offline on boot
      }
    }

    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          debugPrint(
            '[NetworkService] Connectivity stream error (full app restart required): $error',
          );
        },
      );
    } catch (e) {
      debugPrint('[NetworkService] Could not attach connectivity stream: $e');
    }

    _isInitialized = true;
    debugPrint(
      '[NetworkService] Initialized. Current isConnected: $_isConnected',
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    try {
      if (results.contains(ConnectivityResult.none)) {
        _updateStatus(false);
      } else {
        final hasInternet = await _connectionChecker.hasConnection;
        _updateStatus(hasInternet);
      }
    } catch (e) {
      debugPrint('[NetworkService] Connectivity change error: $e');
      _updateStatus(false);
    }
  }

  void _updateStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      debugPrint(
        '[NetworkService] Status updated -> isConnected: $_isConnected',
      );
      _connectionStreamController?.add(_isConnected);
    }
  }

  /// Manually ping for connection verification (e.g. on "Try Again" button tap)
  Future<bool> checkConnection() async {
    try {
      final hasInternet = await _connectionChecker.hasConnection;
      _updateStatus(hasInternet);
      return hasInternet;
    } catch (e) {
      debugPrint('[NetworkService] Manual checkConnection error: $e');
      _updateStatus(false);
      return false;
    }
  }

  /// Dispose service resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _connectionStreamController?.close();
    _connectionStreamController = null;
    _isInitialized = false;
  }
}
