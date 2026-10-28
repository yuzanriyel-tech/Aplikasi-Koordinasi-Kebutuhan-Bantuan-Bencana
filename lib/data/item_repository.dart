import 'package:flutter/foundation.dart';

import '../models/item.dart';

class ItemRepository extends ChangeNotifier {
  ItemRepository._();
  static final ItemRepository instance = ItemRepository._();

  factory ItemRepository() => instance;

  final List<Item> _items = [
    Item(
      id: '1',
      title: 'Beras',
      quantity: 100,
      unit: 'kg',
      urgency: Urgency.tinggi,
      note: 'Untuk dapur umum posko utama.',
      createdAt: DateTime(2026, 10, 9, 8, 30),
      syncStatus: SyncStatus.sent,
    ),

    Item(
      id: '2',
      title: 'Air Mineral',
      quantity: 50,
      unit: 'dus',
      urgency: Urgency.tinggi,
      createdAt: DateTime(2026, 10, 9, 9, 10),
      syncStatus: SyncStatus.sent,
    ),
    
    Item(
      id: '3',
      title: 'Mie Instan',
      quantity: 50,
      unit: 'dus',
      urgency: Urgency.rendah,
      createdAt: DateTime(2026, 10, 9, 10, 45),
      syncStatus: SyncStatus.sent,
    ),

    Item(
      id: '4',
      title: 'Susu',
      quantity: 5,
      unit: 'dus',
      urgency: Urgency.sedang,
      note: 'Untuk bayi berusia 6 bulan.',
      createdAt: DateTime(2026, 10, 10, 15, 12),
    ),

    Item(
      id: '5',
      title: 'Selimut',
      quantity: 40,
      unit: 'lembar',
      urgency: Urgency.tinggi,
      createdAt: DateTime(2026, 10, 10, 15, 20),
    ),
  ];

  List<Item> get items => List.unmodifiable(_items);

  List<Item> get pendingItems =>
      _items.where((item) => item.isPending).toList(growable: false);

  int get pendingCount => _items.where((item) => item.isPending).length;

  int get sentCount => _items.length - pendingCount;

  Item? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  String nextId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<List<Item>> fetchItems({bool simulateError = false}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (simulateError) {
      throw Exception('Gagal memuat data. Periksa koneksi internet.');
    }
    return items;
  }

  void add(Item item) {
    _items.insert(0, item);
    notifyListeners();
  }

  void update(Item item) {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index == -1) return;
    _items[index] = item.copyWith(syncStatus: SyncStatus.pending);
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void markAllSynced() {
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].isPending) {
        _items[i] = _items[i].copyWith(syncStatus: SyncStatus.sent);
      }
    }
    notifyListeners();
  }
}
