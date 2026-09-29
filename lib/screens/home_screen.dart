import 'package:flutter/material.dart';
import '../data/kebutuhan_repository.dart';
import '../models/kebutuhan_bantuan.dart';
import '../routes/app_routes.dart';
import '../widgets/state_views.dart';

enum ViewStatus { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = KebutuhanRepository();
  ViewStatus _status = ViewStatus.loading;
  List<KebutuhanBantuan> _kebutuhanList = [];
  String _errorMessage = '';
  final bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    _loadKebutuhan();
  }

  Future<void> _loadKebutuhan() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      final data = await _repository.fetchKebutuhan(simulateError: _simulateError);
      if (!mounted) return;
      setState(() {
        _kebutuhanList = data;
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
      appBar: AppBar(title: const Text('Daftar Kebutuhan Posko')),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadKebutuhan),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    if (_kebutuhanList.isEmpty) {
      return const EmptyView(message: 'Belum ada data kebutuhan.');
    }
    return ListView.builder(
      itemCount: _kebutuhanList.length,
      itemBuilder: (context, index) {
        
        // Baris ini yang akan mengenalkan 'item' ke aplikasi
        final item = _kebutuhanList[index];
        
        return ListTile(
          title: Text(item.jenis, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Jumlah: ${item.jumlah}\nUrgensi: ${item.urgensi} | Status: ${item.status}'),
          isThreeLine: true,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.detail,
            arguments: item,
          ),
        );
      },
    );
  }
}