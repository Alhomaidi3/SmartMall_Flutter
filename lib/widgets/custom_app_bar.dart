import 'package:flutter/material.dart';
import 'admin_bottom_navigation_bar.dart';
import 'user_bottom_navigation_bar.dart';

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

  void _handleProfilePress(BuildContext context, bool adminMode) {
    if (adminMode) {
      _handleAdminProfilePress(context);
    } else {
      _handleUserProfilePress(context);
    }
  }

  void _handleAdminProfilePress(BuildContext context) {
    final adminState = context.findAncestorStateOfType<AdminMainScreenState>();
    
    if (adminState != null && profileTabIndex != null) {
      adminState.onTabTapped(profileTabIndex!);
    } else {
      Navigator.pushNamed(context, '/admin/profile');
    }
  }

  void _handleUserProfilePress(BuildContext context) {
    final userState = context.findAncestorStateOfType<MainScreenState>();
    
    if (userState != null && profileTabIndex != null) {
      userState.changeTab(profileTabIndex!);
    } else {
      Navigator.pushNamed(context, '/profile');
    }
  }

  Widget? _buildLeading(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (leadingWidget != null) {
      return leadingWidget;
    }

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
            const PopupMenuItem<String>(
              value: '',
              child: Text('all_categories'),
            ),
            ...categories!.map(
              (cat) => PopupMenuItem<String>(
                value: cat,
                child: Text('${cat}_title'),
              ),
            ),
          ];
        },
      );
    }

    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        color: scheme.onSurface,
        onPressed: () => Navigator.pop(context),
      );
    }

    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}