import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'posko_widgets.dart';

/// Chip urgensi: Tinggi (merah), Sedang (kuning), Rendah (hijau).
class UrgencyChip extends StatelessWidget {
  const UrgencyChip(this.urgency, {super.key});
  final Urgency urgency;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (urgency) {
      Urgency.tinggi => (AppColors.urgencyHighBg, AppColors.urgencyHighFg),
      Urgency.sedang => (AppColors.urgencyMidBg, AppColors.urgencyMidFg),
      Urgency.rendah => (AppColors.urgencyLowBg, AppColors.urgencyLowFg),
    };
    return Container(
      height: AppDimens.chipHeight,
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.chipRadius),
      ),
      child: Text(urgency.label, style: AppTextStyles.chip.copyWith(color: fg)),
    );
  }
}

/// Status sinkronisasi data: Menunggu / Terkirim.
/// [pill] true -> chip berisi (dipakai di halaman Antrean dan Detail),
/// false -> teks kecil dengan titik (dipakai di daftar kebutuhan).
class SyncBadge extends StatelessWidget {
  const SyncBadge(this.status, {super.key, this.pill = false});
  final SyncStatus status;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final isPending = status == SyncStatus.pending;
    if (pill) {
      return Container(
        height: AppDimens.chipHeight,
        constraints: const BoxConstraints(minWidth: 64),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPending ? AppColors.syncPending : AppColors.syncSent,
          borderRadius: BorderRadius.circular(AppDimens.chipRadius),
        ),
        child: Text(
          status.label,
          style: AppTextStyles.chip.copyWith(color: AppColors.surface),
        ),
      );
    }
    return Text(
      '· ${status.label}',
      style: AppTextStyles.chip.copyWith(
        fontWeight: FontWeight.w700,
        color: isPending ? AppColors.syncPendingText : AppColors.syncSent,
      ),
    );
  }
}

/// Kartu status koneksi + jumlah data yang menunggu dikirim.
/// Tampil di halaman Antrean dan Beranda (NFR-07).
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AppState.instance, ItemRepository.instance]),
      builder: (context, _) {
        final mode = AppState.instance.mode;
        final pending = AppState.instance.pendingCount;
        final style = connectionStyle(mode);
        final (title, subtitle) = switch (mode) {
          ConnectionMode.offline => (
              'Sedang Offline',
              pending == 0
                  ? 'Semua data tersimpan di perangkat'
                  : '$pending data menunggu dikirim',
            ),
          ConnectionMode.waitingSync => (
              'Menunggu sinkronisasi',
              'Mengirim $pending data ke server...',
            ),
          ConnectionMode.online => (
              'Online',
              pending == 0
                  ? 'Semua data sudah terkirim'
                  : '$pending data menunggu dikirim',
            ),
        };
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(AppDimens.panelRadius),
          ),
          child: Row(
            children: [
              Icon(style.icon, size: 40, color: style.foreground),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: style.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
