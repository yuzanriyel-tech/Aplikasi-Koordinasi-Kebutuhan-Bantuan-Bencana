import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../theme/app_colors.dart';
import '../utils/view_status.dart';
import '../widgets/posko_bottom_nav.dart';
import '../widgets/posko_widgets.dart';
import '../widgets/state_view.dart';
import '../widgets/status_widgets.dart';

/// Beranda: logo, indikator memuat, lalu ringkasan kebutuhan dan status koneksi.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // (1) variabel state
  final _repository = ItemRepository();
  ViewStatus _status = ViewStatus.loading;
  String _errorMessage = '';
  final bool _simulateError = false; // ubah ke true untuk menguji error state

  // (2) ambil data saat layar pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // (3) mengambil data + menangani error
  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      await _repository.fetchItems(simulateError: _simulateError);
      if (!mounted) return;
      setState(() => _status = ViewStatus.success);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ConnectionStatus(),
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: const PoskoBottomNav(currentIndex: 2),
    );
  }

  // (4) memilih tampilan: loading / error / ringkasan
  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PoskoLogo(),
              SizedBox(height: 40),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: AppColors.amber,
                  backgroundColor: AppColors.primaryTint,
                ),
              ),
            ],
          ),
        ),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildSummary(),
    };
  }

  Widget _buildSummary() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PoskoLogo(size: 140),
            const SizedBox(height: 28),
            ListenableBuilder(
              listenable: _repository,
              builder: (context, _) => Row(
                children: [
                  _StatTile(label: 'Kebutuhan', value: _repository.items.length),
                  const SizedBox(width: 12),
                  _StatTile(label: 'Menunggu', value: _repository.pendingCount),
                  const SizedBox(width: 12),
                  _StatTile(label: 'Terkirim', value: _repository.sentCount),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const ConnectionBanner(),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}
