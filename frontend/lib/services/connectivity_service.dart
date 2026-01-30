import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    debugPrint('📡 [Connectivity] Initialized: $_isConnected');
  }

  // Stream to listen for connectivity changes
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      final connected = result != ConnectivityResult.none;
      _isConnected = connected;
      debugPrint('📡 [Connectivity] Changed: $connected');
      return connected;
    });
  }

  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    return _isConnected;
  }
}
