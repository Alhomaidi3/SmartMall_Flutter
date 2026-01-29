import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/map_screen.dart';
import 'package:easy_localization/easy_localization.dart';

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
        color: scheme.primary.withValues(alpha: 0.6), // ✅ بدل withOpacity
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.onPrimary.withValues(alpha: 0.2)), // ✅ بدل withOpacity
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
        border: Border.all(color: scheme.onPrimary.withValues(alpha: 0.2)), // ✅ بدل withOpacity
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

/// 🔹 Custom AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<String>? categories;
  final ValueChanged<String>? onCategorySelected;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.categories,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: scheme.surface,
      elevation: 0,
      centerTitle: true,

      // 🔹 زر الفئات أو السهم في أقصى يسار (leading)
      leading: (categories != null && categories!.isNotEmpty)
          ? PopupMenuButton<String>(
              icon: Icon(Icons.filter_list, color: scheme.onSurface),
              onSelected: (value) {
                if (onCategorySelected != null) {
                  onCategorySelected!(value);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: '',
                    child: Text('all_categories'.tr()),
                  ),
                  ...categories!.map((cat) => PopupMenuItem<String>(
                        value: cat,
                        child: Text('${cat}_title'.tr()), // ✅ مترجم
                      )),
                ];
              },
            )
          : showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: scheme.onSurface,
                  onPressed: () => Navigator.pop(context),
                )
              : null,

      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
      ),

      // 🔹 الصورة الصغيرة في أقصى يمين
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: scheme.secondary,
              child: Icon(Icons.person, color: scheme.onSecondary, size: 20),
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


/// 🔹 Custom Search Bar
class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged; // دالة البحث
  final String? hintText;
  final TextEditingController? controller; // ✅ أضفنا الـ controller

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
        controller: controller, // ✅ ربط الـ controller
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
/// 🔹 Custom Bottom Navigation Bar
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MapScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
