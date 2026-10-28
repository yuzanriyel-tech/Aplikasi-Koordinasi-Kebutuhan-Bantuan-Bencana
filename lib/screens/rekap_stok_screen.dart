import 'package:flutter/material.dart';
import '../models/stok_barang.dart';
import '../theme/app_theme.dart';

class RekapStokScreen extends StatelessWidget {
  // DATA YANG DIKIRIM DARI SCREEN RIWAYAT: daftar stok barang.
  final List<StokBarang> stok;

  const RekapStokScreen({super.key, required this.stok});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekap Stok Posko')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: stok.map(_kartu).toList(),
      ),
    );
  }

  Widget _kartu(StokBarang b) {
    final warna = b.menipis ? Colors.red : Colors.green;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warnaUtama),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(b.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (b.menipis) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Menipis',
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                'Sisa ${b.sisa} ${b.satuan}',
                style: TextStyle(color: warna, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: b.sisa / b.awal,
              minHeight: 8,
              color: warna,
              backgroundColor: const Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Awal ${b.awal} ${b.satuan} | Tersalur ${b.tersalur} ${b.satuan}',
            style: const TextStyle(color: warnaTeks2, fontSize: 12),
          ),
        ],
      ),
    );
  }
}