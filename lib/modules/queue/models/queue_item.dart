import 'dart:math';

/// Model data antrean lokal (pending sync) - Modul B.
class QueueItem {
  final int? id;

  /// ID unik dari sisi klien, dipakai Modul C agar data tidak terkirim ganda (NFR-05).
  final String clientId;
  final String jenisBarang;
  final int jumlah;
  final String satuan;
  final String urgensi;
  final String keterangan;

  /// Diisi Modul A bila ada foto (opsional).
  final String? fotoPath;

  /// Koordinat GPS posko saat data dicatat (FR-14).
  final double? latitude;
  final double? longitude;

  /// 'pending' = masih mengantre, 'sent' = sudah terkirim (diubah Modul C).
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const urgensiOptions = ['Tinggi', 'Sedang', 'Rendah'];
  static const satuanOptions = [
    'kg',
    'liter',
    'dus',
    'karung',
    'paket',
    'botol',
    'buah',
    'lembar',
  ];
  static const statusPending = 'pending';
  static const statusSent = 'sent';

  const QueueItem({
    this.id,
    required this.clientId,
    required this.jenisBarang,
    required this.jumlah,
    required this.satuan,
    required this.urgensi,
    this.keterangan = '',
    this.fotoPath,
    this.latitude,
    this.longitude,
    this.status = statusPending,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Membuat item baru (belum punya id database).
  factory QueueItem.create({
    required String jenisBarang,
    required int jumlah,
    required String satuan,
    required String urgensi,
    String keterangan = '',
    String? fotoPath,
    double? latitude,
    double? longitude,
  }) {
    final now = DateTime.now();
    return QueueItem(
      clientId: '${now.microsecondsSinceEpoch}-${Random().nextInt(1000000)}',
      jenisBarang: jenisBarang,
      jumlah: jumlah,
      satuan: satuan,
      urgensi: urgensi,
      keterangan: keterangan,
      fotoPath: fotoPath,
      latitude: latitude,
      longitude: longitude,
      createdAt: now,
      updatedAt: now,
    );
  }

  QueueItem copyWith({
    String? jenisBarang,
    int? jumlah,
    String? satuan,
    String? urgensi,
    String? keterangan,
    String? fotoPath,
    double? latitude,
    double? longitude,
    String? status,
    DateTime? updatedAt,
  }) {
    return QueueItem(
      id: id,
      clientId: clientId,
      jenisBarang: jenisBarang ?? this.jenisBarang,
      jumlah: jumlah ?? this.jumlah,
      satuan: satuan ?? this.satuan,
      urgensi: urgensi ?? this.urgensi,
      keterangan: keterangan ?? this.keterangan,
      fotoPath: fotoPath ?? this.fotoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'client_id': clientId,
        'jenis_barang': jenisBarang,
        'jumlah': jumlah,
        'satuan': satuan,
        'urgensi': urgensi,
        'keterangan': keterangan,
        'foto_path': fotoPath,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory QueueItem.fromMap(Map<String, Object?> m) => QueueItem(
        id: m['id'] as int?,
        clientId: m['client_id'] as String,
        jenisBarang: m['jenis_barang'] as String,
        jumlah: m['jumlah'] as int,
        satuan: m['satuan'] as String,
        urgensi: m['urgensi'] as String,
        keterangan: (m['keterangan'] as String?) ?? '',
        fotoPath: m['foto_path'] as String?,
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        status: m['status'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updated_at'] as int),
      );
}