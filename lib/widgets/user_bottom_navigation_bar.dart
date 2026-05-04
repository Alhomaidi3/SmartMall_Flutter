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
  int? _selectedStoreIdForMap;

  void changeTab(int index, {int? selectedStoreId}) {
    setState(() {
      currentIndex = index;
      if (selectedStoreId != null) {
        _selectedStoreIdForMap = selectedStoreId;
      }
    });
  }
  
  // ✅ دالة لاستقبال طلب الاتجاهات من HomeScreen
  void _handleDirectionsRequested(int storeId) {
    changeTab(1, selectedStoreId: storeId);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(
            onProfilePressed: () => changeTab(2),
            onDirectionsRequested: _handleDirectionsRequested, // ✅ تمرير المعالج
          ),
          MapScreen(
            key: ValueKey(_selectedStoreIdForMap), // ✅ لإعادة بناء الخريطة عند تغيير ID المتجر
            onProfilePressed: () => changeTab(2),
            selectedStoreId: _selectedStoreIdForMap,
          ),
          ProfileScreen(
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
        selectedItemColor: isDark ? Colors.orange : scheme.primary,
        unselectedItemColor:
            isDark ? Colors.grey[500] : scheme.onSurface.withOpacity(0.6),
        currentIndex: currentIndex,
        onTap: (index) {
          changeTab(index);
          if (index != 1) {
            // ✅ إعادة تعيين ID المتجر عند مغادرة الخريطة
            _selectedStoreIdForMap = null;
          }
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