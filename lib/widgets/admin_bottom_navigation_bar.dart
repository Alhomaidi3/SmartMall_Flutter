import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/stores_management_screen.dart';
import '../screens/admin/categories_management_screen.dart';
import '../screens/admin/users_management_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final void Function(bool)? onThemeChanged; 

  const AdminMainScreen({
    super.key,
    this.onThemeChanged,  
  });

  @override
  State<AdminMainScreen> createState() => AdminMainScreenState();
}

class AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  void goToDashboard() => onTabTapped(0);
  void goToStores() => onTabTapped(1);
  void goToCategories() => onTabTapped(2);
  void goToUsers() => onTabTapped(3);

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
    AdminDashboardScreen(
      onNavigateToUsers: goToUsers,
      onNavigateToCategories: goToCategories,  
    ),
      StoresManagementScreen(),
      CategoriesManagementScreen(),
      UsersManagementScreen(
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
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,  
          selectedItemColor: scheme.primary,
          unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0,  
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined,
              ),
              label: 'dashboard'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 1 ? Icons.store : Icons.store_outlined,
              ),
              label: 'stores'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 2 ? Icons.category : Icons.category_outlined,
              ),
              label: 'categories'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == 3 ? Icons.people : Icons.people_outline,
              ),
              label: 'users'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}