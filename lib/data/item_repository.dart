import '../models/item.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class ItemRepository {
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Beras 5 kg',
      subtitle: 'Jumlah: 100 karung • Urgensi: Tinggi',
      description: 'Stok beras di posko menipis. Dibutuhkan untuk dapur umum.',
    ),
    Item(
      id: '2',
      title: 'Selimut',
      subtitle: 'Jumlah: 50 lembar • Urgensi: Sedang',
      description: 'Dibutuhkan untuk pengungsi yang bermalam di tenda.',
    ),
    Item(
      id: '3',
      title: 'Air Mineral',
      subtitle: 'Jumlah: 200 dus • Urgensi: Tinggi',
      description: 'Air bersih terbatas di lokasi pengungsian.',
    ),
  ];

  /// Mengambil daftar item.
  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}