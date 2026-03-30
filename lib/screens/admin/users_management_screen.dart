import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';

class UsersManagementScreen extends StatefulWidget {
  final void Function(bool)? onThemeChanged;

  const UsersManagementScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  String selectedRole = 'all';
  List<String> selectedStatuses = [];
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await _userService.getUsers();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('🔹 Error fetching users: $e');
      showMessage(context, 'Failed to load users: $e', type: MessageType.error);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      await _fetchUsers();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final users = await _userService.searchUsers(query);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      showMessage(context, e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
      setState(() => _isLoading = false);
    }
  }

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
  List<User> get filteredUsers {
    return _users.where((user) {
      final searchLower = searchQuery.toLowerCase();
      final matchesSearch = user.fullName.toLowerCase().contains(searchLower) ||
          user.email.toLowerCase().contains(searchLower);

      final matchesRole = selectedRole == 'all' ||
          user.role.toLowerCase() == selectedRole.toLowerCase();

      final matchesStatus = selectedStatuses.isEmpty ||
          (selectedStatuses.contains('active') && user.isActive) ||
          (selectedStatuses.contains('inactive') && !user.isActive);

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

Future<void> _toggleUserStatus(User user) async {
  final action = user.isActive ? 'disable' : 'enable';
  final confirmed = await _confirmAction(
    title: action == 'disable' ? 'disable_user'.tr() : 'enable_user'.tr(),
    message: action == 'disable'
        ? 'disable_user_confirmation'.tr().replaceAll('%s', user.fullName)
        : 'enable_user_confirmation'.tr().replaceAll('%s', user.fullName),
  );

  if (confirmed) {
    try {
      await _userService.toggleUserStatus(user.id, !user.isActive);
      await _fetchUsers();

      showMessage(
        context,
        user.isActive ? 'user_disabled'.tr() : 'user_enabled'.tr(),
        type: MessageType.success,
      );
    } catch (e) {
      showMessage(
        context,
        e.toString().replaceAll('Exception: ', ''),
        type: MessageType.error,
      );
    }
  }
}
  Future<void> _deleteUser(User user) async {
  final confirmed = await _confirmAction(
    title: 'delete_user'.tr(),
    message: 'delete_user_confirmation'.tr().replaceAll('%s', user.fullName),
  );

  if (confirmed) {
    try {
      await _userService.deleteUser(user.id);
      await _fetchUsers();
      showMessage(context, 'user_deleted'.tr(), type: MessageType.success);
    } catch (e) {
      showMessage(context, e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
    }
  }
}
  Future<bool> _confirmAction({
    required String title,
    required String message,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title.tr()),
        content: Text(
          message.tr(),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    return result ?? false;
  }

Future<void> _toggleUserRole(User user) async {
  final newRole = user.isAdmin ? 'user' : 'admin';
  final message = 'change_role_confirmation'.tr()
      .replaceFirst('%s', user.fullName)
      .replaceFirst('%s', newRole);
  
  final confirmed = await _confirmAction(
    title: 'change_role'.tr(),
    message: message,
  );

  if (confirmed) {
    try {
      await _userService.changeUserRole(user.id, newRole);
      await _fetchUsers();
      showMessage(context, 'role_updated'.tr(), type: MessageType.success);
    } catch (e) {
      showMessage(context, e.toString(), type: MessageType.error);
    }
  }
}
  Future<bool> _confirmLogout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirmation'.tr()),
        content: Text(
          'logout_confirmation'.tr(),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('logout'.tr()),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Widget _buildFilterChip(
    String value,
    String label,
    IconData icon, {
    bool isStatus = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    bool isSelected;
    if (isStatus) {
      isSelected = selectedStatuses.contains(value);
    } else {
      isSelected = selectedRole == value;
    }

    Color getIconColor() {
      if (!isSelected) return scheme.onSurface.withOpacity(0.5);
      if (isStatus) {
        if (value == 'active') return Colors.green;
        if (value == 'inactive') return Colors.red;
        return scheme.primary;
      }
      return scheme.primary;
    }

    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: getIconColor(),
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() {
        if (isStatus) {
          if (isSelected) {
            selectedStatuses.remove(value);
          } else {
            selectedStatuses.add(value);
          }
        } else {
          if (value == 'all') {
            selectedRole = 'all';
          } else {
            if (selectedRole == 'all') selectedRole = value;
            else if (selectedRole == value) selectedRole = 'all';
            else selectedRole = value;
          }
        }
      }),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[200],
      selectedColor: scheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? getIconColor() : scheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: getIconColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: isSelected
            ? BorderSide(color: getIconColor(), width: 1)
            : BorderSide.none,
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = user.isAdmin;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isAdmin
            ? Border.all(color: scheme.primary.withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isAdmin
                    ? LinearGradient(
                        colors: [scheme.primary, scheme.primary.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                child: Text(
                  user.fullName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      if (isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'admin'.tr(),
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      if (isAdmin) const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: user.isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.isActive ? 'active'.tr() : 'inactive'.tr(),
                          style: TextStyle(
                            color: user.isActive ? Colors.green : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Text(
                    user.email,
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 14, color: scheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(user.phone,
                          style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.7),
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: scheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        'joined'.tr().replaceAll('%s', _formatDate(user.createdAt)),
                        style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.5),
                            fontSize: 11),
                      ),
                    ],
                  ),              
                ],
              ),
            ),

            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.more_vert, color: scheme.onSurface, size: 18),
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'toggle_role':
                    await _toggleUserRole(user);
                    break;
                  case 'disable':
                    await _toggleUserStatus(user);
                    break;
                  case 'delete':
                    await _deleteUser(user);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle_role',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAdmin ? Icons.person_outline : Icons.admin_panel_settings,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(isAdmin ? 'make_user'.tr() : 'make_admin'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'disable',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                            user.isActive ? Icons.block_outlined : Icons.check_circle_outline,
                            color: Colors.orange,
                            size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(user.isActive ? 'disable'.tr() : 'enable'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text('delete'.tr()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: 'users_management'.tr(),
        showProfileIcon: false,
        customActions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: scheme.onSurface,
            ),
            onPressed: () {
              if (widget.onThemeChanged != null) {
                widget.onThemeChanged!(!isDark);
              }
            },
          ),
          PopupMenuButton<Locale>(
            icon: Icon(Icons.language, color: scheme.onSurface),
            onSelected: (locale) {
              context.setLocale(locale);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🇬🇧', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'English',
                      style: TextStyle(
                        fontWeight: context.locale.languageCode == 'en'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: context.locale.languageCode == 'en'
                            ? scheme.primary
                            : scheme.onSurface,
                      ),
                    ),
                    if (context.locale.languageCode == 'en')
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, color: scheme.primary, size: 16),
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: const Locale('ar'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🇸🇦', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'العربية',
                      style: TextStyle(
                        fontWeight: context.locale.languageCode == 'ar'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: context.locale.languageCode == 'ar'
                            ? scheme.primary
                            : scheme.onSurface,
                      ),
                    ),
                    if (context.locale.languageCode == 'ar')
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, color: scheme.primary, size: 16),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
        leadingWidget: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.notifications_outlined, color: scheme.primary),
            onPressed: () {},
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: searchController,
              onChanged: (value) {
                setState(() => searchQuery = value);
                _searchUsers(value);
              },
              hintText: 'search_users'.tr(),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('all', 'all_users'.tr(), Icons.people_outline),
                  const SizedBox(width: 8),
                  _buildFilterChip('user', 'regular_users'.tr(), Icons.person_outline),
                  const SizedBox(width: 8),
                  _buildFilterChip('admin', 'admins'.tr(), Icons.admin_panel_settings),
                  const SizedBox(width: 16),
                  _buildFilterChip('active', 'active'.tr(), Icons.check_circle_outline, isStatus: true),
                  const SizedBox(width: 8),
                  _buildFilterChip('inactive', 'inactive'.tr(), Icons.remove_circle_outline, isStatus: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people, color: scheme.primary, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'total_users'.tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${filteredUsers.length}',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: scheme.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.people_outline,
                                size: 60,
                                color: scheme.primary.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_users_found'.tr(),
                              style: textTheme.titleMedium?.copyWith(
                                color: scheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'try_adjusting_search'.tr(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return _buildUserCard(context, user);
                          },
                        ),
                      ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.orange.withOpacity(0.05),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final confirmed = await _confirmLogout();
                    if (confirmed) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.orange.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.orange, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'logout'.tr(),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}