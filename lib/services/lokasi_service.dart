import 'package:geolocator/geolocator.dart';

class LokasiService {
  Future<Position> ambilLokasiTerbaru() async {
    final serviceAktif = await Geolocator.isLocationServiceEnabled();
    if (!serviceAktif) {
      throw Exception('GPS/lokasi perangkat belum aktif. Aktifkan lokasi lalu coba lagi.');
    }

    LocationPermission izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
    }
    if (izin == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak. Izin lokasi diperlukan untuk memperbarui keterangan.');
    }
    if (izin == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Aktifkan izin lokasi melalui pengaturan aplikasi.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }
}
