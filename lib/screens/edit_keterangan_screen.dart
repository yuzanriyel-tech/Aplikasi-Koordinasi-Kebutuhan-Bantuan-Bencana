import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/laporan_bantuan.dart';
import '../services/lokasi_service.dart';

class EditKeteranganScreen extends StatefulWidget {
  final LaporanBantuan laporan;

  const EditKeteranganScreen({super.key, required this.laporan});

  @override
  State<EditKeteranganScreen> createState() => _EditKeteranganScreenState();
}

class _EditKeteranganScreenState extends State<EditKeteranganScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganController = TextEditingController();
  final _lokasiService = LokasiService();

  Position? _lokasiTerbaru;
  bool _mengambilLokasi = false;
  bool _menyimpan = false;
  String? _pesanLokasi;
  bool _lokasiBerhasil = false;

  @override
  void initState() {
    super.initState();
    _keteranganController.text = widget.laporan.keterangan;
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _ambilGps() async {
    setState(() {
      _mengambilLokasi = true;
      _pesanLokasi = null;
      _lokasiBerhasil = false;
    });
    try {
      final position = await _lokasiService.ambilLokasiTerbaru();
      if (!mounted) return;
      setState(() {
        _lokasiTerbaru = position;
        _pesanLokasi = 'Koordinat terbaru berhasil diambil.';
        _lokasiBerhasil = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pesanLokasi = e.toString().replaceFirst('Exception: ', '');
        _lokasiBerhasil = false;
      });
    } finally {
      if (mounted) setState(() => _mengambilLokasi = false);
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    // GPS wajib diperbarui setiap kali keterangan disimpan.
    // Jika GPS belum berhasil diambil dalam sesi edit ini, ambil otomatis.
    if (_lokasiTerbaru == null) {
      await _ambilGps();
    }
    if (!mounted) return;

    if (_lokasiTerbaru == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_pesanLokasi ?? 'Lokasi GPS wajib diperbarui sebelum menyimpan.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _menyimpan = true);
    final laporanBaru = widget.laporan.copyWith(
      keterangan: _keteranganController.text.trim(),
      latitude: _lokasiTerbaru!.latitude,
      longitude: _lokasiTerbaru!.longitude,
      terakhirDiperbarui: DateTime.now(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _menyimpan = false);
    Navigator.pop(context, laporanBaru);
  }

  String _koordinat(double lat, double lon) =>
      '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';

  @override
  Widget build(BuildContext context) {
    final lat = _lokasiTerbaru?.latitude ?? widget.laporan.latitude;
    final lon = _lokasiTerbaru?.longitude ?? widget.laporan.longitude;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Keterangan', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: const Color(0xFFFFF0E4), borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFC6530A)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hanya keterangan tambahan yang dapat diedit. Lokasi GPS wajib diperbarui setiap kali keterangan disimpan.',
                        style: TextStyle(color: Color(0xFF9B4B13), height: 1.4, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text('Keterangan tambahan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _keteranganController,
                minLines: 4,
                maxLines: 5,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Tulis pembaruan kondisi kebutuhan...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Keterangan tidak boleh kosong.';
                  if (value.trim().length < 5) return 'Keterangan minimal 5 karakter.';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text('Lokasi laporan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE7E0DA))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFFE86B18)),
                        SizedBox(width: 8),
                        Text('Koordinat GPS', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF7F4F1), borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        lat == null || lon == null ? 'Koordinat belum tersedia' : _koordinat(lat, lon),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lokasiTerbaru == null ? 'Koordinat di atas adalah lokasi terakhir yang tersimpan.' : 'Akurasi: ${_lokasiTerbaru!.accuracy.toStringAsFixed(0)} meter',
                      style: const TextStyle(color: Color(0xFF817870), fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _mengambilLokasi ? null : _ambilGps,
                        icon: _mengambilLokasi
                            ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location),
                        label: Text(_mengambilLokasi ? 'Mengambil lokasi...' : 'Ambil Lokasi GPS Terbaru'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    if (_pesanLokasi != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_lokasiBerhasil ? Icons.check_circle : Icons.error_outline,
                              color: _lokasiBerhasil ? const Color(0xFF25834B) : Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pesanLokasi!,
                              style: TextStyle(color: _lokasiBerhasil ? const Color(0xFF25834B) : Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _menyimpan ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _menyimpan || _mengambilLokasi ? null : _simpan,
                      icon: _menyimpan
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_outlined),
                      label: Text(_menyimpan ? 'Menyimpan...' : 'Simpan Perubahan'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
