class Penyaluran {
  final String namaPenerima;
  final String jenisBarang;
  final int jumlah;
  final String satuan;
  final DateTime tanggal;
  final bool adaFoto;

  const Penyaluran({
    required this.namaPenerima,
    required this.jenisBarang,
    required this.jumlah,
    required this.satuan,
    required this.tanggal,
    required this.adaFoto,
  });
}