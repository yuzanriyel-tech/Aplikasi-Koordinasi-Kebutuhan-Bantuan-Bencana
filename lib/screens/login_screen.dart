import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/posko_widgets.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 44),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 88),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PoskoLogo(),
                    const SizedBox(height: 88),
                    PoskoTextField(controller: _usernameController, hintText: 'Username', validator: _required),
                    const SizedBox(height: 36),
                    PoskoTextField(controller: _passwordController, hintText: 'Password', obscureText: true, validator: _required),
                    const SizedBox(height: 64),
                    PoskoPrimaryButton(label: 'Login', onPressed: _login),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
}