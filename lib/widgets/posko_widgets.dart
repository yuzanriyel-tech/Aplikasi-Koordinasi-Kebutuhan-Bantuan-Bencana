import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// bila file belum ada, tampil logo pengganti agar aplikasi tetap jalan.
class PoskoLogo extends StatelessWidget {
  const PoskoLogo({super.key, this.size = 180, this.showName = true});
  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size / 9),
            child: Image.asset(
              'assets/images/logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _LogoFallback(size: size),
            ),
          ),
        
        ],
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Icon(Icons.festival, size: size * 0.8, color: AppColors.primary),
    );
  }
}

/// Label di atas field, dengan penanda "(opsional)" bila perlu.
class PoskoFieldLabel extends StatelessWidget {
  const PoskoFieldLabel(this.label, {super.key, this.optional = false});
  final String label;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: AppTextStyles.fieldLabel,
        children: [
          if (optional)
            const TextSpan(
              text: ' (opsional)',
              style: TextStyle(color: AppColors.optional),
            ),
        ],
      ),
    );
  }
}

InputDecoration poskoInputDecoration({String? hintText}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.hint,
    filled: true,
    fillColor: AppColors.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    constraints: const BoxConstraints(minHeight: AppDimens.fieldHeight),
    border: border(AppColors.border),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.primary, 1.5),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.5),
    errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
  );
}

/// Field teks seragam: label di atas, kotak 48 dp, sudut 12 dp.
class PoskoTextField extends StatelessWidget {
  const PoskoTextField({
    required this.controller,
    required this.label,
    super.key,
    this.hintText,
    this.optional = false,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool optional;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final lines = obscureText ? 1 : maxLines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoskoFieldLabel(label, optional: optional),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          minLines: lines,
          maxLines: lines,
          textInputAction: textInputAction,
          style: AppTextStyles.input,
          decoration: poskoInputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}

/// Tombol utama seragam: tinggi 56 dp, sudut 12 dp, lebar penuh.
class PoskoPrimaryButton extends StatelessWidget {
  const PoskoPrimaryButton({required this.label, required this.onPressed, super.key});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          ),
        ),
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }
}

/// Indikator status koneksi (Online / Offline / Menunggu sinkronisasi).
/// Tekan lama untuk mengganti Online/Offline saat simulasi.
class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        final style = connectionStyle(AppState.instance.mode);
        return GestureDetector(
          onLongPress: AppState.instance.toggleOnline,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(style.icon, size: 16, color: style.foreground),
                const SizedBox(width: 6),
                Text(
                  style.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: style.foreground,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Warna, ikon, dan teks untuk tiap status koneksi.
({Color background, Color foreground, IconData icon, String label})
    connectionStyle(ConnectionMode mode) {
  switch (mode) {
    case ConnectionMode.online:
      return (
        background: AppColors.onlineBg,
        foreground: AppColors.onlineFg,
        icon: Icons.cloud_done_outlined,
        label: 'Online',
      );
    case ConnectionMode.offline:
      return (
        background: AppColors.offlineBg,
        foreground: AppColors.offlineFg,
        icon: Icons.wifi_off,
        label: 'Offline',
      );
    case ConnectionMode.waitingSync:
      return (
        background: AppColors.waitingBg,
        foreground: AppColors.waitingFg,
        icon: Icons.sync,
        label: 'Menunggu sinkronisasi',
      );
  }
}
