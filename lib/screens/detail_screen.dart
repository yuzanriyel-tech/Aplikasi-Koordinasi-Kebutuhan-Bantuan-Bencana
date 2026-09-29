import 'package:flutter/material.dart';
import '../models/kebutuhan_bantuan.dart';
import '../routes/app_routes.dart';

class DetailScreen extends StatefulWidget {
  final KebutuhanBantuan item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _catatan;

  Future<void> _bukaFormCatatan() async {
    final hasil = await Navigator.pushNamed<String>(
      context,
      AppRoutes.catatanForm,
    );
    if (!mounted || hasil == null) return;
    
    setState(() => _catatan = hasil);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan update berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    
    return Scaffold(
      appBar: AppBar(title: Text(item.jenis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Detail Kebutuhan', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Jumlah: ${item.jumlah}'),
          Text('Tingkat Urgensi: ${item.urgensi}'),
          const SizedBox(height: 16),
          Text('Status: ${item.status}'),
          const Divider(height: 32),
          Text(
            _catatan == null ? 'Belum ada catatan update.' : 'Update Terkini: $_catatan',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _bukaFormCatatan,
            icon: const Icon(Icons.edit_note),
            label: const Text('Tulis Update Lapangan'),
          ),
        ],
      ),
    );
  }
}