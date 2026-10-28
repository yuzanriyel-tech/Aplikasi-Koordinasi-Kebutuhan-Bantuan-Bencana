import 'package:connectivity_plus/connectivity_plus.dart';

/// Status jaringan perangkat. Dipakai banner Daftar Antrean,
/// dan bisa dipakai ulang oleh Modul C (FR-16).
/// Catatan: ini mendeteksi ada/tidaknya jaringan, bukan jaminan internet aktif.
class ConnectivityService {
  static bool _fromResults(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  static Future<bool> isOnline() async =>
      _fromResults(await Connectivity().checkConnectivity());

  static Stream<bool> get onChanged =>
      Connectivity().onConnectivityChanged.map(_fromResults);
}