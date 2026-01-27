import 'package:flutter/material.dart';
import '/widgets/widgets.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,

      /// 🔝 AppBar
      appBar: const CustomAppBar(title: 'Smart Mall Guide'),

      /// 🗺 Map Body
      body: Stack(
        children: [
          /// Map + Markers داخل InteractiveViewer
          Positioned.fill(
            child: InteractiveViewer(
              panEnabled: true, // يسمح بالسحب
              minScale: 0.5,    // أقل نسبة تصغير
              maxScale: 4.0,    // أقصى نسبة تكبير
              child: Stack(
                children: [
                  /// Map Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/map.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  /// 📍 Store Markers (تتحرك مع الخريطة)
                  const Positioned(top: 260, left: 70, child: MapMarker(label: 'BATA')),
                  const Positioned(bottom: 200, left: 140, child: MapMarker(label: 'NIKE')),
                  const Positioned(bottom: 240, right: 70, child: MapMarker(label: 'STYLO')),
                ],
              ),
            ),
          ),

          /// 🔍 Search Bar (ثابت فوق الخريطة)
          const Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: CustomSearchBar(),
          ),

          /// 🏷 Categories (ثابتة فوق الخريطة)
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: const [
                  MapChip(title: 'Clothing'),
                  MapChip(title: 'Shoes'),
                  MapChip(title: 'Perfumes'),
                  MapChip(title: 'Electronics'),
                  MapChip(title: 'Accessories'),
                ],
              ),
            ),
          ),

          /// 🎯 Floating Buttons (ثابتة فوق الخريطة)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: scheme.primary,
                  onPressed: () {},
                  child: Icon(Icons.my_location, color: scheme.onPrimary),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: scheme.primary,
                  onPressed: () {},
                  child: Icon(Icons.layers, color: scheme.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
