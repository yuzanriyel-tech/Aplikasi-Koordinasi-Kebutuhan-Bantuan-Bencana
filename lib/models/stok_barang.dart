class StokBarang {
  final String nama;
  final String satuan;
  final int awal;
  int tersalur;

  StokBarang({
    required this.nama,
    required this.satuan,
    required this.awal,
    this.tersalur = 0,
  });

  int get sisa => awal - tersalur;

  // Menipis kalau sisa kurang dari 50% stok awal
  bool get menipis => sisa / awal < 0.5;
}