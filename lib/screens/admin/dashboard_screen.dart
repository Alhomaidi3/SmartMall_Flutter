import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import 'analytics_screen.dart';

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
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              // TODO: فتح صفحة الإشعارات
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Welcome Section
            _buildWelcomeSection(context),
            
            const SizedBox(height: 24),
            
            // 🔹 Period Filter
            _buildPeriodFilter(),
            
            const SizedBox(height: 24),
            
            // 🔹 Stats Cards
            _buildStatsGrid(),
            
            const SizedBox(height: 32),
            
            // 🔹 Quick Actions
            Text(
              'quick_actions'.tr(),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 16),
             _buildQuickActionsGrid(),  // ✅ أضف هذا السطر           
            const SizedBox(height: 32),
            
            // 🔹 Recent Activities
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
                    // View all activities
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
      // ✅ تم حذف bottomNavigationBar نهائياً
    );
  }


  Widget _buildWelcomeSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primary.withOpacity(0.8),
          ],
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
                  'admin_dashboard_desc'.tr(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'last_login_today'.tr(),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimary,
                    ),
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
      onTap: () => setState(() => _selectedPeriod = value),
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
          value: '24',
          change: '+3',
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.people_outline,
          title: 'total_users'.tr(),
          value: '1,284',
          change: '+48',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.rate_review_outlined,
          title: 'total_reviews'.tr(),
          value: '3,421',
          change: '+156',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.visibility_outlined,
          title: 'total_views'.tr(),
          value: '12.5K',
          change: '+1.2K',
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: Colors.green,
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
  double _scale = 1.0;  // ✅ متغير التحكم في الحجم

  return StatefulBuilder(
    builder: (context, setState) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _scale = 0.95),
          onTapUp: (_) {
            setState(() => _scale = 1.0);
            onTap();
          },
          onTapCancel: () => setState(() => _scale = 1.0),
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 150),
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
          ),
        ),
      );
    },
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
          Navigator.pushNamed(context, '/admin/stores/add');
        },
      ),
      _buildQuickAction(
        icon: Icons.category_outlined,
        label: 'categories'.tr(),
        color: Colors.green,
        onTap: () { 
          if (widget.onNavigateToCategories != null) {
            widget.onNavigateToCategories!();
          }
        },
      ),
      _buildQuickAction(
        icon: Icons.analytics_outlined,
        label: 'analytics'.tr(),
        color: Colors.orange,
  onTap: () {
    // ✅ نفس أسلوب StoreCard بالضبط
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminAnalyticsScreen(), 
      ),
    );
  },
      ),
      _buildQuickAction(
        icon: Icons.settings_outlined,
        label: 'settings'.tr(),
        color: Colors.grey,
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
        children: [
          _buildActivityItem(
            icon: Icons.add_business,
            title: 'new_store_added'.tr(),
            subtitle: 'store_added_desc'.tr(args: ['Nike']),
            time: '5_min_ago'.tr(),
            color: Colors.blue,
          ),
          _buildDivider(),
          _buildActivityItem(
            icon: Icons.person_add,
            title: 'new_user_registered'.tr(),
            subtitle: 'user_registered_desc'.tr(args: ['Ahmed Ali']),
            time: '15_min_ago'.tr(),
            color: Colors.green,
          ),
          _buildDivider(),
          _buildActivityItem(
            icon: Icons.rate_review,
            title: 'new_review'.tr(),
            subtitle: 'review_desc'.tr(args: ['5', 'Adidas']),
            time: '1_hour_ago'.tr(),
            color: Colors.orange,
          ),
          _buildDivider(),
          _buildActivityItem(
            icon: Icons.edit,
            title: 'store_updated'.tr(),
            subtitle: 'store_updated_desc'.tr(args: ['Zara']),
            time: '2_hours_ago'.tr(),
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
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
}