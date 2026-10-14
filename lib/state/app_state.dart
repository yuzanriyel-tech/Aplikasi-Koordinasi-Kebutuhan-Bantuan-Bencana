import 'dart:async';
import 'dart:io' show InternetAddress, SocketException;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../data/item_repository.dart';

/// Tiga status koneksi yang wajib selalu terlihat (NFR-07).
enum ConnectionMode { online, offline, waitingSync }

/// Status koneksi aplikasi + sinkronisasi otomatis.
///
/// Pemantauan jaringan (FR-16) memakai dua lapis:
///  1. `connectivity_plus` memberi tahu saat Wi-Fi/seluler menyala atau mati.
///  2. Pengecekan DNS memastikan internet benar-benar bisa dijangkau,
///     bukan sekadar tersambung ke Wi-Fi tanpa internet.
///
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  static const _probeHost = 'google.com';
  static const _probeTimeout = Duration(seconds: 3);
  static const _retryEvery = Duration(seconds: 10);

  // Mulai offline sampai pengecekan pertama selesai.
  bool _online = false;
  bool _syncing = false;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _retryTimer;
  int _checkId = 0; // untuk mengabaikan hasil cek yang sudah usang

  bool get isOnline => _online;

  ConnectionMode get mode {
    if (!_online) return ConnectionMode.offline;
    if (_syncing) return ConnectionMode.waitingSync;
    return ConnectionMode.online;
  }

  int get pendingCount => ItemRepository.instance.pendingCount;

  /// Mulai memantau jaringan. Dipanggil sekali dari `main()`.
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
    if (id != _checkId) return; // ada perubahan jaringan yang lebih baru
    setOnline(reachable);

    // Tersambung ke Wi-Fi/seluler tetapi tanpa internet: coba lagi berkala.
    if (!reachable) {
      _retryTimer = Timer(_retryEvery, () => _onChanged(results));
    }
  }

  Future<bool> _canReachInternet() async {
    // Di web tidak ada akses DNS; percayai status dari connectivity_plus.
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

  /// Hanya untuk uji manual: tekan lama indikator koneksi. Berlaku sampai
  /// jaringan berubah lagi.
  void toggleOnline() => setOnline(!_online);

  void setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    notifyListeners();
    if (value) syncNow();
  }

  /// Dipanggil saat koneksi kembali atau setelah ada data baru saat online.
  Future<void> syncNow() async {
    if (!_online || _syncing || pendingCount == 0) return;
    _syncing = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (_online) ItemRepository.instance.markAllSynced();
    _syncing = false;
    notifyListeners();
  }
}
