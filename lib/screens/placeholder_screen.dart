import 'package:flutter/material.dart';

import '../widgets/posko_app_bar.dart';
import '../widgets/posko_bottom_nav.dart';
import '../widgets/posko_widgets.dart';
import '../widgets/state_view.dart';

/// Halaman sementara untuk tab yang modulnya belum dikerjakan
/// (Riwayat = Modul D, Distribusi = Modul E).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.navIndex,
    required this.icon,
  });

  final String title;
  final int navIndex;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PoskoAppBar(title: title, actions: const [ConnectionStatus()]),
      body: SafeArea(
        child: EmptyView(
          message: 'Halaman $title akan tersedia pada modul berikutnya.',
          icon: icon,
        ),
      ),
      bottomNavigationBar: PoskoBottomNav(currentIndex: navIndex),
    );
  }
}
