
import 'package:flutter/material.dart';
import '../models/laporan_bantuan.dart';
import 'detail_laporan_screen.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  final List<LaporanBantuan> laporan;
  final ValueChanged<LaporanBantuan> onUpdate;
  final ValueChanged<String> onDelete;

  const RiwayatLaporanScreen({
    super.key,
    required this.laporan,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<RiwayatLaporanScreen> createState() =>
      _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState
    extends State<RiwayatLaporanScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTanggal(DateTime date) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');

    return '${date.day} ${bulan[date.month - 1]} '
        '${date.year}, $jam:$menit';
  }

  Color _warnaPrioritas(String prioritas) {
    switch (prioritas.toLowerCase()) {
      case 'tinggi':
        return const Color(0xFFFFE5E1);
      case 'sedang':
        return const Color(0xFFFFF0C2);
      default:
        return const Color(0xFFE2F4E7);
    }
  }

  Color _warnaTeksPrioritas(String prioritas) {
    switch (prioritas.toLowerCase()) {
      case 'tinggi':
        return const Color(0xFFC62828);
      case 'sedang':
        return const Color(0xFF946200);
      default:
        return const Color(0xFF267344);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasil = widget.laporan.where((item) {
      final query = _query.toLowerCase();

      return item.namaKebutuhan.toLowerCase().contains(query) ||
          item.keterangan.toLowerCase().contains(query) ||
          item.dibuatOleh.toLowerCase().contains(query);
    }).toList()
      ..sort(
        (a, b) => b.terakhirDiperbarui.compareTo(
          a.terakhirDiperbarui,
        ),
      );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Laporan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          children: [
            const Text(
              'Daftar laporan kebutuhan bantuan yang telah dibuat '
              'atau disinkronkan.',
              style: TextStyle(
                color: Color(0xFF77716C),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Search laporan
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _query = value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Cari nama kebutuhan atau keterangan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Total laporan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFF0E4),
                    Color(0xFFFFE4CE),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFFE86B18),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total laporan',
                        style: TextStyle(
                          color: Color(0xFF7B6D62),
                        ),
                      ),
                      Text(
                        '${widget.laporan.length} laporan',
                        style: const TextStyle(
                          color: Color(0xFFC6530A),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            if (hasil.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 52,
                      color: Color(0xFFB9B0A8),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Laporan tidak ditemukan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coba kata kunci lain.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ...hasil.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        final messenger =
                            ScaffoldMessenger.of(context);

                        final dihapus = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailLaporanScreen(
                              laporan: item,
                              onUpdate: widget.onUpdate,
                              onDelete: widget.onDelete,
                            ),
                          ),
                        );

                        if (!mounted) return;

                        setState(() {});

                        if (dihapus == true) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Laporan berhasil dihapus.',
                              ),
                              backgroundColor: Color(0xFF25834B),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFF0E9E3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEFE3),
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: Color(0xFFE86B18),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.namaKebutuhan,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _warnaPrioritas(
                                            item.prioritas,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          'Prioritas ${item.prioritas.toLowerCase()}',
                                          style: TextStyle(
                                            color: _warnaTeksPrioritas(
                                              item.prioritas,
                                            ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF938A82),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Jumlah: ${item.jumlah}',
                              style: const TextStyle(
                                color: Color(0xFF5F5A55),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.keterangan,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF77716C),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 17,
                                  color: Color(0xFFE86B18),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.latitude == null ||
                                            item.longitude == null
                                        ? 'Koordinat belum tersedia'
                                        : '${item.latitude!.toStringAsFixed(4)}, '
                                            '${item.longitude!.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                      color: Color(0xFF77716C),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTanggal(
                                    item.terakhirDiperbarui,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF8B837C),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dibuat oleh ${item.dibuatOleh}',
                              style: const TextStyle(
                                color: Color(0xFF9A9188),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Lihat detail →',
                                style: TextStyle(
                                  color: Color(0xFFC6530A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
