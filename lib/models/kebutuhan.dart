/// Tingkat urgensi kebutuhan bantuan.
enum Urgensi {
  rendah('Rendah'),
  sedang('Sedang'),
  tinggi('Tinggi');

  final String label;
  const Urgensi(this.label);
}

/// Status sinkronisasi data ke server.
enum StatusSinkron {
  pending('Pending'),
  terkirim('Terkirim'),
  gagal('Gagal');

  final String label;
  const StatusSinkron(this.label);
}

/// Satu data kebutuhan bantuan (Modul A: FR-06 sampai FR-08).
class Kebutuhan {
  final String id; // ID unik, dibuat di perangkat (mencegah data ganda)
  final String jenisBarang;
  final int jumlah;
  final String satuan;
  final Urgensi urgensi;
  final String keterangan;
  final DateTime dibuatPada;
  final DateTime diperbaruiPada;
  final StatusSinkron statusSinkron;

  const Kebutuhan({
    required this.id,
    required this.jenisBarang,
    required this.jumlah,
    required this.satuan,
    required this.urgensi,
    required this.keterangan,
    required this.dibuatPada,
    required this.diperbaruiPada,
    required this.statusSinkron,
  });

  /// Salin data dengan sebagian isi diganti (id dan waktu dibuat tetap).
  Kebutuhan copyWith({
    String? jenisBarang,
    int? jumlah,
    String? satuan,
    Urgensi? urgensi,
    String? keterangan,
    DateTime? diperbaruiPada,
    StatusSinkron? statusSinkron,
  }) {
    return Kebutuhan(
      id: id,
      jenisBarang: jenisBarang ?? this.jenisBarang,
      jumlah: jumlah ?? this.jumlah,
      satuan: satuan ?? this.satuan,
      urgensi: urgensi ?? this.urgensi,
      keterangan: keterangan ?? this.keterangan,
      dibuatPada: dibuatPada,
      diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
      statusSinkron: statusSinkron ?? this.statusSinkron,
    );
  }
}

/// Aksi yang dilakukan user di form.
enum AksiForm { tambah, ubah, hapus }

/// Hasil yang DIKEMBALIKAN form ke layar daftar.
class HasilForm {
  final AksiForm aksi;
  final Kebutuhan data;

  const HasilForm(this.aksi, this.data);
}
