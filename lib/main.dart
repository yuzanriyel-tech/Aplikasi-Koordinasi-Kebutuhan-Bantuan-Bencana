import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'theme/posync_colors.dart';

void main() {
  runApp(const PoskoSyncApp());
}

class PoskoSyncApp extends StatelessWidget {
  const PoskoSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoskoSync - Modul A',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: PosyncColors.primary),
        scaffoldBackgroundColor: PosyncColors.background,
      ),
      initialRoute: AppRoutes.daftar,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
      // Bingkai layar HP supaya tampil seperti di HP saat dibuka di Chrome.
      // Hapus baris "builder" ini kalau mau layar penuh.
      builder: (context, child) => _BingkaiHp(child: child ?? const SizedBox.shrink()),
    );
  }
}

class _BingkaiHp extends StatelessWidget {
  final Widget child;
  const _BingkaiHp({required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEAF0FA),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double tinggi = constraints.maxHeight - 32;
          if (tinggi > 800) tinggi = 800;
          if (tinggi < 400) tinggi = 400;
          return Center(
            child: Container(
              width: 380,
              height: tinggi,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: PosyncColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PosyncColors.border),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
