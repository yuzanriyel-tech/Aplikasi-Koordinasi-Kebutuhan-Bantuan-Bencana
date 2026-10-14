import 'dart:async';

import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/posko_widgets.dart';

/// Halaman pembuka: logo, indikator memuat, lalu otomatis ke Login.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            const PoskoLogo(),
            const SizedBox(height: 40),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: AppColors.amber,
                backgroundColor: AppColors.primaryTint,
              ),
            ),
            const Spacer(flex: 3),
            const Text('PoskoSync', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            const Text(
              'Pusat Informasi Kebutuhan Bencana',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
