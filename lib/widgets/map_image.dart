import 'package:flutter/material.dart';

class MapImage extends StatelessWidget {
  const MapImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/map_placeholder.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF1E2D52),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 40, color: Color(0xFF8FA3C7)),
            SizedBox(height: 8),
            Text(
              'Peta belum tersedia',
              style: TextStyle(color: Color(0xFF8FA3C7), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
