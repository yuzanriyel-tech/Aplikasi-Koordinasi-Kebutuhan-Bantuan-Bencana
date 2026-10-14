import 'package:flutter/material.dart';

import '../models/posko_location.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../widgets/map_image.dart';
import '../widgets/posko_app_bar.dart';
import '../widgets/posko_widgets.dart';

/// Halaman Map: geser pin untuk menyesuaikan titik lokasi posko (FR-04).
/// Mengembalikan [PoskoLocation] lewat Navigator.pop saat menekan Lanjut.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initial = PoskoLocation.fallback});
  final PoskoLocation initial;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Posisi pin dalam pecahan lebar/tinggi peta (0..1). Titik awal = tengah.
  double _fx = 0.5;
  double _fy = 0.5;

  // Selisih derajat dari tepi ke tepi peta pada gambar contoh.
  static const double _span = 0.004;

  PoskoLocation get _location => PoskoLocation(
        widget.initial.latitude - (_fy - 0.5) * _span,
        widget.initial.longitude + (_fx - 0.5) * _span,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PoskoAppBar(title: 'Atur lokasi posko', showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Lokasi awal diambil dari GPS. Geser atau ketuk peta untuk menyesuaikan titik posko.',
                style: TextStyle(fontSize: 14, color: AppColors.text),
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, box) {
                    void move(Offset point) {
                      setState(() {
                        _fx = (point.dx / box.maxWidth).clamp(0.0, 1.0).toDouble();
                        _fy = (point.dy / box.maxHeight).clamp(0.0, 1.0).toDouble();
                      });
                    }

                    return GestureDetector(
                      onTapDown: (details) => move(details.localPosition),
                      onPanUpdate: (details) => move(details.localPosition),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const MapImage(),
                            Positioned(
                              left: _fx * box.maxWidth - 22,
                              top: _fy * box.maxHeight - 44,
                              child: const Icon(
                                Icons.location_on,
                                size: 44,
                                color: AppColors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(_location.label, style: const TextStyle(fontSize: 14, color: AppColors.text)),
              const Spacer(),
              PoskoPrimaryButton(
                label: 'Lanjut',
                onPressed: () => Navigator.pop(context, _location),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
