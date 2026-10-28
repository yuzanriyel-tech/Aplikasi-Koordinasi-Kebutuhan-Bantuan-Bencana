import 'dart:async';

import 'package:flutter/material.dart';

import '../data/queue_repository.dart';
import '../models/queue_item.dart';
import '../services/connectivity_service.dart';
import '../theme/queue_theme.dart';
import 'queue_form_screen.dart';

/// FR-12: daftar data yang sedang mengantre.
/// Ikon pensil membuka halaman edit/hapus (FR-13).
class QueueListScreen extends StatefulWidget {
  const QueueListScreen({super.key});

  @override
  State<QueueListScreen> createState() => _QueueListScreenState();
}

class _QueueListScreenState extends State<QueueListScreen> {
  final _repo = QueueRepository.instance;
  StreamSubscription<bool>? _connSub;
  List<QueueItem> _items = [];
  bool _loading = true;
  bool _online = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    ConnectivityService.isOnline().then((v) {
      if (mounted) setState(() => _online = v);
    }).catchError((_) {});
    _connSub = ConnectivityService.onChanged.listen((v) {
      if (mounted) setState(() => _online = v);
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repo.getPending();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat antrean.';
        _loading = false;
      });
    }
  }

  Future<void> _openForm({QueueItem? item}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => QueueFormScreen(item: item)),
    );
    if (changed == true) _load();
  }

  Widget _banner() {
    final offline = !_online;
    final String subtitle;
    if (_loading) {
      subtitle = 'Memuat data...';
    } else if (_items.isEmpty) {
      subtitle = 'Tidak ada data yang mengantre';
    } else if (offline) {
      subtitle = '${_items.length} data menunggu dikirim...';
    } else {
      subtitle = '${_items.length} data menunggu sinkronisasi...';
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: offline ? QueueColors.orange500 : QueueColors.success,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            offline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
            color: QueueColors.neutral0,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offline ? 'Sedang Offline' : 'Sedang Online',
                  style: QueueTextStyles.bannerTitle,
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: QueueTextStyles.bannerSubtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(QueueItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      decoration: BoxDecoration(
        color: QueueColors.neutral0,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: QueueColors.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: QueueColors.orange500.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: QueueColors.orange500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.jenisBarang,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: QueueTextStyles.cardTitle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${item.jumlah} ${item.satuan}', style: QueueTextStyles.cardMeta),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: QueueColors.warning.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Pending', style: QueueTextStyles.badge),
                    ),
                    const SizedBox(width: 8),
                    const Text('Menunggu...', style: QueueTextStyles.cardMeta),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined, color: QueueColors.neutral500),
            onPressed: () => _openForm(item: item),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: QueueColors.orange600));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: QueueTextStyles.dialogMessage),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _load,
              child: const Text('Coba lagi', style: QueueTextStyles.link),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: QueueColors.orange600,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Text(
                'Semua data sudah tersinkron.\nTekan "Tambah" untuk menambah data.',
                textAlign: TextAlign.center,
                style: QueueTextStyles.dialogMessage,
              ),
            )
          else
            ..._items.map(_card),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QueueColors.neutral0,
      appBar: AppBar(
        backgroundColor: QueueColors.neutral0,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QueueColors.neutral900),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Daftar Antrean', style: QueueTextStyles.appBarTitle),
      ),
      body: Column(
        children: [
          _banner(),
          Expanded(child: _content()),
        ],
      ),
      // Sementara: pintu masuk tambah data sampai form Modul A tersambung.
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: QueueColors.orange500,
        foregroundColor: QueueColors.neutral0,
        elevation: 2,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}