import 'package:flutter/material.dart';

/// Palet warna khusus Modul B: 3 oranye, 5 monokrom, 3 warna tanda.
abstract final class QueueColors {
  // ---- Oranye (3) ----
  /// Utama: tombol, banner offline, ikon.
  static const orange500 = Color(0xFFFF6442);

  /// Aksen: border fokus input, ikon lokasi, indikator loading.
  static const orange600 = Color(0xFFEC7700);

  /// Gelap: teks tautan (kontras lebih baik di atas putih).
  static const orange800 = Color(0xFFAF1705);

  // ---- Monokrom (5) ----
  /// Latar halaman dan teks di atas warna.
  static const neutral0 = Color(0xFFFFFFFF);

  /// Latar input dan kotak info.
  static const neutral100 = Color(0xFFF5F5F5);

  /// Garis tepi kartu.
  static const neutral200 = Color(0xFFE4E4E4);

  /// Teks sekunder dan hint.
  static const neutral500 = Color(0xFF8A8A8A);

  /// Teks utama.
  static const neutral900 = Color(0xFF1F1F1F);

  // ---- Tanda (3) ----
  static const success = Color(0xFF39AD00);
  static const warning = Color(0xFFF5B800);
  static const error = Color(0xFFD32F2F);
}

/// Gaya teks Modul B (memakai font bawaan tema aplikasi).
abstract final class QueueTextStyles {
  static const appBarTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: QueueColors.neutral900);
  static const label = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: QueueColors.neutral900);
  static const input = TextStyle(fontSize: 15, color: QueueColors.neutral900);
  static const hint = TextStyle(fontSize: 15, color: QueueColors.neutral500);
  static const helper = TextStyle(fontSize: 13, color: QueueColors.neutral900);
  static const helperMuted = TextStyle(fontSize: 13, color: QueueColors.neutral500);
  static const link = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: QueueColors.orange800);

  static const cardTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: QueueColors.neutral900);
  static const cardMeta = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: QueueColors.neutral500);
  static const badge = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: QueueColors.neutral900);

  static const bannerTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: QueueColors.neutral0);
  static const bannerSubtitle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: QueueColors.neutral0);

  static const buttonLabel = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: QueueColors.neutral0);
  static const dialogTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: QueueColors.neutral900);
  static const dialogMessage = TextStyle(fontSize: 14, color: QueueColors.neutral500);
}