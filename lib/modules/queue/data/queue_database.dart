import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWebNoWebWorker;

/// Database SQLite lokal khusus Modul B.
/// Android/iOS memakai sqflite; Chrome (web) memakai sqflite_common_ffi_web.
/// Memakai file terpisah agar tidak bentrok dengan modul lain saat digabung.
class QueueDatabase {
  QueueDatabase._();
  static final QueueDatabase instance = QueueDatabase._();

  static const _dbName = 'posko_queue.db';
  static Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    if (kIsWeb) {
      return databaseFactoryFfiWebNoWebWorker.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
      );
    }
    final dir = await getDatabasesPath();
    return openDatabase(
      join(dir, _dbName),
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE queue_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id TEXT NOT NULL UNIQUE,
        jenis_barang TEXT NOT NULL,
        jumlah INTEGER NOT NULL,
        satuan TEXT NOT NULL,
        urgensi TEXT NOT NULL,
        keterangan TEXT,
        foto_path TEXT,
        latitude REAL,
        longitude REAL,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }
}