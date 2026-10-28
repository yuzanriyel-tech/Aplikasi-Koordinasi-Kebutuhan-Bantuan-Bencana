import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';
import '../widgets/posko_dialog.dart';
import '../widgets/posko_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final success = AuthRepository.instance.login(
      _phoneController.text,
      _passwordController.text,
    );
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    await showPoskoDialog(
      context,
      title: 'Error',
      message: 'Nomor telepon atau password salah!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
          child: Column(
            children: [
              const PoskoLogo(size: 160),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                      const Text(
                        'Masuk',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 24),
                      PoskoTextField(
                        controller: _phoneController,
                        label: 'Nomor Telepon',
                        hintText: 'cth: 081234567890',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 16),
                      PoskoTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        validator: (value) =>
                            Validators.requiredField(value, fieldName: 'Password'),
                      ),
                      const SizedBox(height: 28),
                      PoskoPrimaryButton(label: 'Masuk', onPressed: _submit),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                child: const Text.rich(
                  TextSpan(
                    text: 'Posko belum terdaftar? ',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Daftarkan Posko',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
