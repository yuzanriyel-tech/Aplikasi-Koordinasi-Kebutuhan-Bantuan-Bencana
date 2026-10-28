import 'package:flutter/material.dart';
import '../models/laporan_bantuan.dart';
import 'edit_keterangan_screen.dart';

class DetailLaporanScreen extends StatefulWidget {
  final LaporanBantuan laporan;
  final ValueChanged<LaporanBantuan> onUpdate;
  final ValueChanged<String> onDelete;

  const DetailLaporanScreen({
    super.key,
    required this.laporan,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  late LaporanBantuan _laporan = widget.laporan;

  String _tanggal(DateTime date) {
    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} $jam:$menit';
  }

  Future<void> _hapusLaporan() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 36),
        title: const Text('Hapus laporan?'),
        content: const Text('Laporan ini akan dihapus dari riwayat dan tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true && mounted) {
      widget.onDelete(_laporan.id);
      Navigator.pop(context, true);
    }
  }

  Future<void> _editKeterangan() async {
    final hasil = await Navigator.push<LaporanBantuan>(
      context,
      MaterialPageRoute(
        builder: (_) => EditKeteranganScreen(laporan: _laporan),
      ),
    );
    if (hasil != null && mounted) {
      setState(() => _laporan = hasil);
      widget.onUpdate(hasil);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keterangan dan lokasi berhasil diperbarui.'),
          backgroundColor: Color(0xFF25834B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final koordinat = _laporan.latitude == null || _laporan.longitude == null
        ? 'Koordinat belum tersedia'
        : '${_laporan.latitude!.toStringAsFixed(6)}, ${_laporan.longitude!.toStringAsFixed(6)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE7D3), Color(0xFFFFF6EC)],
                ),
              ),
              child: const Center(
                child: Icon(Icons.inventory_2_outlined, size: 72, color: Color(0xFFE86B18)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Text(_laporan.namaKebutuhan, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFFFE5E1), borderRadius: BorderRadius.circular(30)),
                  child: Text('Prioritas ${_laporan.prioritas.toLowerCase()}', style: const TextStyle(color: Color(0xFFC62828), fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoRow(label: 'Jumlah kebutuhan', value: _laporan.jumlah),
            const SizedBox(height: 18),
            const Text('Keterangan tambahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE7E0DA))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_laporan.keterangan, style: const TextStyle(height: 1.5, fontSize: 14)),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _editKeterangan,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Keterangan'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Lokasi laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE7E0DA))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFFE86B18)),
                      SizedBox(width: 8),
                      Text('Koordinat GPS', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(koordinat, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 6),
                  Text('Terakhir diperbarui: ${_tanggal(_laporan.terakhirDiperbarui)}', style: const TextStyle(color: Color(0xFF817870), fontSize: 12)),
                  const SizedBox(height: 12),
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFFFFF0E4), borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined, size: 30, color: Color(0xFFE86B18)),
                          SizedBox(height: 4),
                          Text('Pratinjau peta tidak tersedia pada prototipe', style: TextStyle(fontSize: 11, color: Color(0xFF8C6B53))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Informasi laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _InfoRow(label: 'ID laporan', value: _laporan.id),
            _InfoRow(label: 'Tanggal dibuat', value: _tanggal(_laporan.tanggalDibuat)),
            _InfoRow(label: 'Dibuat oleh', value: _laporan.dibuatOleh),
            _InfoRow(label: 'Terakhir diperbarui', value: _tanggal(_laporan.terakhirDiperbarui)),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _hapusLaporan,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus Laporan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF817870)))),
          const SizedBox(width: 12),
          Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
