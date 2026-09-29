import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const brand = TextStyle(fontFamily: 'monospace', fontSize: 44, height: 1.2, color: AppColors.surface);
  static const fieldLabel = TextStyle(fontFamily: 'monospace', fontSize: 20, height: 1.25, color: AppColors.placeholder);
  static const button = TextStyle(fontFamily: 'monospace', fontSize: 20, height: 1.25, color: AppColors.surface);
  static const pageTitle = TextStyle(fontFamily: 'monospace', fontSize: 22, height: 1.25, color: AppColors.primary);
}