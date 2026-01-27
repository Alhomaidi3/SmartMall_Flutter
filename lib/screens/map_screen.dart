import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(title: 'smart_mall_guide'.tr()),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/map.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  /// 📍 Store Markers
                  Positioned(
                      top: 260,
                      left: 70,
                      child: MapMarker(label: 'store_bata'.tr())),
                  Positioned(
                      bottom: 200,
                      left: 140,
                      child: MapMarker(label: 'store_nike'.tr())),
                  Positioned(
                      bottom: 240,
                      right: 70,
                      child: MapMarker(label: 'store_stylo'.tr())),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: CustomSearchBar(),
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  MapChip(title: 'category_clothing'.tr()),
                  MapChip(title: 'category_shoes'.tr()),
                  MapChip(title: 'category_perfumes'.tr()),
                  MapChip(title: 'category_electronics'.tr()),
                  MapChip(title: 'category_accessories'.tr()),
                ],
              ),
            ),
          ),
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
