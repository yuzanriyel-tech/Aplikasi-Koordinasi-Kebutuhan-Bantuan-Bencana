/// Model data utama: satu data kebutuhan bantuan yang diinput Posko.
class KebutuhanBantuan {
  final String id;
  final String jenis;
  final String jumlah;
  final String urgensi;
  final String status;

  const KebutuhanBantuan({
    required this.id,
    required this.jenis,
    required this.jumlah,
    required this.urgensi,
    required this.status,
  });
}