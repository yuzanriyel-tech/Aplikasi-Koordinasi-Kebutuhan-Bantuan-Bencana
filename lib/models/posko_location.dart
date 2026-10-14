/// Titik lokasi posko (hasil GPS atau hasil geser manual di peta).
class PoskoLocation {
  final double latitude;
  final double longitude;

  const PoskoLocation(this.latitude, this.longitude);

  /// Titik awal sementara sampai deteksi GPS sungguhan dipasang (Modul Dasar, FR-04).
  static const PoskoLocation fallback = PoskoLocation(-6.9715, 107.6191);

  String get label =>
      'GPS ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}
