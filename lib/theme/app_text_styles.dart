import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const brand = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.surface,
    shadows: [Shadow(offset: Offset(0, 4), color: Color(0x66000000))],
  );
  static const pageTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink);
  static const sectionTitle = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.text);
  static const fieldLabel = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black);
  static const input = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black);
  static const hint = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.hint);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.surface);
  static const body = TextStyle(fontSize: 15, color: AppColors.text);
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.caption);
  static const chip = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  static const cardTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3F4A45));
  static const cardQuantity = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6B7570));
  static const navLabel = TextStyle(fontSize: 12, color: AppColors.olive);
}
