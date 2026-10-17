import 'package:flutter/material.dart';

import '../models/kebutuhan.dart';
import '../screens/daftar_kebutuhan_screen.dart';
import '../screens/form_kebutuhan_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String daftar = '/';
  static const String form = '/form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case daftar:
        return MaterialPageRoute<void>(
          builder: (_) => const DaftarKebutuhanScreen(),
          settings: settings,
        );
      case form:
        final args = settings.arguments;
        // args kosong = tambah baru; berisi Kebutuhan = edit data itu
        if (args == null || args is Kebutuhan) {
          // <HasilForm> karena layar ini mengembalikan hasil saat ditutup
          return MaterialPageRoute<HasilForm>(
            builder: (_) => FormKebutuhanScreen(data: args as Kebutuhan?),
            settings: settings,
          );
        }
        return null; // data salah -> halaman tidak ditemukan
      default:
        return null; // route tidak terdaftar -> halaman tidak ditemukan
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
        body: Center(child: Text('Route: ${settings.name}')),
      ),
      settings: settings,
    );
  }
}