import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps [connectivity_plus] into a simple online/offline stream.
///
/// Used by SyncEngine and the SyncStatusBloc.
class ConnectivityMonitor {
  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Emits true when online, false when offline.
  Stream<bool> get stream => _connectivity.onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
