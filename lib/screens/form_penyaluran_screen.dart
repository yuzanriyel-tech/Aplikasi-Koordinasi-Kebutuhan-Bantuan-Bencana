import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/penyaluran.dart';
import '../models/stok_barang.dart';
import '../theme/app_theme.dart';

class FormPenyaluranScreen extends StatefulWidget {
  // DATA YANG DIKIRIM DARI SCREEN RIWAYAT: daftar stok barang.
  final List<StokBarang> stok;

  // Kalau diisi = mode EDIT (form terisi data lama). Kalau null = mode TAMBAH.
  final Penyaluran? awal;

  const FormPenyaluranScreen({super.key, required this.stok, this.awal});

  @override
  State<FormPenyaluranScreen> createState() => _FormPenyaluranScreenState();
}

class _FormPenyaluranScreenState extends State<FormPenyaluranScreen> {
  static const _daftarSatuan = [
    'kg',
    'dus',
    'buah',
    'lembar',
    'pak',
    'liter',
    'kotak',
    'helai',
  ];

  static const _batasFotoBytes = 1024 * 1024; // NFR-13: maksimal 1 MB

  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _picker = ImagePicker();

  StokBarang? _barang;
  String? _satuan;
  String? _fotoPath;
  bool _isLoading = false;

  bool get _modeEdit => widget.awal != null;

  @override
  void initState() {
    super.initState();
    final a = widget.awal;
    if (a != null) {
      // Isi form dengan data lama
      _namaCtrl.text = a.namaPenerima;
      _jumlahCtrl.text = a.jumlah.toString();
      _barang = widget.stok.firstWhere((b) => b.nama == a.jenisBarang);
      _satuan = a.satuan;
      _fotoPath = a.fotoPath;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    super.dispose();
  }

  // Stok yang boleh dipakai. Saat edit, jumlah lama "dikembalikan" dulu
  // supaya user bisa mengubah jumlah tanpa dianggap melebihi stok.
  int _tersedia(StokBarang b) {
    final a = widget.awal;
    if (a != null && a.jenisBarang == b.nama) return b.sisa + a.jumlah;
    return b.sisa;
  }

  // VALIDATION
  String? _validasiNama(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Nama penerima tidak boleh kosong';
    }
    return null;
  }

  String? _validasiJumlah(String? v) {
    final angka = int.tryParse(v ?? '');
    if (angka == null || angka <= 0) {
      return 'Jumlah harus berupa angka lebih dari 0';
    }
    if (_barang != null && angka > _tersedia(_barang!)) {
      return 'Stok hanya tersisa ${_tersedia(_barang!)} ${_barang!.satuan}';
    }
    return null;
  }

  String? _validasiSatuan(String? v) {
    if (v == null) return 'Pilih satuan';
    if (_barang != null && v != _barang!.satuan) {
      return 'Stok dalam ${_barang!.satuan}';
    }
    return null;
  }

  bool _melebihiStok() {
    final angka = int.tryParse(_jumlahCtrl.text);
    return _barang != null && angka != null && angka > _tersedia(_barang!);
  }

  void _pesan(String teks, {Color warna = Colors.red}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(backgroundColor: warna, content: Text(teks)));
  }

  // KAMERA (FR-29): ambil foto, kompres, simpan permanen
  Future<void> _ambilFoto() async {
    try {
      final hasil = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 60, // kompres JPEG
        maxWidth: 1280, // kecilkan resolusi
      );
      if (hasil == null) return; // user membatalkan

      // Salin ke folder aplikasi supaya tidak hilang dari cache
      final dir = await getApplicationDocumentsDirectory();
      final tujuan =
          '${dir.path}/serah_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = await File(hasil.path).copy(tujuan);

      // NFR-13: foto maksimal 1 MB setelah dikompres
      if (await file.length() > _batasFotoBytes) {
        await file.delete();
        if (!mounted) return;
        _pesan('Foto terlalu besar (>1 MB), coba ambil ulang');
        return;
      }

      if (!mounted) return;
      setState(() => _fotoPath = file.path);
    } on PlatformException {
      // NFR-12: izin kamera ditolak / kamera bermasalah -> app tidak crash
      if (!mounted) return;
      _pesan(
        'Kamera tidak bisa dipakai (izin ditolak atau kamera bermasalah). '
        'Foto bersifat opsional, data tetap bisa disimpan.',
      );
    } catch (_) {
      if (!mounted) return;
      _pesan('Gagal mengambil foto, coba lagi');
    }
  }

  // EVENT: tombol Simpan ditekan
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      // FEEDBACK kritis (FR-30)
      if (_melebihiStok()) {
        _pesan('jumlah melebihi sisa stok!');
      }
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulasi simpan
    if (!mounted) return;

    final hasil = Penyaluran(
      namaPenerima: _namaCtrl.text.trim(),
      jenisBarang: _barang!.nama,
      jumlah: int.parse(_jumlahCtrl.text),
      satuan: _satuan!,
      // Saat edit, tanggal asli dipertahankan
      tanggal: widget.awal?.tanggal ?? DateTime.now(),
      fotoPath: _fotoPath,
    );

    Navigator.pop(context, hasil);
  }

  Widget _label(String teks) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      teks,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );

  Widget _areaFoto() {
    // Belum ada foto: tombol ambil foto
    if (_fotoPath == null) {
      return InkWell(
        onTap: _ambilFoto,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: warnaSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: warnaUtama),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: warnaUtama),
              SizedBox(height: 8),
              Text(
                'Ambil Foto Bukti Serah Terima',
                style: TextStyle(
                  color: warnaUtama,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sudah ada foto: preview + ganti/hapus
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_fotoPath!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: warnaSoft,
              alignment: Alignment.center,
              child: const Text('Foto tidak ditemukan'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _ambilFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ganti Foto'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _fotoPath = null),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Foto'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Penyaluran' : 'Catat Penyaluran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            const SizedBox(height: 16),

            _label('Nama Penerima Warga'),
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(
                hintText: 'Contoh: Siti Aminah',
              ),
              validator: _validasiNama,
            ),
            const SizedBox(height: 16),

            _label('Jenis Barang'),
            DropdownButtonFormField<StokBarang>(
              value: _barang,
              decoration: const InputDecoration(hintText: 'Pilih jenis barang'),
              items: widget.stok
                  .map((b) => DropdownMenuItem(value: b, child: Text(b.nama)))
                  .toList(),
              onChanged: (v) => setState(() {
                _barang = v;
                _satuan = v?.satuan;
              }),
              validator: (v) => v == null ? 'Pilih jenis barang' : null,
            ),
            const SizedBox(height: 16),

            _label('Jumlah'),
            TextFormField(
              controller: _jumlahCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(hintText: 'Contoh: 5'),
              validator: _validasiJumlah,
            ),
            const SizedBox(height: 16),

            _label('Satuan'),
            DropdownButtonFormField<String>(
              value: _satuan,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Satuan'),
              items: _daftarSatuan
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _satuan = v),
              validator: _validasiSatuan,
            ),
            const SizedBox(height: 16),

            _label('Foto Bukti Serah Terima (opsional)'),
            _areaFoto(),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _isLoading ? null : _simpan,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan Penyaluran'),
            ),
          ],
        ),
      ),
    );
  }
}
