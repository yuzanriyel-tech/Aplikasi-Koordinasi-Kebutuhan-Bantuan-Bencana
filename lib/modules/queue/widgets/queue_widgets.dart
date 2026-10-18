import 'package:flutter/material.dart';

import '../theme/queue_theme.dart';

OutlineInputBorder _border(Color c, {double width = 1}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: width),
    );

/// Input minimalis: latar abu muda tanpa garis, oranye saat fokus.
InputDecoration queueInputDecoration({String? hint}) => InputDecoration(
      hintText: hint,
      hintStyle: QueueTextStyles.hint,
      filled: true,
      fillColor: QueueColors.neutral100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _border(Colors.transparent),
      enabledBorder: _border(Colors.transparent),
      focusedBorder: _border(QueueColors.orange600, width: 1.5),
      errorBorder: _border(QueueColors.error),
      focusedErrorBorder: _border(QueueColors.error, width: 1.5),
      errorStyle: const TextStyle(fontSize: 12, color: QueueColors.error),
    );

class QueueFieldLabel extends StatelessWidget {
  final String text;
  const QueueFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: QueueTextStyles.label),
      );
}

enum QueueButtonVariant { filled, text }

class QueueButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final QueueButtonVariant variant;
  final Color color;

  const QueueButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.variant = QueueButtonVariant.filled,
    this.color = QueueColors.orange500,
  });

  @override
  Widget build(BuildContext context) {
    final isText = variant == QueueButtonVariant.text;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isText ? color : QueueColors.neutral0,
            ),
          )
        : Text(
            label,
            style: QueueTextStyles.buttonLabel.copyWith(
              color: isText ? color : QueueColors.neutral0,
            ),
          );
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: isText
          ? TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(shape: shape, foregroundColor: color),
              child: child,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                disabledBackgroundColor: color.withValues(alpha: 0.6),
                shape: shape,
                elevation: 0,
              ),
              child: child,
            ),
    );
  }
}

Dialog _dialogShell({required List<Widget> children}) => Dialog(
      backgroundColor: QueueColors.neutral0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );

/// Pop-up sukses: centang hijau, "Berhasil!", tombol OK.
Future<void> showQueueSuccessDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _dialogShell(
      children: [
        const Icon(Icons.check_circle_rounded, size: 56, color: QueueColors.success),
        const SizedBox(height: 12),
        const Text('Berhasil!', style: QueueTextStyles.dialogTitle),
        const SizedBox(height: 4),
        Text(message, textAlign: TextAlign.center, style: QueueTextStyles.dialogMessage),
        const SizedBox(height: 20),
        QueueButton(label: 'OK', onPressed: () => Navigator.pop(ctx)),
      ],
    ),
  );
}

/// Dialog konfirmasi (untuk hapus). Mengembalikan true bila dikonfirmasi.
Future<bool> showQueueConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _dialogShell(
      children: [
        const Icon(Icons.delete_outline_rounded, size: 48, color: QueueColors.error),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: QueueTextStyles.dialogTitle),
        const SizedBox(height: 4),
        Text(message, textAlign: TextAlign.center, style: QueueTextStyles.dialogMessage),
        const SizedBox(height: 20),
        QueueButton(
          label: confirmLabel,
          color: QueueColors.error,
          onPressed: () => Navigator.pop(ctx, true),
        ),
        const SizedBox(height: 4),
        QueueButton(
          label: 'Batal',
          variant: QueueButtonVariant.text,
          color: QueueColors.neutral500,
          onPressed: () => Navigator.pop(ctx, false),
        ),
      ],
    ),
  );
  return result ?? false;
}