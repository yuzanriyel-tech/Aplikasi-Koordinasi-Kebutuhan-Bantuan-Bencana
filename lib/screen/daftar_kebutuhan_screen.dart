import 'package:flutter/material.dart';

import '../data/kebutuhan_repository.dart';
import '../models/kebutuhan.dart';
import '../routes/app_routes.dart';
import '../theme/posync_colors.dart';

enum _Filter { semua, urgensiTinggi, pending }

/// Daftar kebutuhan bantuan yang tersimpan di perangkat (FR-07).
class DaftarKebutuhanScreen extends StatefulWidget {
  const DaftarKebutuhanScreen({super.key});

  @override
  State<DaftarKebutuhanScreen> createState() => _DaftarKebutuhanScreenState();
}

class _DaftarKebutuhanScreenState extends State<DaftarKebutuhanScreen> {
  final _repository = KebutuhanRepository.instance;

  // ---- STATE layar ini ----
  _Filter _filter = _Filter.semua;

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  // ---- EVENT: tap tombol + (tambah) atau ikon pensil (edit) ----
  Future<void> _bukaForm([Kebutuhan? data]) async {
    // DATA DIKIRIM ke form: null = tambah baru, berisi = edit data itu
    final hasil = await Navigator.pushNamed<HasilForm>(
      context,
      AppRoutes.form,
      arguments: data,
    );
    if (!mounted || hasil == null) return; // null = user kembali tanpa menyimpan

    // RESULT diterima: gambar ulang daftar, lalu beri konfirmasi
    setState(() {});
    final nama = hasil.data.jenisBarang;
    _snack(switch (hasil.aksi) {
      AksiForm.tambah => '"$nama" tersimpan di perangkat',
      AksiForm.ubah => '"$nama" berhasil diperbarui',
      AksiForm.hapus => '"$nama" dihapus dari perangkat',
    });
  }

  List<Kebutuhan> get _terfilter {
    final semua = _repository.semua;
    return switch (_filter) {
      _Filter.semua => semua,
      _Filter.urgensiTinggi =>
        semua.where((e) => e.urgensi == Urgensi.tinggi).toList(),
      _Filter.pending =>
        semua.where((e) => e.statusSinkron == StatusSinkron.pending).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = _terfilter;

    return Scaffold(
      backgroundColor: PosyncColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Text(
                'Daftar kebutuhan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: PosyncColors.textDark,
                ),
              ),
            ),
            const Divider(height: 1, color: PosyncColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Wrap(
                spacing: 8,
                children: [
                  _chipFilter('Semua', _Filter.semua),
                  _chipFilter('Urgensi tinggi', _Filter.urgensiTinggi),
                  _chipFilter('Pending', _Filter.pending),
                ],
              ),
            ),
            Expanded(
              child: data.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada data untuk filter ini.',
                        style: TextStyle(color: PosyncColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _kartu(data[index]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PosyncColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => _bukaForm(),
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: _menuBawah(),
    );
  }

  Widget _chipFilter(String label, _Filter nilai) {
    final aktif = _filter == nilai;
    return ChoiceChip(
      label: Text(label),
      selected: aktif,
      showCheckmark: false,
      selectedColor: PosyncColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(color: aktif ? PosyncColors.primary : PosyncColors.textMuted),
      labelStyle: TextStyle(
        fontSize: 12,
        color: aktif ? Colors.white : PosyncColors.textMuted,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => setState(() => _filter = nilai),
    );
  }

  Widget _kartu(Kebutuhan item) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PosyncColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: PosyncColors.iconBox,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: PosyncColors.iconMerah,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item.jenisBarang,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: PosyncColors.textDark,
                        ),
                      ),
                      TextSpan(
                        text: '  ${item.jumlah} ${item.satuan}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PosyncColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.urgensi.latar,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.urgensi.label,
                        style: TextStyle(
                          color: item.urgensi.teks,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${item.statusSinkron.label}',
                      style: TextStyle(
                        color: item.statusSinkron.teks,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _bukaForm(item),
            icon: const Icon(Icons.edit_outlined, size: 20, color: PosyncColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ---- menu bawah (hanya "Kebutuhan" yang milik Modul A) ----
  Widget _menuBawah() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: PosyncColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              _itemMenu(Icons.assignment_outlined, 'Kebutuhan', aktif: true),
              _itemMenu(Icons.sync, 'Antrean'),
              _itemMenu(Icons.home_outlined, 'Beranda'),
              _itemMenu(Icons.access_time, 'Riwayat'),
              _itemMenu(Icons.inventory_2_outlined, 'Distribusi'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemMenu(IconData ikon, String label, {bool aktif = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: aktif ? null : () => _snack('Halaman $label dikerjakan oleh modul lain'),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: aktif ? PosyncColors.navPill : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ikon, size: 24, color: PosyncColors.navLabel),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: PosyncColors.navLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}