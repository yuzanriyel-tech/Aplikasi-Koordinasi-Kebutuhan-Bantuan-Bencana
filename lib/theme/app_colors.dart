import 'package:flutter/material.dart';

/// Palet warna PoskoSync, diambil dari prototype Figma
/// (Requirement List / Input / Edit) lalu dipakai di semua halaman.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFFEB6442);
  static const primaryTint = Color(0xFFFFDAC6);
  static const accent = Color(0xFF2F9C53);
  static const amber = Color(0xFFFA9500);

  // Surface & teks
  static const surface = Color(0xFFFFFFFF);
  static const mutedSurface = Color(0xFFF5F7F4);
  static const ink = Color(0xFF16352B);
  static const text = Color(0xFF17251F);
  static const hint = Color(0xFF6A6E6D);
  static const placeholder = hint;
  static const caption = Color(0xFF838383);
  static const muted = Color(0xFF73827B);
  static const optional = Color(0xFFA0A8A4);

  // Garis & border
  static const border = Color(0xFFDEE7E1);
  static const borderStrong = Color(0xFFB8C2BE);
  static const olive = Color(0xFF7C6A0A);
  static const oliveSoft = Color(0xFFADA458);
  static const dashed = Color(0xFFA6BFAF);
  static const overlay = Color(0xCC49454F);
  static const danger = Color(0xFFDB1212);

  // Indikator urgensi (Tinggi / Sedang / Rendah)
  static const urgencyHighBg = Color(0x38FA0909);
  static const urgencyHighFg = Color(0xFFA90000);
  static const urgencyHighBorder = Color(0xFFE02D2D);
  static const urgencyHighFill = Color(0xFFFFC7C7);

  static const urgencyMidBg = Color(0x4DD4B01F);
  static const urgencyMidFg = Color(0xFF8A6D00);
  static const urgencyMidBorder = Color(0xFFD4B01F);
  static const urgencyMidFill = Color(0xFFFFF1B8);

  static const urgencyLowBg = Color(0x3856C600);
  static const urgencyLowFg = Color(0xFF3F8A00);
  static const urgencyLowBorder = Color(0xFF56C600);
  static const urgencyLowFill = Color(0xFFD9F5C2);

  // Indikator status sinkronisasi
  static const syncPending = Color(0xFFE98C5A);
  static const syncPendingText = Color(0xFFC2622F);
  static const syncSent = Color(0xFF6E9A92);

  // Indikator status koneksi (Online / Offline / Menunggu sinkronisasi)
  static const onlineBg = Color(0xFFE3F4E8);
  static const onlineFg = Color(0xFF1F7A3E);
  static const offlineBg = Color(0xFFFFE4D6);
  static const offlineFg = Color(0xFF9A3412);
  static const waitingBg = Color(0xFFFFF1B8);
  static const waitingFg = Color(0xFF8A6D00);
}
