import 'dart:io';

import 'package:flutter/material.dart';

import '../models/penyaluran.dart';
import '../models/stok_barang.dart';
import '../theme/app_theme.dart';
import 'form_penyaluran_screen.dart';
import 'rekap_stok_screen.dart';

class DaftarPenyaluranScreen extends StatefulWidget {
  const DaftarPenyaluranScreen({super.key});

  @override
  State<DaftarPenyaluranScreen> createState() => _DaftarPenyaluranScreenState();
}

class _DaftarPenyaluranScreenState extends State<DaftarPenyaluranScreen> {
  // STATE: stok rekap posko (dummy) dan riwayat penyaluran
  final List<StokBarang> _stok = [
    StokBarang(nama: 'Beras', satuan: 'kg', awal: 100),
    StokBarang(nama: 'Mie Instan', satuan: 'dus', awal: 50),
    StokBarang(nama: 'Air Mineral', satuan: 'dus', awal: 50),
    StokBarang(nama: 'Selimut', satuan: 'helai', awal: 50),
    StokBarang(nama: 'Susu Bayi', satuan: 'kotak', awal: 30),
    StokBarang(nama: 'Popok Bayi', satuan: 'pak', awal: 30),
    StokBarang(nama: 'Terpal', satuan: 'lembar', awal: 20),
  ];
  final List<Penyaluran> _riwayat = [];

  static const _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String _formatTanggal(DateTime t) =>
      '${t.day} ${_bulan[t.month - 1]} ${t.year}';

  String _jam(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  String _labelTanggal(DateTime t) {
    final now = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);
    final tgl = DateTime(t.year, t.month, t.day);
    final selisih = hariIni.difference(tgl).inDays;
    if (selisih == 0) return 'Hari ini';
    if (selisih == 1) return 'Kemarin';
    return _formatTanggal(t);
  }

  StokBarang _cariStok(String nama) => _stok.firstWhere((b) => b.nama == nama);

  void _snack(String teks, Color warna) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(backgroundColor: warna, content: Text(teks)));
  }

  // EVENT: tombol tambah ditekan
  Future<void> _tambah() async {
    final hasil = await Navigator.push<Penyaluran>(
      context,
      MaterialPageRoute(builder: (_) => FormPenyaluranScreen(stok: _stok)),
    );

    if (hasil == null || !mounted) return;

    // STATE berubah: riwayat bertambah, stok tersalur bertambah (FR-28)
    setState(() {
      _riwayat.insert(0, hasil);
      _cariStok(hasil.jenisBarang).tersalur += hasil.jumlah;
    });

    _snack('Penyaluran berhasil dicatat', Colors.green);
  }

  // EDIT penyaluran (FR-28): kirim data lama ke form, terima data baru
  Future<void> _edit(Penyaluran lama) async {
    final baru = await Navigator.push<Penyaluran>(
      context,
      MaterialPageRoute(
        builder: (_) => FormPenyaluranScreen(stok: _stok, awal: lama),
      ),
    );

    if (baru == null || !mounted) return;

    setState(() {
      // 1) kembalikan stok sesuai data lama
      _cariStok(lama.jenisBarang).tersalur -= lama.jumlah;
      // 2) kurangi stok sesuai data baru (barang bisa saja berganti)
      _cariStok(baru.jenisBarang).tersalur += baru.jumlah;
      // 3) ganti catatan di posisi yang sama
      final i = _riwayat.indexOf(lama);
      if (i != -1) _riwayat[i] = baru;
    });

    _snack('Penyaluran berhasil diperbarui', Colors.green);
  }

  // Hapus catatan (FR-27), stok dikembalikan
  void _hapus(Penyaluran p) {
    setState(() {
      _cariStok(p.jenisBarang).tersalur -= p.jumlah;
      _riwayat.remove(p);
    });
    _snack(
      'Catatan penyaluran dihapus',
      const Color.fromARGB(255, 190, 26, 14),
    );
  }

  Widget _banner() {
    final jumlahWarga = _riwayat.map((p) => p.namaPenerima).toSet().length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warnaUtama,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.white),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_riwayat.length} penyaluran tercatat',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Bantuan untuk $jumlahWarga warga',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Thumbnail: foto asli kalau ada, ikon kalau tidak
  Widget _thumbnail(Penyaluran p) {
    final ikon = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: warnaSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.inventory_2_outlined, color: warnaUtama),
    );

    if (p.fotoPath == null) return ikon;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(p.fotoPath!),
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ikon,
      ),
    );
  }

  Widget _kartu(Penyaluran p) {
    return InkWell(
      onTap: () => _edit(p),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            _thumbnail(p),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.namaPenerima,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${p.jenisBarang} · ${p.jumlah} ${p.satuan}',
                    style: const TextStyle(color: warnaTeks2, fontSize: 13),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 13, color: warnaTeks2),
                      const SizedBox(width: 4),
                      Text(
                        'Tersalurkan · ${_jam(p.tanggal)}',
                        style: const TextStyle(color: warnaTeks2, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit',
              style: IconButton.styleFrom(backgroundColor: warnaSoft),
              icon: const Icon(Icons.edit_outlined, color: warnaUtama),
              onPressed: () => _edit(p),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Hapus',
              style: IconButton.styleFrom(backgroundColor: warnaSoft),
              icon: const Icon(Icons.delete_outline, color: warnaUtama),
              onPressed: () => _hapus(p),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _bangunDaftar() {
    final widgets = <Widget>[];
    String? labelSebelumnya;
    for (final p in _riwayat) {
      final label = _labelTanggal(p.tanggal);
      if (label != labelSebelumnya) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatTanggal(p.tanggal),
                  style: const TextStyle(color: warnaTeks2, fontSize: 12),
                ),
              ],
            ),
          ),
        );
        labelSebelumnya = label;
      }
      widgets.add(_kartu(p));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penyaluran'),
        actions: [
          IconButton(
            tooltip: 'Rekap stok posko',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RekapStokScreen(stok: _stok)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _banner(),
          if (_riwayat.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: Text('Belum ada penyaluran')),
            )
          else
            ..._bangunDaftar(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        backgroundColor: warnaUtama,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        selectedItemColor: warnaUtama,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Kebutuhan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Antrean'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Distribusi',
          ),
        ],
      ),
    );
  }
}
