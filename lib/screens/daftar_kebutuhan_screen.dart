import 'package:flutter/material.dart';

import '../data/kebutuhan_repository.dart';
import '../models/kebutuhan_bantuan.dart';
import '../widgets/state_views.dart';

// status tampilan: loading, berhasil, atau gagal
enum ViewStatus { loading, success, error }

class DaftarKebutuhanScreen extends StatefulWidget {
  const DaftarKebutuhanScreen({super.key});

  @override
  State<DaftarKebutuhanScreen> createState() => _DaftarKebutuhanScreenState();
}

class _DaftarKebutuhanScreenState extends State<DaftarKebutuhanScreen> {
  final _repository = KebutuhanRepository();
  ViewStatus _status = ViewStatus.loading;
  List<KebutuhanBantuan> _items = [];
  String _errorMessage = '';
  final bool _simulateError = false; // ubah ke true untuk menguji tampilan error

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
      final items = await _repository.fetchKebutuhan(simulateError: _simulateError);
      if (!mounted) return;
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
      appBar: AppBar(title: const Text('Daftar Kebutuhan Bantuan')),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(message: 'Memuat data kebutuhan...'),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return const EmptyView(message: 'Belum ada kebutuhan bantuan yang tercatat.');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(item.jenis),
            subtitle: Text('${item.jumlah} • Urgensi: ${item.urgensi} • ${item.status}'),
            trailing: const Icon(Icons.chevron_right),
            // sementara kosong dulu, diisi di Langkah selanjutnya (buka Detail)
            onTap: () {},
          ),
        );
      },
    );
  }
}