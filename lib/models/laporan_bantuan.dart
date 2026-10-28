class LaporanBantuan {
  final String id;
  final String namaKebutuhan;
  final String jumlah;
  final String prioritas;
  final String keterangan;
  final double? latitude;
  final double? longitude;
  final DateTime tanggalDibuat;
  final DateTime terakhirDiperbarui;
  final String dibuatOleh;

  const LaporanBantuan({
    required this.id,
    required this.namaKebutuhan,
    required this.jumlah,
    required this.prioritas,
    required this.keterangan,
    required this.latitude,
    required this.longitude,
    required this.tanggalDibuat,
    required this.terakhirDiperbarui,
    required this.dibuatOleh,
  });

  LaporanBantuan copyWith({
    String? keterangan,
    double? latitude,
    double? longitude,
    DateTime? terakhirDiperbarui,
  }) {
    return LaporanBantuan(
      id: id,
      namaKebutuhan: namaKebutuhan,
      jumlah: jumlah,
      prioritas: prioritas,
      keterangan: keterangan ?? this.keterangan,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tanggalDibuat: tanggalDibuat,
      terakhirDiperbarui: terakhirDiperbarui ?? this.terakhirDiperbarui,
      dibuatOleh: dibuatOleh,
    );
  }
}
