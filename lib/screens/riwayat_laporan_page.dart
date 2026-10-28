import 'package:flutter/material.dart';

import '../data/dummy_laporan.dart';
import '../models/laporan_bantuan.dart';
import 'riwayat_laporan_screen.dart';

class RiwayatLaporanPage extends StatefulWidget {
  const RiwayatLaporanPage({super.key});

  @override
  State<RiwayatLaporanPage> createState() => _RiwayatLaporanPageState();
}

class _RiwayatLaporanPageState extends State<RiwayatLaporanPage> {
  // static supaya perubahan tidak hilang saat pindah halaman
  static final List<LaporanBantuan> _laporan = List.of(dummyLaporan);

  void _perbarui(LaporanBantuan laporan) {
    final index = _laporan.indexWhere((item) => item.id == laporan.id);
    if (index != -1) setState(() => _laporan[index] = laporan);
  }

  void _hapus(String id) {
    setState(() => _laporan.removeWhere((item) => item.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return RiwayatLaporanScreen(
      laporan: _laporan,
      onUpdate: _perbarui,
      onDelete: _hapus,
    );
  }
}