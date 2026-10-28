import 'package:flutter/material.dart';

import '../models/kebutuhan.dart';

/// Warna template UI PoSync (diambil dari desain Figma Modul A).
class PosyncColors {
  PosyncColors._();

  static const Color primary = Color(0xFFEB6442); // tombol, FAB, chip aktif
  static const Color primarySoft = Color(0xFFF7C1B3); // latar ikon kamera
  static const Color iconBox = Color(0xFFF9D1C7); // latar ikon barang
  static const Color iconMerah = Color(0xFFEC221F); // ikon barang
  static const Color cardBorder = Color(0xFFF39E89); // garis kartu
  static const Color navPill = Color(0xFFFFDAC6); // menu bawah yang aktif
  static const Color navLabel = Color(0xFF6B6A2F); // teks menu bawah
  static const Color background = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF16352B);
  static const Color textMuted = Color(0xFF8A9A95);
  static const Color border = Color(0xFFE2E6E4);
  static const Color dashed = Color(0xFFBCCFC3);
  static const Color danger = Color(0xFFDB1212);

  // urgensi & status
  static const Color tinggiBg = Color(0xFFFEC9C9);
  static const Color tinggiText = Color(0xFFBE3232);
  static const Color sedangBg = Color(0xFFF3E8BC);
  static const Color sedangText = Color(0xFF8A6D00);
  static const Color rendahBg = Color(0xFFDAF3C7);
  static const Color rendahText = Color(0xFF4C9A14);
  static const Color terkirimText = Color(0xFF5E8F86);
}

/// Warna chip sesuai tingkat urgensi.
extension UrgensiWarna on Urgensi {
  Color get latar => switch (this) {
        Urgensi.tinggi => PosyncColors.tinggiBg,
        Urgensi.sedang => PosyncColors.sedangBg,
        Urgensi.rendah => PosyncColors.rendahBg,
      };

  Color get teks => switch (this) {
        Urgensi.tinggi => PosyncColors.tinggiText,
        Urgensi.sedang => PosyncColors.sedangText,
        Urgensi.rendah => PosyncColors.rendahText,
      };
}

/// Warna teks sesuai status sinkronisasi.
extension StatusWarna on StatusSinkron {
  Color get teks => switch (this) {
        StatusSinkron.terkirim => PosyncColors.terkirimText,
        StatusSinkron.pending => PosyncColors.sedangText,
        StatusSinkron.gagal => PosyncColors.danger,
      };
}
