import 'package:flutter/material.dart';

import '../data/kebutuhan_repository.dart';
import '../models/kebutuhan.dart';
import '../theme/posync_colors.dart';
import '../utils/validators.dart';

/// Form tambah / edit kebutuhan bantuan (FR-06 dan FR-08).
/// Menerima: data (null = tambah baru, berisi = edit data itu).
/// Mengembalikan: HasilForm (aksi + data) lewat Navigator.pop.
class FormKebutuhanScreen extends StatefulWidget {
  // data yang DITERIMA dari layar daftar
  final Kebutuhan? data;

  const FormKebutuhanScreen({super.key, this.data});

  @override
  State<FormKebutuhanScreen> createState() => _FormKebutuhanScreenState();
}

class _FormKebutuhanScreenState extends State<FormKebutuhanScreen> {
  final _repository = KebutuhanRepository.instance;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _jenisController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _satuanController;
  late final TextEditingController _keteranganController;

  // ---- STATE layar ini ----
  Urgensi? _urgensi; // null = belum dipilih
  bool _urgensiError = false; // tampilkan pesan error urgensi?
  bool _isSaving = false; // sedang menyimpan / menghapus?
  String? _errorMessage; // pesan error dari proses simpan

  bool get _modeEdit => widget.data != null;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _jenisController = TextEditingController(text: d?.jenisBarang ?? '');
    _jumlahController = TextEditingController(text: d == null ? '' : '${d.jumlah}');
    _satuanController = TextEditingController(text: d?.satuan ?? '');
    _keteranganController = TextEditingController(text: d?.keterangan ?? '');
    _urgensi = d?.urgensi;
  }

  @override
  void dispose() {
    _jenisController.dispose();
    _jumlahController.dispose();
    _satuanController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  // ---- VALIDASI jenis barang: minimal 3 huruf dan tidak boleh kembar ----
  String? _validasiJenis(String? value) {
    final error = Validators.minLength(value, 3, fieldName: 'Jenis barang');
    if (error != null) return error;
    if (_repository.sudahAda(value!, kecualiId: widget.data?.id)) {
      return '"${value.trim()}" sudah tercatat';
    }
    return null;
  }

  // ---- EVENT: user menekan "Simpan di Perangkat" ----
  Future<void> _simpan() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final urgensiValid = _urgensi != null;
    setState(() {
      _urgensiError = !urgensiValid;
      _errorMessage = null;
    });
    if (!formValid || !urgensiValid) return; // tidak valid -> tetap di form

    setState(() => _isSaving = true); // FEEDBACK: loading

    final jenis = _jenisController.text.trim();
    final jumlah = int.parse(_jumlahController.text.trim());
    final satuan = _satuanController.text.trim();
    final keterangan = _keteranganController.text.trim();

    try {
      final Kebutuhan hasil;
      if (_modeEdit) {
        hasil = await _repository.perbarui(
          widget.data!,
          jenisBarang: jenis,
          jumlah: jumlah,
          satuan: satuan,
          urgensi: _urgensi!,
          keterangan: keterangan,
        );
      } else {
        hasil = await _repository.tambah(
          jenisBarang: jenis,
          jumlah: jumlah,
          satuan: satuan,
          urgensi: _urgensi!,
          keterangan: keterangan,
        );
      }
      if (!mounted) return;
      // NAVIGASI + RESULT: tutup form sambil MEMBAWA hasilnya ke layar daftar
      Navigator.pop(
        context,
        HasilForm(_modeEdit ? AksiForm.ubah : AksiForm.tambah, hasil),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ---- EVENT: user menekan "Hapus data ini" ----
  Future<void> _hapus() async {
    final data = widget.data!;
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus data ini?'),
        content: Text('"${data.jenisBarang}" akan dihapus dari perangkat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || yakin != true) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await _repository.hapus(data.id);
      if (!mounted) return;
      Navigator.pop(context, HasilForm(AksiForm.hapus, data));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ---- tampilan ----
  Widget _label(String teks, {bool opsional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: teks,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: PosyncColors.textDark,
              ),
            ),
            if (opsional)
              const TextSpan(
                text: ' (opsional)',
                style: TextStyle(color: PosyncColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dekor(String hint) {
    final garis = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: PosyncColors.border),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PosyncColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: garis,
      enabledBorder: garis,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: PosyncColors.primary, width: 1.5),
      ),
    );
  }

  Widget _pilihanUrgensi(Urgensi u) {
    final aktif = _urgensi == u;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: u == Urgensi.tinggi ? 0 : 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _isSaving
              ? null
              : () => setState(() {
                    _urgensi = u;
                    _urgensiError = false;
                  }),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: aktif ? u.latar : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: aktif ? u.teks : PosyncColors.border,
                width: aktif ? 1.5 : 1,
              ),
            ),
            child: Text(
              u.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: aktif ? u.teks : PosyncColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kotakFoto() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur kamera menyusul (opsional)')),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(PosyncColors.dashed),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PosyncColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 20,
                  color: PosyncColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ambil foto kondisi lapangan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: PosyncColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PosyncColors.background,
      appBar: AppBar(
        backgroundColor: PosyncColors.background,
        foregroundColor: PosyncColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _modeEdit ? 'Edit kebutuhan' : 'Tambah kebutuhan',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: PosyncColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label('Jenis barang'),
                TextFormField(
                  controller: _jenisController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _dekor('cth: Susu bayi'),
                  validator: _validasiJenis,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Jumlah'),
                          TextFormField(
                            controller: _jumlahController,
                            enabled: !_isSaving,
                            keyboardType: TextInputType.number,
                            decoration: _dekor('cth: 10'),
                            validator: Validators.jumlah,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Satuan'),
                          TextFormField(
                            controller: _satuanController,
                            enabled: !_isSaving,
                            decoration: _dekor('cth: kaleng'),
                            validator: (value) =>
                                Validators.requiredField(value, fieldName: 'Satuan'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _label('Tingkat urgensi'),
                Row(children: Urgensi.values.map(_pilihanUrgensi).toList()),
                if (_urgensiError)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Pilih tingkat urgensi',
                      style: TextStyle(color: PosyncColors.danger, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 14),
                _label('Keterangan tambahan', opsional: true),
                TextFormField(
                  controller: _keteranganController,
                  enabled: !_isSaving,
                  maxLines: 3,
                  maxLength: 100,
                  decoration: _dekor('cth: untuk bayi berusia 6 bulan'),
                ),
                const SizedBox(height: 4),
                _label('Foto kondisi lapangan', opsional: true),
                _kotakFoto(),
                const SizedBox(height: 20),
                if (_errorMessage != null) ...[
                  _BannerError(pesan: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                
                FilledButton(
                  onPressed: _isSaving ? null : _simpan,
                  style: FilledButton.styleFrom(
                    backgroundColor: PosyncColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Menyimpan...'),
                          ],
                        )
                      : const Text(
                          'Simpan di Perangkat',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lokasi posko dicatat otomatis. Data dikirim ke server saat online.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: PosyncColors.textMuted),
                ),
                if (_modeEdit) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isSaving ? null : _hapus,
                    child: const Text(
                      'Hapus data ini',
                      style: TextStyle(
                        color: PosyncColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner pesan error kecil di dalam form.
class _BannerError extends StatelessWidget {
  final String pesan;
  const _BannerError({required this.pesan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PosyncColors.tinggiBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: PosyncColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(pesan, style: const TextStyle(color: PosyncColors.danger)),
          ),
        ],
      ),
    );
  }
}

/// Garis putus-putus untuk kotak foto.
class _DashedBorderPainter extends CustomPainter {
  final Color warna;
  _DashedBorderPainter(this.warna);

  @override
  void paint(Canvas canvas, Size size) {
    final kuas = Paint()
      ..color = warna
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      );
    for (final metric in path.computeMetrics()) {
      double jarak = 0;
      while (jarak < metric.length) {
        canvas.drawPath(metric.extractPath(jarak, jarak + 6), kuas);
        jarak += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}