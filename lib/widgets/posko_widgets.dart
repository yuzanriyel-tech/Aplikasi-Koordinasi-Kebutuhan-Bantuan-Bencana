import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PoskoLogo extends StatelessWidget {
  const PoskoLogo({super.key, this.showName = true});
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
          child: const Icon(Icons.health_and_safety_outlined, size: 44, color: AppColors.surface),
        ),
        if (showName) ...[
          const SizedBox(height: 12),
          const Text('PoskoSync', style: AppTextStyles.brand),
        ],
      ],
    );
  }
}

class PoskoTextField extends StatelessWidget {
  const PoskoTextField({required this.controller, required this.hintText, super.key, this.obscureText = false, this.keyboardType, this.validator});
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textAlign: TextAlign.center,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.fieldLabel,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
        errorStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class PoskoPrimaryButton extends StatelessWidget {
  const PoskoPrimaryButton({required this.label, required this.onPressed, super.key});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.surface, shape: const StadiumBorder()),
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }
}

class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: AppColors.mutedSurface, borderRadius: BorderRadius.circular(18)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_done_outlined, size: 16, color: AppColors.accent),
          SizedBox(width: 6),
          Text('Online', style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.primary)),
        ],
      ),
    );
  }
}