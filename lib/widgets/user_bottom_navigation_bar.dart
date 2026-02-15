import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/map_screen.dart';
import '../screens/user/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final void Function(bool) onThemeChanged;

  const MainScreen({super.key, required this.onThemeChanged});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late final List<Widget> pages;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    pages = [
      HomeScreen(
        onProfilePressed: () => changeTab(2), // ✅ الذهاب للبروفايل
      ),
      MapScreen(
        onProfilePressed: () => changeTab(2), // ✅ الذهاب للبروفايل
      ),
      ProfileScreen(
        onThemeChanged: widget.onThemeChanged,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
        selectedItemColor: isDark ? Colors.orange : scheme.primary,
        unselectedItemColor:
            isDark ? Colors.grey[500] : scheme.onSurface.withOpacity(0.6),
        currentIndex: currentIndex,
        onTap: (index) {
          changeTab(index); // ✅ استخدام الدالة نفسها
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
