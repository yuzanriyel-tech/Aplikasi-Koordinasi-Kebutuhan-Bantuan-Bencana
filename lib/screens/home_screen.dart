import 'package:flutter/material.dart';

import '../models/kebutuhan_bantuan.dart';
import '../repositories/kebutuhan_repository.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';
import '../widgets/posko_widgets.dart';
import '../widgets/state_views.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();

  // Repository untuk mengambil data dummy.
  final KebutuhanRepository _repository = KebutuhanRepository();

  // State data Home.
  List<KebutuhanBantuan> _kebutuhan = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Digunakan untuk menguji error state.
  bool get _simulateError => false;

  String? _urgency;
  bool _hasPhoto = false;

  @override
  void initState() {
    super.initState();

    // Load data ketika Home pertama kali dibuka.
    _loadKebutuhan();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Mengambil data dengan loading, error, dan finally.
  Future<void> _loadKebutuhan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_simulateError) {
        throw Exception('Simulasi error saat mengambil data.');
      }

      final data = await _repository.getKebutuhan();

      if (!mounted) return;

      setState(() {
        _kebutuhan = data;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal memuat data kebutuhan.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _submitNeed() {
    if (!(_formKey.currentState?.validate() ?? false) ||
        _urgency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi tingkat urgensi kebutuhan.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kebutuhan disimpan untuk dikirim ke server.'),
      ),
    );

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
        title: const Text(
          'PoskoSync',
          style: AppTextStyles.button,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: ConnectionStatus(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth > 500
                ? 460.0
                : constraints.maxWidth - 40;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                28,
                20,
                36,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: contentWidth,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Input Kebutuhan Bantuan',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.pageTitle,
                        ),

                        const SizedBox(height: 28),

                        _fieldLabel('Jenis Kebutuhan'),

                        PoskoTextField(
                          controller: _typeController,
                          hintText: 'Contoh: Air mineral',
                          validator: validateRequired,
                        ),

                        const SizedBox(height: 20),

                        _fieldLabel('Jumlah'),

                        PoskoTextField(
                          controller: _quantityController,
                          hintText: 'Masukkan jumlah',
                          keyboardType: TextInputType.number,
                          validator: validateRequired,
                        ),

                        const SizedBox(height: 20),

                        _fieldLabel('Tingkat Urgensi'),

                        DropdownButtonFormField<String>(
                          initialValue: _urgency,
                          isExpanded: true,
                          decoration: _dropdownDecoration(),
                          hint: const Text(
                            'Pilih tingkat urgensi',
                            style: AppTextStyles.fieldLabel,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Tinggi',
                              child: Text('Tinggi'),
                            ),
                            DropdownMenuItem(
                              value: 'Sedang',
                              child: Text('Sedang'),
                            ),
                            DropdownMenuItem(
                              value: 'Rendah',
                              child: Text('Rendah'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _urgency = value;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        _fieldLabel('Foto'),

                        _PhotoPicker(
                          hasPhoto: _hasPhoto,
                          onPressed: () {
                            setState(() {
                              _hasPhoto = !_hasPhoto;
                            });
                          },
                        ),

                        const SizedBox(height: 30),

                        Align(
                          alignment: Alignment.center,
                          child: PoskoPrimaryButton(
                            label: 'Kirim',
                            onPressed: _submitNeed,
                          ),
                        ),

                        const SizedBox(height: 36),

                        const Text(
                          'Data Kebutuhan Bantuan',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.pageTitle,
                        ),

                        const SizedBox(height: 20),

                        _buildKebutuhanState(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        height: 22,
        color: AppColors.primary,
      ),
    );
  }

  // Menentukan tampilan berdasarkan state data.
  Widget _buildKebutuhanState() {
    // Loading state.
    if (_isLoading) {
      return const LoadingView();
    }

    // Error state.
    if (_errorMessage != null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: _loadKebutuhan,
      );
    }

    // Empty state.
    if (_kebutuhan.isEmpty) {
      return const EmptyView(
        message: 'Belum ada data kebutuhan bantuan.',
      );
    }

    // Data state.
    return Column(
      children: _kebutuhan.map(_buildKebutuhanCard).toList(),
    );
  }

  // Menampilkan satu data kebutuhan.
  // Card dapat ditekan untuk membuka Detail.
  Widget _buildKebutuhanCard(
    KebutuhanBantuan kebutuhan,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.detail,
            arguments: kebutuhan,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kebutuhan.jenisKebutuhan,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Jumlah: ${kebutuhan.jumlah}',
              ),

              Text(
                'Urgensi: ${kebutuhan.urgensi}',
              ),

              Text(
                'ID: ${kebutuhan.id}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.fieldLabel,
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: AppColors.primary,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.hasPhoto,
    required this.onPressed,
  });

  final bool hasPhoto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasPhoto
                  ? Icons.check_circle_outline
                  : Icons.add_a_photo_outlined,
              size: 34,
              color: AppColors.accent,
            ),

            const SizedBox(height: 8),

            Text(
              hasPhoto
                  ? 'Foto siap dilampirkan'
                  : 'Ambil atau pilih foto',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}