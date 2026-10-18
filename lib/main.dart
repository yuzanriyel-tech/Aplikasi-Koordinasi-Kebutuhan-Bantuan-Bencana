import 'package:flutter/material.dart';
import 'data/dummy_laporan.dart';
import 'models/laporan_bantuan.dart';
import 'screens/riwayat_laporan_screen.dart';

void main() {
  runApp(const PoskoRiwayatApp());
}

class PoskoRiwayatApp extends StatefulWidget {
  const PoskoRiwayatApp({super.key});

  @override
  State<PoskoRiwayatApp> createState() => _PoskoRiwayatAppState();
}

class _PoskoRiwayatAppState extends State<PoskoRiwayatApp> {
  final List<LaporanBantuan> _laporan = List.of(dummyLaporan);

  void _perbaruiLaporan(LaporanBantuan laporan) {
    final index = _laporan.indexWhere((item) => item.id == laporan.id);
    if (index != -1) {
      setState(() => _laporan[index] = laporan);
    }
  }

  void _hapusLaporan(String id) {
    setState(() => _laporan.removeWhere((item) => item.id == id));
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFE86B18);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Posko - Riwayat Laporan',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: orange),
        scaffoldBackgroundColor: const Color(0xFFFFFBF7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFBF7),
          foregroundColor: Color(0xFF242424),
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE7E0DA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE7E0DA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: orange, width: 1.5),
          ),
        ),
      ),
      home: RiwayatLaporanScreen(
        laporan: _laporan,
        onUpdate: _perbaruiLaporan,
        onDelete: _hapusLaporan,
      ),
    );
  }
}
