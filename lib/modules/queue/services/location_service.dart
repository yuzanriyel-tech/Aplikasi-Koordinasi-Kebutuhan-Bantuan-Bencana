import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double? latitude;
  final double? longitude;

  /// Pesan untuk pengguna bila lokasi gagal didapat (NFR-12).
  final String? message;

  const LocationResult({this.latitude, this.longitude, this.message});

  bool get hasLocation => latitude != null && longitude != null;
}

/// FR-14: mengambil koordinat GPS perangkat.
/// Tidak pernah melempar error; kegagalan dikembalikan sebagai pesan.
class LocationService {
  static Future<LocationResult> getCurrent() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return const LocationResult(
          message: 'GPS belum aktif. Aktifkan GPS untuk mencatat lokasi.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult(
          message: 'Izin lokasi ditolak. Data tetap bisa disimpan tanpa lokasi.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          message: 'Izin lokasi diblokir. Aktifkan lewat Pengaturan aplikasi.',
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationResult(latitude: pos.latitude, longitude: pos.longitude);
    } on TimeoutException {
      return const LocationResult(
        message: 'Lokasi belum terdeteksi. Coba lagi di tempat terbuka.',
      );
    } catch (_) {
      return const LocationResult(
        message: 'Gagal mengambil lokasi. Data tetap bisa disimpan.',
      );
    }
  }
}