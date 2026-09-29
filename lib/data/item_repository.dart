import '../models/item.dart';

/// Sumber data sementara (dummy). Nanti bisa diganti dengan API/database.
class ItemRepository {
  static const List<Item> _items = [
    Item(
      id: '1',
      title: 'Air mineral',
      subtitle: 'Posko A - 100 dus',
      description: 'Kebutuhan air minum untuk pengungsi.',
      urgency: 'Tinggi',
    ),
    Item(
      id: '2',
      title: 'Obat-obatan',
      subtitle: 'Posko A - 20 paket',
      description: 'Obat dasar dan perlengkapan P3K.',
      urgency: 'Tinggi',
    ),
    Item(
      id: '3',
      title: 'Selimut',
      subtitle: 'Posko B - 50 buah',
      description: 'Selimut untuk pengungsi di tenda.',
      urgency: 'Sedang',
    ),
    Item(
      id: '4',
      title: 'Pakaian layak pakai',
      subtitle: 'Posko C - 80 potong',
      description: 'Pakaian dewasa dan anak-anak.',
      urgency: 'Rendah',
    ),
  ];

  /// simulateError: true -> sengaja dibuat gagal untuk menguji error state.
  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi waktu tunggu server
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return _items;
  }
}