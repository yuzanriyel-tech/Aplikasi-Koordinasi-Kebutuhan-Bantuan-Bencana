import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/penyaluran.dart';
import '../models/stok_barang.dart';
import '../theme/app_theme.dart';

class FormPenyaluranScreen extends StatefulWidget {
  // DATA YANG DIKIRIM DARI SCREEN RIWAYAT: daftar stok barang.
  final List<StokBarang> stok;

  const FormPenyaluranScreen({super.key, required this.stok});

  @override
  State<FormPenyaluranScreen> createState() => _FormPenyaluranScreenState();
}

class _FormPenyaluranScreenState extends State<FormPenyaluranScreen> {
  // Pilihan satuan untuk dropdown
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

  // STATE: kunci form, isi field, barang terpilih, foto, status loading.
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  StokBarang? _barang;
  String? _satuan;
  bool _adaFoto = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    super.dispose();
  }

  // VALIDATION
  String? _validasiNama(String? v) {
    if (v == null || v.trim().isEmpty)
      return 'Nama penerima tidak boleh kosong';
    return null;
  }

  String? _validasiJumlah(String? v) {
    final angka = int.tryParse(v ?? '');
    if (angka == null || angka <= 0) return 'Jumlah harus angka lebih dari 0';
    if (_barang != null && angka > _barang!.sisa) {
      return 'Stok hanya tersisa ${_barang!.sisa} ${_barang!.satuan}';
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
    return _barang != null && angka != null && angka > _barang!.sisa;
  }

  // EVENT: tombol Simpan Data ditekan
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      // FEEDBACK kritis (FR-30)
      if (_melebihiStok()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Stok tidak mencukupi '),
          ),
        );
      }
      return; // tetap di form
    }

    setState(() => _isLoading = true); // FEEDBACK: sedang berlangsung
    await Future.delayed(const Duration(seconds: 1)); // simulasi simpan
    if (!mounted) return;

    final hasil = Penyaluran(
      namaPenerima: _namaCtrl.text.trim(),
      jenisBarang: _barang!.nama,
      jumlah: int.parse(_jumlahCtrl.text),
      satuan: _satuan!,
      tanggal: DateTime.now(),
      adaFoto: _adaFoto,
    );

    // RESULT: dikembalikan ke screen sebelumnya
    Navigator.pop(context, hasil);
  }

  Widget _label(String teks) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      teks,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penyaluran Bantuan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Data penyaluran',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Catat penerima dan jumlah bantuan untuk penyaluran yang transparan.',
              style: TextStyle(color: warnaTeks2, fontSize: 13),
            ),
            const SizedBox(height: 20),
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
                _satuan = v?.satuan; // satuan otomatis menyesuaikan barang
              }),
              validator: (v) => v == null ? 'Pilih jenis barang' : null,
            ),

            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Jumlah'),
                      TextFormField(
                        controller: _jumlahCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Contoh: 5',
                        ),
                        validator: _validasiJumlah,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Satuan'),
                      DropdownButtonFormField<String>(
                        value: _satuan,
                        isExpanded: true,
                        decoration: const InputDecoration(hintText: 'Satuan'),
                        items: _daftarSatuan
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _satuan = v),
                        validator: _validasiSatuan,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: ganti dengan kamera sungguhan (paket image_picker)
            InkWell(
              onTap: () => setState(() => _adaFoto = !_adaFoto),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 96,
                decoration: BoxDecoration(
                  color: warnaSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: warnaUtama),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _adaFoto ? Icons.check_circle : Icons.camera_alt,
                      color: warnaUtama,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _adaFoto
                          ? 'Foto bukti terlampir'
                          : 'Ambil Foto Bukti Serah Terima',
                      style: const TextStyle(
                        color: warnaUtama,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                  : const Text('Simpan Data'),
            ),
          ],
        ),
      ),
    );
  }
}
