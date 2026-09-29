import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/posko_widgets.dart';
import '../routes/app_routes.dart';

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
  final isValid = _formKey.currentState?.validate() ?? false;

  if (!isValid) return;

  Navigator.pushReplacementNamed(
    context,
    AppRoutes.home,
  );
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
                    PoskoTextField(
                      controller: _usernameController,
                      hintText: 'Username',
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 36),
                    PoskoTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    validator: validatePassword,
                  ),
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
}