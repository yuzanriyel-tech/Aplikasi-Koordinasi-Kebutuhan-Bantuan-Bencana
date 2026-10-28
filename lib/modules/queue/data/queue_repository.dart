import '../models/queue_item.dart';
import 'queue_database.dart';

/// Satu-satunya pintu akses data antrean.
/// Modul A memanggil [enqueue]; Modul C memanggil [getPending] dan [markSent].
class QueueRepository {
  QueueRepository._();
  static final QueueRepository instance = QueueRepository._();

  static const _table = 'queue_items';

  /// FR-11: masukkan data baru ke antrean lokal (status pending).
  Future<int> enqueue(QueueItem item) async {
    final db = await QueueDatabase.instance.database;
    final map = item.copyWith(status: QueueItem.statusPending).toMap()
      ..remove('id');
    return db.insert(_table, map);
  }

  /// FR-12: ambil semua data yang masih mengantre (terbaru di atas).
  Future<List<QueueItem>> getPending() async {
    final db = await QueueDatabase.instance.database;
    final rows = await db.query(
      _table,
      where: 'status = ?',
      whereArgs: [QueueItem.statusPending],
      orderBy: 'created_at DESC',
    );
    return rows.map(QueueItem.fromMap).toList();
  }

  /// FR-13: edit data yang masih mengantre. Data 'sent' tidak bisa diubah.
  Future<bool> update(QueueItem item) async {
    if (item.id == null) return false;
    final db = await QueueDatabase.instance.database;
    final count = await db.update(
      _table,
      item.copyWith(updatedAt: DateTime.now()).toMap()..remove('id'),
      where: 'id = ? AND status = ?',
      whereArgs: [item.id, QueueItem.statusPending],
    );
    return count > 0;
  }

  /// FR-13: hapus data yang masih mengantre.
  Future<bool> delete(int id) async {
    final db = await QueueDatabase.instance.database;
    final count = await db.delete(
      _table,
      where: 'id = ? AND status = ?',
      whereArgs: [id, QueueItem.statusPending],
    );
    return count > 0;
  }

  /// Disiapkan untuk Modul C (FR-18): tandai data sudah terkirim.
  Future<void> markSent(int id) async {
    final db = await QueueDatabase.instance.database;
    await db.update(
      _table,
      {
        'status': QueueItem.statusSent,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}