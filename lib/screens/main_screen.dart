import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final void Function(bool) onThemeChanged;

  const MainScreen({super.key, required this.onThemeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomeScreen(),
      const MapScreen(),
      ProfileScreen(onThemeChanged: widget.onThemeChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]  // نفس لون الخلفية في الوضع الداكن
          : Colors.grey[100], // نفس لون الخلفية في الوضع الفاتح
      selectedItemColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.orange
          : scheme.primary,
      unselectedItemColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[500]
          : scheme.onSurface.withOpacity(0.6),
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.map_outlined),
          label: 'map'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          label: 'profile'.tr(),
        ),
      ],
    ),
    );
  }
}
