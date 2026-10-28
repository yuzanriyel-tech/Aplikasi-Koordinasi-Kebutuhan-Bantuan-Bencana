class Penyaluran {
  final String namaPenerima;
  final String jenisBarang;
  final int jumlah;
  final String satuan;
  final DateTime tanggal;

  // Path file foto serah terima (null = tidak ada foto)
  final String? fotoPath;

  const Penyaluran({
    required this.namaPenerima,
    required this.jenisBarang,
    required this.jumlah,
    required this.satuan,
    required this.tanggal,
    this.fotoPath,
  });

  bool get adaFoto => fotoPath != null;
}
