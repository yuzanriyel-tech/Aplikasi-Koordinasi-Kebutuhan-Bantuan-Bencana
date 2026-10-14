import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';
import '../state/app_state.dart';
import '../widgets/need_card.dart';
import '../widgets/posko_app_bar.dart';
import '../widgets/posko_bottom_nav.dart';
import '../widgets/posko_dialog.dart';
import '../widgets/state_view.dart';
import '../widgets/status_widgets.dart';

/// Halaman Antrean (Synchronize): status koneksi + data yang menunggu dikirim.
/// Hapus data memakai dialog konfirmasi (Information Page).
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Item item) async {
    final confirmed = await showPoskoDialog(
      context,
      title: 'Pemberitahuan',
      message: 'Kebutuhan ini akan dihapus, Anda yakin?',
      confirmLabel: 'Ya',
      cancelLabel: 'Batal',
    );
    if (confirmed != true || !context.mounted) return;
    ItemRepository.instance.remove(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kebutuhan dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PoskoAppBar(title: 'Antrean'),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([ItemRepository.instance, AppState.instance]),
          builder: (context, _) {
            final pending = ItemRepository.instance.pendingItems;
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              children: [
                const ConnectionBanner(),
                const SizedBox(height: 16),
                if (pending.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: EmptyView(
                      message: 'Tidak ada data yang menunggu dikirim.',
                      icon: Icons.cloud_done_outlined,
                    ),
                  )
                else
                  for (final item in pending)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NeedCard(
                        item: item,
                        showMeta: true,
                        onEdit: () => Navigator.pushNamed(
                          context,
                          AppRoutes.requirementEdit,
                          arguments: item,
                        ),
                        onDelete: () => _confirmDelete(context, item),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const PoskoBottomNav(currentIndex: 1),
    );
  }
}
