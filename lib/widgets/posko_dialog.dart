import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Dialog seragam untuk pesan error dan konfirmasi
/// (halaman Error Message dan Information di Figma).
/// Mengembalikan true bila tombol konfirmasi ditekan, false bila batal.
Future<bool?> showPoskoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'OK',
  String? cancelLabel,
  bool isError = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: AppColors.overlay,
    builder: (context) => Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: const BorderSide(color: AppColors.olive),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1.5, color: AppColors.amber),
            const SizedBox(height: 28),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: cancelLabel == null
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (cancelLabel != null)
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    child: Text(cancelLabel, style: const TextStyle(fontSize: 16)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: AppColors.amber),
                  child: Text(confirmLabel, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
