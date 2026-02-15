import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
export 'settings_tile.dart';
export 'user_bottom_navigation_bar.dart';
export 'admin_bottom_navigation_bar.dart';
export 'custom_app_bar.dart';


/// 🔹 Main Button
class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final Color? backgroundColor;
  final Color? textColor;

  const MainButton({
    required this.text,
    required this.onPressed,
    this.width = 250,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? scheme.primary,
          foregroundColor: textColor ?? scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

/// 🔹 Social Icon
class SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SocialIcon({required this.icon, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: color,
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

/// 🔹 Map Chip
class MapChip extends StatelessWidget {
  final String title;
  const MapChip({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.onPrimary.withValues(alpha: 0.2)),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
      ),
    );
  }
}

/// 🔹 Map Marker
class MapMarker extends StatelessWidget {
  final String label;
  const MapMarker({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.onPrimary.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
      ),
    );
  }
}

/// 🔹 Custom Search Bar
class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final TextEditingController? controller;

  const CustomSearchBar({
    super.key,
    this.onChanged,
    this.hintText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: hintText ?? 'search_hint'.tr(),
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(Icons.search, color: scheme.primary),
          filled: true,
          fillColor: scheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: scheme.outline, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: scheme.outlineVariant, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

