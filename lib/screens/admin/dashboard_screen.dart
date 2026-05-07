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
  
  final AdminService _adminService = AdminService();
  final UserService _userService = UserService();
  final StoreService _storeService = StoreService();
  
  bool _isLoading = true;
  String? _error;
  
  int _totalStores = 0;
  int _totalUsers = 0;
  int _totalRatings = 0;
  int _totalViews = 0;
  int _storesChange = 0;
  int _usersChange = 0;
  int _ratingsChange = 0;
  int _viewsChange = 0;
  
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
      debugPrint('Error loading current user: $e');
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
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
      debugPrint('API stats failed, using fallback data: $e');
      await _loadFallbackData();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFallbackData() async {
    try {
      final users = await _userService.getUsers();
      _totalUsers = users.length;
      _usersChange = 0;
      
      final storesResponse = await _storeService.getAllStoresForAdmin(page: 1, pageSize: 1);
      _totalStores = storesResponse.totalCount;
      _storesChange = 0;
      
      _totalRatings = 0;
      _totalViews = 0;
      _ratingsChange = 0;
      _viewsChange = 0;
      
      debugPrint('Fallback data loaded: Users=$_totalUsers, Stores=$_totalStores');
    } catch (e) {
      debugPrint('Error loading fallback data: $e');
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
            color: scheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: scheme.primary,
            onPressed: () {},
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
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
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
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: scheme.onPrimary.withValues(alpha: 0.2),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
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
    final bool isSelected = _selectedPeriod == value;

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isPositive = change.startsWith('+');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (change != '0')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.1),
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
              color: scheme.onSurface.withValues(alpha: 0.7),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: Colors.black.withValues(alpha: 0.05),
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
                color: color.withValues(alpha: 0.1),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StoreFormScreen()),
            );
          },
        ),
        _buildQuickAction(
          icon: Icons.add_box,
          label: 'add_category'.tr(),
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoryFormScreen()),
            );
          },
        ),
        _buildQuickAction(
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