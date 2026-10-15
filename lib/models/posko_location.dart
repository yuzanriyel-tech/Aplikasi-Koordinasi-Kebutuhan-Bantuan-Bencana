/// Titik lokasi posko 
class PoskoLocation {
  final double latitude;
  final double longitude;

  const PoskoLocation(this.latitude, this.longitude);

  static const PoskoLocation fallback = PoskoLocation(-6.9715, 107.6191);

  String get label =>
      'GPS ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
}
