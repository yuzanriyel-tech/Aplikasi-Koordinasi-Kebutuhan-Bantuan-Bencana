import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../models/posko_location.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/validators.dart';
import '../widgets/map_image.dart';
import '../widgets/posko_app_bar.dart';
import '../widgets/posko_dialog.dart';
import '../widgets/posko_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _poskoController = TextEditingController();

  // Titik awal dianggap hasil deteksi GPS (sementara memakai titik contoh).
  PoskoLocation _location = PoskoLocation.fallback;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _poskoController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.pushNamed<PoskoLocation>(
      context,
      AppRoutes.map,
      arguments: _location,
    );
    if (result != null && mounted) setState(() => _location = result);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (AuthRepository.instance.isRegistered(_phoneController.text)) {
      await showPoskoDialog(
        context,
        title: 'Error',
        message: 'Nomor telepon sudah terdaftar.',
      );
      return;
    }

    AuthRepository.instance.register(
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      poskoName: _poskoController.text,
      location: _location,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Akun berhasil dibuat. Silakan masuk.')),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PoskoAppBar(title: 'Daftar', showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            20,
            AppDimens.screenPadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(AppDimens.panelRadius),
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PoskoTextField(
                        controller: _nameController,
                        label: 'Nama Penanggung Jawab',
                        textInputAction: TextInputAction.next,
                        validator: (value) => Validators.minLength(
                          value,
                          3,
                          fieldName: 'Nama penanggung jawab',
                        ),
                      ),
                      const SizedBox(height: 16),
                      PoskoTextField(
                        controller: _phoneController,
                        label: 'Nomor Telepon',
                        hintText: 'cth: 081234567890',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: PoskoTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: true,
                              validator: Validators.password,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PoskoTextField(
                              controller: _confirmController,
                              label: 'Ulangi Sandi',
                              obscureText: true,
                              validator: (value) => Validators.confirmPassword(
                                value,
                                _passwordController.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PoskoTextField(
                        controller: _poskoController,
                        label: 'Nama Posko',
                        textInputAction: TextInputAction.done,
                        validator: (value) => Validators.minLength(
                          value,
                          3,
                          fieldName: 'Nama posko',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const PoskoFieldLabel('Lokasi'),
                      const SizedBox(height: 8),
                      _LocationPreview(location: _location, onTap: _pickLocation),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PoskoPrimaryButton(label: 'Daftar', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationPreview extends StatelessWidget {
  const _LocationPreview({required this.location, required this.onTap});
  final PoskoLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: 'Atur titik lokasi posko',
          child: GestureDetector(
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const MapImage(),
                    const Align(
                      alignment: Alignment(0, -0.15),
                      child: Icon(Icons.location_on, size: 44, color: AppColors.amber),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_location_alt_outlined, size: 16, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Atur titik',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          location.label,
          style: const TextStyle(fontSize: 13, color: AppColors.text),
        ),
      ],
    );
  }
}
