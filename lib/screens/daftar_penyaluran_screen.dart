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

  // EVENT: tombol tambah ditekan
  Future<void> _tambah() async {
    // NAVIGATION: kirim daftar stok ke form, tunggu hasil (result)
    final hasil = await Navigator.push<Penyaluran>(
      context,
      MaterialPageRoute(builder: (_) => FormPenyaluranScreen(stok: _stok)),
    );

    if (hasil == null || !mounted) return; // user kembali tanpa menyimpan

    // STATE berubah: riwayat bertambah, stok tersalur bertambah (FR-28)
    setState(() {
      _riwayat.insert(0, hasil);
      _stok.firstWhere((b) => b.nama == hasil.jenisBarang).tersalur +=
          hasil.jumlah;
    });

    // FEEDBACK sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Penyaluran berhasil dicatat')),
    );
  }

  // Hapus catatan (FR-27), stok dikembalikan
  void _hapus(Penyaluran p) {
    setState(() {
      _stok.firstWhere((b) => b.nama == p.jenisBarang).tersalur -= p.jumlah;
      _riwayat.remove(p);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan penyaluran dihapus')));
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

  Widget _kartu(Penyaluran p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: warnaSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              p.adaFoto ? Icons.photo_camera : Icons.inventory_2_outlined,
              color: warnaUtama,
            ),
          ),
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
            style: IconButton.styleFrom(backgroundColor: warnaSoft),
            icon: const Icon(Icons.delete_outline, color: warnaUtama),
            onPressed: () => _hapus(p),
          ),
        ],
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
    );
  }
}
