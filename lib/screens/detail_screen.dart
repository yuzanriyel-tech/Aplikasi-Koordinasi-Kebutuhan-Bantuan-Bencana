import 'package:flutter/material.dart';

import '../models/kebutuhan_bantuan.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DetailScreen extends StatefulWidget {
  final KebutuhanBantuan kebutuhan;

  const DetailScreen({
    super.key,
    required this.kebutuhan,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Menyimpan catatan berdasarkan ID kebutuhan.
  // Jadi catatan tidak hilang ketika DetailScreen dibuat ulang.
  static final Map<String, String> _catatanTersimpan = {};

  String? get _catatan {
    return _catatanTersimpan[widget.kebutuhan.id];
  }

  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );

    if (!mounted) return;

    // Kalau kembali tanpa menyimpan,
    // catatan lama tetap dipertahankan.
    if (hasil == null || hasil.trim().isEmpty) {
      return;
    }

    setState(() {
      _catatanTersimpan[widget.kebutuhan.id] = hasil.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan berhasil disimpan'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kebutuhan = widget.kebutuhan;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text(
          'Detail Kebutuhan',
          style: AppTextStyles.button,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detail Kebutuhan Bantuan',
                textAlign: TextAlign.center,
                style: AppTextStyles.pageTitle,
              ),

              const SizedBox(height: 28),

              _detailItem(
                label: 'ID Kebutuhan',
                value: kebutuhan.id,
              ),

              _detailItem(
                label: 'Jenis Kebutuhan',
                value: kebutuhan.jenisKebutuhan,
              ),

              _detailItem(
                label: 'Jumlah',
                value: kebutuhan.jumlah.toString(),
              ),

              _detailItem(
                label: 'Tingkat Urgensi',
                value: kebutuhan.urgensi,
              ),

              const SizedBox(height: 20),

              if (kebutuhan.foto != null)
                _detailItem(
                  label: 'Foto',
                  value: kebutuhan.foto!,
                ),

              const Divider(height: 32),

              Text(
                _catatan == null
                    ? 'Belum ada catatan.'
                    : 'Catatan: $_catatan',
              ),

              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: _bukaFormCatatan,
                icon: const Icon(Icons.edit_note),
                label: const Text('Tulis Catatan'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 22,
        color: AppColors.primary,
      ),
    );
  }

  Widget _detailItem({
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.primary,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.fieldLabel,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}