import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/services/admin_service.dart';
import '/services/user_service.dart';
import '/services/store_service.dart';
import 'analytics_screen.dart';
import '/models/user.dart';  
import 'store_form_screen.dart';
import 'category_form_screen.dart';


class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToUsers;
  final VoidCallback? onNavigateToCategories;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToUsers,
    this.onNavigateToCategories,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedPeriod = 'today';
  
  // ✅ متغيرات البيانات
  final AdminService _adminService = AdminService();
  final UserService _userService = UserService();
  final StoreService _storeService = StoreService();
  
  bool _isLoading = true;
  String? _error;
  
  // ✅ إحصائيات حقيقية
  int _totalStores = 0;
  int _totalUsers = 0;
  int _totalRatings = 0;
  int _totalViews = 0;
  int _storesChange = 0;
  int _usersChange = 0;
  int _ratingsChange = 0;
  int _viewsChange = 0;
  
  // ✅ الأنشطة الأخيرة
  List<ActivityItem> _recentActivities = [];
  
  // ✅ بيانات المستخدم الحالي
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }
Future<void> _loadDashboardData() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    // ✅ محاولة جلب البيانات من API
    final stats = await _adminService.getDashboardStats(period: _selectedPeriod);
    
    if (mounted) {
      setState(() {
        _totalStores = stats['totalStores'] ?? 0;
        _totalUsers = stats['totalUsers'] ?? 0;
        _totalRatings = stats['totalRatings'] ?? 0;
        _totalViews = stats['totalViews'] ?? 0;
        _storesChange = stats['storesChange'] ?? 0;
        _usersChange = stats['usersChange'] ?? 0;
        _ratingsChange = stats['ratingsChange'] ?? 0;
        _viewsChange = stats['viewsChange'] ?? 0;
      });
    }
  } catch (e) {
    // ✅ إذا فشل API، استخدم بيانات حقيقية من Services المتوفرة
    print('API stats failed, using fallback data: $e');
    await _loadFallbackData();
  }
  
  // ✅ تحميل الأنشطة (بيانات تجريبية)
  _recentActivities = [
    ActivityItem(
      icon: Icons.add_business,
      title: 'new_store_added'.tr(),
      subtitle: 'store_added_desc'.tr(args: ['Nike Store']),
      time: '5_min_ago'.tr(),
      color: Colors.blue,
    ),
    ActivityItem(
      icon: Icons.person_add,
      title: 'new_user_registered'.tr(),
      subtitle: 'user_registered_desc'.tr(args: ['Ahmed Mohamed']),
      time: '15_min_ago'.tr(),
      color: Colors.green,
    ),
    ActivityItem(
      icon: Icons.rate_review,
      title: 'new_review'.tr(),
      subtitle: 'review_desc'.tr(args: ['5', 'Adidas Store']),
      time: '1_hour_ago'.tr(),
      color: Colors.orange,
    ),
  ];

  if (mounted) {
    setState(() {
      _isLoading = false;
    });
  }
}

// ✅ بيانات احتياطية من الـ Services المتوفرة
Future<void> _loadFallbackData() async {
  try {
    // جلب عدد المستخدمين من UserService
    final users = await _userService.getUsers();
    _totalUsers = users.length;
    _usersChange = 0;  // لا يوجد بيانات للتغيير
    
    // جلب عدد المتاجر من StoreService
    final storesResponse = await _storeService.getAllStoresForAdmin(page: 1, pageSize: 1);
    _totalStores = storesResponse.totalCount;
    _storesChange = 0;
    
    // قيم افتراضية للتقييمات والمشاهدات
    _totalRatings = 0;
    _totalViews = 0;
    _ratingsChange = 0;
    _viewsChange = 0;
    
    print('Fallback data loaded: Users=$_totalUsers, Stores=$_totalStores');
  } catch (e) {
    print('Error loading fallback data: $e');
  }
}
  
   @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: 'admin_dashboard'.tr(),
        showProfileIcon: true,
        profileTabIndex: 3,
        leadingWidget: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: scheme.primary,
            onPressed: () {
              // TODO: فتح صفحة الإشعارات
            },
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDashboardData,
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(context),
                        const SizedBox(height: 24),
                        _buildPeriodFilter(),
                        const SizedBox(height: 24),
                        _buildStatsGrid(),
                        const SizedBox(height: 32),
                        Text(
                          'quick_actions'.tr(),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickActionsGrid(),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'recent_activities'.tr(),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: عرض كل الأنشطة
                              },
                              child: Text(
                                'view_all'.tr(),
                                style: TextStyle(color: scheme.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildRecentActivities(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome_back_admin'.tr(),
                  style: textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentUser?.fullName ?? 'Admin',
                  style: textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'admin_dashboard_desc'.tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: scheme.onPrimary.withOpacity(0.2),
            child: Icon(
              Icons.admin_panel_settings,
              size: 40,
              color: scheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterChip('today'.tr(), 'today'),
          _buildFilterChip('week'.tr(), 'week'),
          _buildFilterChip('month'.tr(), 'month'),
          _buildFilterChip('year'.tr(), 'year'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _selectedPeriod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
        _loadDashboardData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.store_outlined,
          title: 'total_stores'.tr(),
          value: _formatNumber(_totalStores),
          change: _formatChange(_storesChange),
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.people_outline,
          title: 'total_users'.tr(),
          value: _formatNumber(_totalUsers),
          change: _formatChange(_usersChange),
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.rate_review_outlined,
          title: 'total_reviews'.tr(),
          value: _formatNumber(_totalRatings),
          change: _formatChange(_ratingsChange),
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.visibility_outlined,
          title: 'total_views'.tr(),
          value: _formatNumber(_totalViews),
          change: _formatChange(_viewsChange),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required Color color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = change.startsWith('+');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (change != '0')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }


Widget _buildQuickAction({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
Widget _buildQuickActionsGrid() {
  final scheme = Theme.of(context).colorScheme;

  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 4,
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
    childAspectRatio: 0.9,
    children: [
      _buildQuickAction(
        icon: Icons.add_business_outlined,
        label: 'add_store'.tr(),
        color: scheme.primary,
        onTap: () {
          // ✅ نفس أسلوب StoreDetailsScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const StoreFormScreen(),  // شاشة إضافة متجر
            ),
          );
      }
    ),
      _buildQuickAction(
        icon: Icons.add_box,  
        label: 'add_category'.tr(),          
        color: Colors.green,
        onTap: () {
          // ✅ فتح شاشة إضافة فئة جديدة
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CategoryFormScreen(),  // شاشة إضافة فئة
            ),
          );
        },
      ),      _buildQuickAction(
        icon: Icons.analytics_outlined,
        label: 'analytics'.tr(),
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen()),
          );
        },
      ),
      _buildQuickAction(
        icon: Icons.people_outline,
        label: 'users'.tr(),
        color: Colors.blue,
        onTap: () {
          if (widget.onNavigateToUsers != null) {
            widget.onNavigateToUsers!();
          }
        },
      ),
    ],
  );
}

  Widget _buildRecentActivities() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_recentActivities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'no_activities'.tr(),
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _recentActivities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return Column(
            children: [
              _buildActivityItem(activity),
              if (index < _recentActivities.length - 1) _buildDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(activity.icon, color: activity.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final scheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: scheme.outlineVariant,
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatChange(int change) {
    if (change > 0) return '+$change';
    if (change < 0) return change.toString();
    return '0';
  }
}

// ✅ موديل النشاط
class ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
}