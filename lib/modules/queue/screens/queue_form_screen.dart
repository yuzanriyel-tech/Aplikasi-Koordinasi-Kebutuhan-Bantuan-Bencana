import 'package:flutter/material.dart';

import '../data/queue_repository.dart';
import '../models/queue_item.dart';
import '../services/location_service.dart';
import '../theme/queue_theme.dart';
import '../widgets/queue_widgets.dart';

/// Form tambah/edit kebutuhan di antrean (FR-11, FR-13, FR-14).
/// Mode tambah bersifat sementara sampai form Modul A tersambung.
class QueueFormScreen extends StatefulWidget {
  final QueueItem? item;
  const QueueFormScreen({super.key, this.item});

  @override
  State<QueueFormScreen> createState() => _QueueFormScreenState();
}

class _QueueFormScreenState extends State<QueueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _barangCtrl;
  late final TextEditingController _jumlahCtrl;
  late final TextEditingController _ketCtrl;
  late String _satuan;
  late String _urgensi;

  double? _lat;
  double? _lng;
  String? _locMessage;
  bool _locLoading = false;
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _barangCtrl = TextEditingController(text: i?.jenisBarang ?? '');
    _jumlahCtrl = TextEditingController(text: i?.jumlah.toString() ?? '');
    _ketCtrl = TextEditingController(text: i?.keterangan ?? '');
    _satuan = i?.satuan ?? QueueItem.satuanOptions.first;
    _urgensi = i?.urgensi ?? QueueItem.urgensiOptions[1];
    _lat = i?.latitude;
    _lng = i?.longitude;
    if (!_isEdit) {
      _locLoading = true;
      _fetchLocation();
    }
  }

  @override
  void dispose() {
    _barangCtrl.dispose();
    _jumlahCtrl.dispose();
    _ketCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    if (!_locLoading) setState(() => _locLoading = true);
    final r = await LocationService.getCurrent();
    if (!mounted) return;
    setState(() {
      _locLoading = false;
      if (r.hasLocation) {
        _lat = r.latitude;
        _lng = r.longitude;
        _locMessage = null;
      } else {
        _locMessage = r.message;
      }
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = QueueRepository.instance;
      final jumlah = int.parse(_jumlahCtrl.text.trim());
      if (_isEdit) {
        final ok = await repo.update(widget.item!.copyWith(
          jenisBarang: _barangCtrl.text.trim(),
          jumlah: jumlah,
          satuan: _satuan,
          urgensi: _urgensi,
          keterangan: _ketCtrl.text.trim(),
          latitude: _lat,
          longitude: _lng,
        ));
        if (!ok) throw Exception('Data sudah tidak ada di antrean');
      } else {
        await repo.enqueue(QueueItem.create(
          jenisBarang: _barangCtrl.text.trim(),
          jumlah: jumlah,
          satuan: _satuan,
          urgensi: _urgensi,
          keterangan: _ketCtrl.text.trim(),
          latitude: _lat,
          longitude: _lng,
        ));
      }
      if (!mounted) return;
      await showQueueSuccessDialog(
        context,
        _isEdit ? 'Data Berhasil Diperbarui' : 'Data Berhasil Ditambahkan ke Antrean',
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Gagal menyimpan data. Silakan coba lagi.');
    }
  }

  Future<void> _delete() async {
    final yes = await showQueueConfirmDialog(
      context,
      title: 'Hapus data ini?',
      message: '"${widget.item!.jenisBarang}" akan dihapus dari antrean dan tidak akan dikirim ke server.',
      confirmLabel: 'Hapus',
    );
    if (!yes || !mounted) return;
    setState(() => _saving = true);
    try {
      final ok = await QueueRepository.instance.delete(widget.item!.id!);
      if (!ok) throw Exception('Data tidak ditemukan');
      if (!mounted) return;
      await showQueueSuccessDialog(context, 'Data Berhasil Dihapus');
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('Gagal menghapus data. Silakan coba lagi.');
    }
  }

  Widget _locationCard() {
    final has = _lat != null && _lng != null;
    final text = has
        ? 'Lat ${_lat!.toStringAsFixed(6)}, Lng ${_lng!.toStringAsFixed(6)}'
        : (_locLoading ? 'Mencari lokasi...' : (_locMessage ?? 'Lokasi belum tersedia'));
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: QueueColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            has ? Icons.location_on : Icons.location_off_outlined,
            color: has ? QueueColors.orange600 : QueueColors.neutral500,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: has ? QueueTextStyles.helper : QueueTextStyles.helperMuted,
            ),
          ),
          if (_locLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: QueueColors.orange600),
              ),
            )
          else
            TextButton(
              onPressed: _saving ? null : _fetchLocation,
              child: Text(has ? 'Perbarui' : 'Coba lagi', style: QueueTextStyles.link),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QueueColors.neutral0,
      appBar: AppBar(
        backgroundColor: QueueColors.neutral0,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QueueColors.neutral900),
          onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _isEdit ? 'Edit Kebutuhan' : 'Tambah Kebutuhan',
          style: QueueTextStyles.appBarTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const QueueFieldLabel('Jenis Barang'),
                TextFormField(
                  controller: _barangCtrl,
                  style: QueueTextStyles.input,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: queueInputDecoration(hint: 'Contoh: Beras'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Jenis barang wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const QueueFieldLabel('Jumlah'),
                          TextFormField(
                            controller: _jumlahCtrl,
                            style: QueueTextStyles.input,
                            keyboardType: TextInputType.number,
                            decoration: queueInputDecoration(hint: '0'),
                            validator: (v) {
                              final n = int.tryParse((v ?? '').trim());
                              if (n == null) return 'Isi angka';
                              if (n <= 0) return 'Harus > 0';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const QueueFieldLabel('Satuan'),
                          DropdownButtonFormField<String>(
                            initialValue: _satuan,
                            isExpanded: true,
                            style: QueueTextStyles.input,
                            dropdownColor: QueueColors.neutral0,
                            decoration: queueInputDecoration(),
                            items: QueueItem.satuanOptions
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) => setState(() => _satuan = v ?? _satuan),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const QueueFieldLabel('Tingkat Urgensi'),
                DropdownButtonFormField<String>(
                  initialValue: _urgensi,
                  isExpanded: true,
                  style: QueueTextStyles.input,
                  dropdownColor: QueueColors.neutral0,
                  decoration: queueInputDecoration(),
                  items: QueueItem.urgensiOptions
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _urgensi = v ?? _urgensi),
                ),
                const SizedBox(height: 16),
                const QueueFieldLabel('Keterangan Tambahan (opsional)'),
                TextFormField(
                  controller: _ketCtrl,
                  style: QueueTextStyles.input,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: queueInputDecoration(hint: 'Contoh: untuk 20 keluarga'),
                ),
                const SizedBox(height: 16),
                const QueueFieldLabel('Lokasi Posko'),
                _locationCard(),
                const SizedBox(height: 28),
                QueueButton(
                  label: 'Simpan Data',
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
                if (_isEdit) ...[
                  const SizedBox(height: 8),
                  QueueButton(
                    label: 'Hapus Data',
                    variant: QueueButtonVariant.text,
                    color: QueueColors.error,
                    onPressed: _saving ? null : _delete,
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