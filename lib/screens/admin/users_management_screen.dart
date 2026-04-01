import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import 'user_form_screen.dart';

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
  String searchQuery = '';
  String selectedRole = 'all';
  final TextEditingController searchController = TextEditingController();
  String selectedStatus = 'all'; 


    final List<FilterChipData> allFilters = [
  // Role Filters
  const FilterChipData(value: 'all', labelKey: 'all_users', icon: Icons.people_outline),
  const FilterChipData(value: 'admin', labelKey: 'admin', icon: Icons.admin_panel_settings),
  const FilterChipData(value: 'user', labelKey: 'user', icon: Icons.person_outline),

  // Status Filters
  const FilterChipData(value: 'active', labelKey: 'active', icon: Icons.check_circle_outline, selectedColor: Colors.green),
  const FilterChipData(value: 'inactive', labelKey: 'inactive', icon: Icons.remove_circle_outline, selectedColor: Colors.red),
];

  List<User> _users = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  List<User> _searchResults = [];
  bool _isSearching = false;
  
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUsers();
    });
  }
  
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers({bool refresh = false}) async {
    if (!_hasMore && !refresh) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      if (mounted) setState(() => _isLoading = true);
    } else if (_currentPage == 1) {
      if (mounted) setState(() => _isLoading = true);
    }
    
    try {
      final users = await _userService.getUsers();
      
      if (!mounted) return;
      
      setState(() {
        if (refresh || _currentPage == 1) {
          _users = users;
        } else {
          _users.addAll(users);
        }
        _hasMore = false;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

Future<void> _searchUsers(String query) async {
  if (query.isEmpty) {
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
    await _fetchUsers(refresh: true);
    return;
  }
  
  setState(() {
    _isSearching = true;
    _isLoading = true;
  });
  
  try {
    // جلب جميع المستخدمين مرة واحدة فقط
    final allUsers = await _userService.getUsers();
    
    // تصفية محلية حسب الاسم أو الإيميل أو الهاتف
    final results = allUsers.where((user) {
      final fullName = user.fullName.toLowerCase();
      final email = user.email.toLowerCase();
      final phone = user.phone.toLowerCase();
      final searchLower = query.toLowerCase();
      
      return fullName.contains(searchLower) ||
             email.contains(searchLower) ||
             phone.contains(searchLower);
    }).toList();

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isLoading = false);
      showMessage(context, e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
    }
  }
}
List<User> get filteredUsers {
  final sourceList = _isSearching ? _searchResults : _users;

  return sourceList.where((user) {
    if (selectedRole != 'all') {
      final roleMatches = selectedRole == 'admin' ? user.isAdmin : !user.isAdmin;
      if (!roleMatches) return false;
    }
    
    if (selectedStatus == 'active' && !user.isActive) return false;
    if (selectedStatus == 'inactive' && user.isActive) return false;
    
    return true;
  }).toList();
}
  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_user'.tr()),
        content: Text('delete_user_confirmation'.tr()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      
      try {
        await _userService.deleteUser(user.id);
        await _fetchUsers(refresh: true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('user_deleted'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

Future<bool> _confirmLogout() async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('confirmation'.tr()),
      content: Text(
        'logout_confirmation'.tr(),
        style: TextStyle(color: textColor),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
          // Search Bar
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
          
          // Stats Row with Add Button
          UnifiedStatsRow(
            icon: Icons.people,
            title: 'total_users'.tr(),
            count: filteredUsers.length,
            onAddPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserFormScreen(),
                ),
              );
              if (result == true) {
                _fetchUsers(refresh: true);
              }
            },
            addButtonText: 'add_user'.tr(),
          ),

          // Scrollable Content
Expanded(
      child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), 
child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest, 
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips
            FilterChipsRow(
              filters: allFilters,
              selectedRole: selectedRole,
              selectedStatus: selectedStatus,
              onSingleSelected: (value) {
                setState(() {
                  if (['all', 'user', 'admin'].contains(value)) {
                    selectedRole = value;
                    if (value == 'all') selectedStatus = 'all';
                  } else {
                    selectedStatus = value;
                  }
                  _fetchUsers(refresh: true);
                });
              },
            ),

            // Users List
            UnifiedLoadingState(
              isLoading: _isLoading && _users.isEmpty,
              isEmpty: filteredUsers.isEmpty,
              emptyIcon: 'user',
              emptyTitle: 'no_users_found'.tr(),
              emptySubtitle: 'try_adjusting_search'.tr(),
              child: RefreshIndicator(
                onRefresh: () => _fetchUsers(refresh: true),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // ListView لن يتجاوز
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(context, user);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)),          
          // Logout Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: UnifiedFormButton(
            onPressed: () async {
              final confirmed = await _confirmLogout();
              if (confirmed) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
              },
              text: 'logout'.tr(),
              isOutlined: true,
              isDestructive: false,
              icon: Icons.logout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    
    // بناء معلومات إضافية للبطاقة
    final additionalInfo = [
      Row(
        children: [
          Icon(Icons.phone_outlined, size: 14, 
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 4),
          Text(user.phone,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12)),
        ],
      ),
    ];

    return UnifiedCard(
      type: CardType.user,
      data: user,
      title: user.fullName,
      subtitle: user.email,
      isActive: user.isActive,
      statusLabel: null,
      onEdit: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserFormScreen(user: user),
          ),
        );
        if (result == true) {
          _fetchUsers(refresh: true);
        }
      },
      onDelete: () => _deleteUser(user),
      additionalInfo: additionalInfo,
    );
  }
}