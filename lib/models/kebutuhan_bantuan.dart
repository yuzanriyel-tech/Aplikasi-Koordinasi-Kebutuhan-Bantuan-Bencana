class KebutuhanBantuan {
  final String id;
  final String jenisKebutuhan;
  final int jumlah;
  final String urgensi;
  final String? foto;

  const KebutuhanBantuan({
    required this.id,
    required this.jenisKebutuhan,
    required this.jumlah,
    required this.urgensi,
    this.foto,
  });
}