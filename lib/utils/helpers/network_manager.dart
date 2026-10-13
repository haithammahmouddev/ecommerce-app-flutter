import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import '../popups/loaders.dart';

class NetworkManager {
  NetworkManager._internal() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  static final NetworkManager _instance = NetworkManager._internal();

  factory NetworkManager() => _instance;

  static NetworkManager get instance => _instance;

  final Connectivity _connectivity = Connectivity();

  late final StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;

  List<ConnectivityResult> _connectionStatus = [];

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _connectionStatus = result;

    if (result.contains(ConnectivityResult.none)) {

    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } on PlatformException {
      return false;
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
