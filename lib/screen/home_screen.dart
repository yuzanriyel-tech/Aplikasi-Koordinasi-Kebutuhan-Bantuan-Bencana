import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/posko_widgets.dart';
import '../widgets/state_views.dart';

// status tampilan layar yang memuat data
enum ViewStatus { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = ItemRepository();
  ViewStatus _status = ViewStatus.loading;
  List<Item> _items = [];
  String _errorMessage = '';
  // ubah ke true (hapus "final") hanya untuk menguji error state
  final bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final items = await _repository.fetchItems(simulateError: _simulateError);
      if (!mounted) return; // layar sudah ditutup -> berhenti
      setState(() {
        _items = items;
        _status = ViewStatus.success;
      });
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('PoskoSync', style: AppTextStyles.button),
        actions: const [Padding(padding: EdgeInsets.only(right: 20), child: ConnectionStatus())],
      ),
      body: SafeArea(child: _buildContent()),
      // Tombol menuju form input kebutuhan (belum disambungkan, di luar latihan ini)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Input Kebutuhan'),
      ),
      bottomNavigationBar: Container(height: 22, color: AppColors.primary),
    );
  }

  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(message: 'Memuat data...'),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(message: 'Belum ada data.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primary),
          ),
          child: ListTile(
            title: Text(item.title),
            subtitle: Text('${item.subtitle} • ${item.urgency}'),
            trailing: const Icon(Icons.chevron_right),
            // kirim item yang dipilih ke layar Detail
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.detail,
              arguments: item,
            ),
          ),
        );
      },
    );
  }
}
