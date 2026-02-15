import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'admin_bottom_navigation_bar.dart';
import 'user_bottom_navigation_bar.dart';

/// 🔹 Custom AppBar - شريط علوي مخصص لجميع شاشات التطبيق
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<String>? categories;
  final ValueChanged<String>? onCategorySelected;
  final VoidCallback? onProfilePressed;
  final bool showProfileIcon;
  final List<Widget>? customActions;
  final Widget? leadingWidget;
  final bool? isAdmin;
  final int? profileTabIndex;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.categories,
    this.onCategorySelected,
    this.onProfilePressed,
    this.showProfileIcon = true,
    this.customActions,
    this.leadingWidget,
    this.isAdmin,
    this.profileTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bool adminMode = isAdmin ??
        ModalRoute.of(context)?.settings.name?.startsWith('/admin') ??
        context.findAncestorWidgetOfExactType<AdminMainScreen>() != null;

    return AppBar(
      backgroundColor: scheme.surface,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
      ),
      actions: [
        if (customActions != null) ...customActions!,
        if (showProfileIcon) _buildProfileIcon(context, adminMode),
      ],
    );
  }

  /// 🖼️ بناء أيقونة البروفايل مع منطق الضغط
  Widget _buildProfileIcon(BuildContext context, bool adminMode) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: IconButton(
        icon: CircleAvatar(
          radius: 18,
          backgroundColor: scheme.secondary,
          child: Icon(
            adminMode ? Icons.people : Icons.person,
            color: scheme.onSecondary,
            size: 20,
          ),
        ),
        onPressed: onProfilePressed ?? () => _handleProfilePress(context, adminMode),
      ),
    );
  }

  /// 👤 معالجة ضغط أيقونة البروفايل
  void _handleProfilePress(BuildContext context, bool adminMode) {
    if (adminMode) {
      _handleAdminProfilePress(context);
    } else {
      _handleUserProfilePress(context);
    }
  }

  /// 👑 معالجة ضغط البروفايل في وضع الأدمن
  void _handleAdminProfilePress(BuildContext context) {
    // محاولة العثور على حالة AdminMainScreen
    final adminState = context.findAncestorStateOfType<AdminMainScreenState>();
    
    if (adminState != null && profileTabIndex != null) {
      // ✅ تغيير التبويب في الشريط السفلي
      adminState.onTabTapped(profileTabIndex!);
    } else {
      // 🔄 Fallback: التنقل إلى صفحة البروفايل
      Navigator.pushNamed(context, '/admin/profile');
    }
  }

  /// 👤 معالجة ضغط البروفايل في وضع المستخدم العادي
  void _handleUserProfilePress(BuildContext context) {
    // محاولة العثور على حالة MainScreen
    final userState = context.findAncestorStateOfType<MainScreenState>();
    
    if (userState != null && profileTabIndex != null) {
      // ✅ تغيير التبويب في الشريط السفلي
      userState.changeTab(profileTabIndex!);
    } else {
      // 🔄 Fallback: التنقل إلى صفحة البروفايل
      Navigator.pushNamed(context, '/profile');
    }
  }

  /// 🏗️ بناء الجزء الأيسر من الـ AppBar
  Widget? _buildLeading(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // 1️⃣ الأولوية: leadingWidget المخصص
    if (leadingWidget != null) {
      return leadingWidget;
    }

    // 2️⃣ فلترة: إذا في categories
    if (categories != null && categories!.isNotEmpty) {
      return PopupMenuButton<String>(
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
            ...categories!.map(
              (cat) => PopupMenuItem<String>(
                value: cat,
                child: Text('${cat}_title'.tr()),
              ),
            ),
          ];
        },
      );
    }

    // 3️⃣ رجوع: إذا showBackButton = true
    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        color: scheme.onSurface,
        onPressed: () => Navigator.pop(context),
      );
    }

    // 4️⃣ لا شيء
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}