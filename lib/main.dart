import 'package:flutter/material.dart';

import 'screens/daftar_penyaluran_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const PoskoSyncApp());

class PoskoSyncApp extends StatelessWidget {
  const PoskoSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoskoSync - Modul E',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const DaftarPenyaluranScreen(),
    );
  }
}
