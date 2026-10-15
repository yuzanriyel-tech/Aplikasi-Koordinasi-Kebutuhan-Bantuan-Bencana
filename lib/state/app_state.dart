import 'dart:async';
import 'dart:io' show InternetAddress, SocketException;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

import '../data/item_repository.dart';

enum ConnectionMode { online, offline, waitingSync }

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  static const _probeHost = 'google.com';
  static const _probeTimeout = Duration(seconds: 3);
  static const _retryEvery = Duration(seconds: 10);

  bool _online = false;
  bool _syncing = false;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _retryTimer;
  int _checkId = 0; 

  bool get isOnline => _online;

  ConnectionMode get mode {
    if (!_online) return ConnectionMode.offline;
    if (_syncing) return ConnectionMode.waitingSync;
    return ConnectionMode.online;
  }

  int get pendingCount => ItemRepository.instance.pendingCount;

  Future<void> startMonitoring() async {
    if (_subscription != null) return;
    final connectivity = Connectivity();
    _subscription = connectivity.onConnectivityChanged.listen(_onChanged);
    _onChanged(await connectivity.checkConnectivity());
  }

  Future<void> stopMonitoring() async {
    await _subscription?.cancel();
    _subscription = null;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  Future<void> _onChanged(List<ConnectivityResult> results) async {
    _retryTimer?.cancel();
    final id = ++_checkId;

    final hasLink = results.any((r) => r != ConnectivityResult.none);
    if (!hasLink) {
      setOnline(false);
      return;
    }

    final reachable = await _canReachInternet();
    if (id != _checkId) return; 
    setOnline(reachable);

    
    if (!reachable) {
      _retryTimer = Timer(_retryEvery, () => _onChanged(results));
    }
  }

  Future<bool> _canReachInternet() async {
    if (kIsWeb) return true;
    try {
      final found =
          await InternetAddress.lookup(_probeHost).timeout(_probeTimeout);
      return found.isNotEmpty && found.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  void toggleOnline() => setOnline(!_online);

  void setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    notifyListeners();
    if (value) syncNow();
  }

  Future<void> syncNow() async {
    if (!_online || _syncing || pendingCount == 0) return;
    _syncing = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    final success = _online;
    if (success) ItemRepository.instance.markAllSynced();

    _syncing = false;
    notifyListeners();

    if (success) await _vibrateOnSyncSuccess();
  }

  Future<void> _vibrateOnSyncSuccess() async {
    try {
      if (await Vibration.hasVibrator() == true) {
        await Vibration.vibrate(duration: 500);
      }
    } catch (_) {
    }
  }
}
