/// Tingkat urgensi kebutuhan bantuan.
enum Urgency {
  rendah('Rendah'),
  sedang('Sedang'),
  tinggi('Tinggi');

  const Urgency(this.label);
  final String label;
}

/// Status sinkronisasi sebuah data ke server.
enum SyncStatus {
  pending('Menunggu'),
  sent('Terkirim');

  const SyncStatus(this.label);
  final String label;
}

class Item {
  final String id;
  final String title; // jenis barang
  final int quantity;
  final String unit;
  final Urgency urgency;
  final String note;
  final bool hasPhoto;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final SyncStatus syncStatus;

  const Item({
    required this.id,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.urgency,
    required this.createdAt,
    this.note = '',
    this.hasPhoto = false,
    this.latitude = -6.9715,
    this.longitude = 107.6191,
    this.syncStatus = SyncStatus.pending,
  });

  String get subtitle => '$quantity $unit';

  String get description =>
      note.trim().isEmpty ? 'Tidak ada keterangan tambahan.' : note;

  bool get isPending => syncStatus == SyncStatus.pending;

  Item copyWith({
    String? title,
    int? quantity,
    String? unit,
    Urgency? urgency,
    String? note,
    bool? hasPhoto,
    double? latitude,
    double? longitude,
    SyncStatus? syncStatus,
  }) {
    return Item(
      id: id,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      urgency: urgency ?? this.urgency,
      note: note ?? this.note,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
