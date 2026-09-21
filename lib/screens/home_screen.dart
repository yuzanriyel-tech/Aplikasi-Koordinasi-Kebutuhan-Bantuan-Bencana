import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/posko_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _urgency;
  bool _hasPhoto = false;

  @override
  void dispose() {
    _typeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submitNeed() {
    if (!(_formKey.currentState?.validate() ?? false) || _urgency == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi tingkat urgensi kebutuhan.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kebutuhan disimpan untuk dikirim ke server.')));
    _formKey.currentState?.reset();
    _typeController.clear();
    _quantityController.clear();
    setState(() {
      _urgency = null;
      _hasPhoto = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('PoskoSync', style: AppTextStyles.button),
        actions: const [Padding(padding: EdgeInsets.only(right: 20), child: ConnectionStatus())],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > 500 ? 460.0 : constraints.maxWidth - 40;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Input Kebutuhan Bantuan', textAlign: TextAlign.center, style: AppTextStyles.pageTitle),
                        const SizedBox(height: 28),
                        _fieldLabel('Jenis Kebutuhan'),
                        PoskoTextField(controller: _typeController, hintText: 'Contoh: Air mineral', validator: _required),
                        const SizedBox(height: 20),
                        _fieldLabel('Jumlah'),
                        PoskoTextField(controller: _quantityController, hintText: 'Masukkan jumlah', keyboardType: TextInputType.number, validator: _required),
                        const SizedBox(height: 20),
                        _fieldLabel('Tingkat Urgensi'),
                        DropdownButtonFormField<String>(
                          initialValue: _urgency,
                          isExpanded: true,
                          decoration: _dropdownDecoration(),
                          hint: const Text('Pilih tingkat urgensi', style: AppTextStyles.fieldLabel),
                          items: const [
                            DropdownMenuItem(value: 'Tinggi', child: Text('Tinggi')),
                            DropdownMenuItem(value: 'Sedang', child: Text('Sedang')),
                            DropdownMenuItem(value: 'Rendah', child: Text('Rendah')),
                          ],
                          onChanged: (value) => setState(() => _urgency = value),
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel('Foto'),
                        _PhotoPicker(hasPhoto: _hasPhoto, onPressed: () => setState(() => _hasPhoto = !_hasPhoto)),
                        const SizedBox(height: 30),
                        Align(alignment: Alignment.center, child: PoskoPrimaryButton(label: 'Kirim', onPressed: _submitNeed)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(height: 22, color: AppColors.primary),
    );
  }

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label, textAlign: TextAlign.center, style: AppTextStyles.fieldLabel),
      );

  InputDecoration _dropdownDecoration() => InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary)),
      );

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.hasPhoto, required this.onPressed});
  final bool hasPhoto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 150,
          decoration: BoxDecoration(border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(hasPhoto ? Icons.check_circle_outline : Icons.add_a_photo_outlined, size: 34, color: AppColors.accent),
              const SizedBox(height: 8),
              Text(hasPhoto ? 'Foto siap dilampirkan' : 'Ambil atau pilih foto', style: const TextStyle(fontFamily: 'monospace', color: AppColors.primary)),
            ],
          ),
        ),
      );
}