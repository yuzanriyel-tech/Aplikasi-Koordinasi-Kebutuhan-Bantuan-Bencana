import '../models/kebutuhan_bantuan.dart';

class KebutuhanRepository {
  static const List<KebutuhanBantuan> _dataKebutuhan = [
    KebutuhanBantuan(
      id: '1',
      jenis: 'Beras & Makanan Instan',
      jumlah: '50 Dus',
      urgensi: 'Tinggi',
      status: 'Masih Dibutuhkan',
    ),
    KebutuhanBantuan(
      id: '2',
      jenis: 'Air Mineral',
      jumlah: '100 Galon',
      urgensi: 'Tinggi',
      status: 'Masih Dibutuhkan',
    ),
  ];

  Future<List<KebutuhanBantuan>> fetchKebutuhan({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _dataKebutuhan;
  }
}
