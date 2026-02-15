import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  String _selectedPeriod = 'week'; // today, week, month, year
  String _selectedChartType = 'visits'; // visits, users, stores, reviews

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: 'analytics'.tr(),
        showProfileIcon: false,
        customActions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.filter_list, color: scheme.primary),
              onPressed: () => _showFilterDialog(context),
            ),
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
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPeriodFilter(),
            const SizedBox(height: 24),
            _buildChartTypeSelector(),
            const SizedBox(height: 24),
            _buildMainChart(),
            const SizedBox(height: 32),
            Text(
              'key_metrics'.tr(),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricsGrid(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'detailed_analysis'.tr(),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // تصدير التقرير
                  },
                  child: Row(
                    children: [
                      Icon(Icons.download_outlined, size: 18, color: scheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'export'.tr(),
                        style: TextStyle(color: scheme.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailedAnalysis(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final scheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.purple.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
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
                  'analytics_overview'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'analytics_description'.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'last_updated_now'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.analytics, size: 40, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[800] 
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodChip('today'.tr(), 'today'),
          _buildPeriodChip('week'.tr(), 'week'),
          _buildPeriodChip('month'.tr(), 'month'),
          _buildPeriodChip('year'.tr(), 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
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

  Widget _buildChartTypeSelector() {
    return Row(
      children: [
        _buildTypeChip(Icons.visibility_outlined, 'visits', 'visits'.tr()),
        const SizedBox(width: 8),
        _buildTypeChip(Icons.people_outline, 'users', 'users'.tr()),
        const SizedBox(width: 8),
        _buildTypeChip(Icons.store_outlined, 'stores', 'stores'.tr()),
        const SizedBox(width: 8),
        _buildTypeChip(Icons.rate_review_outlined, 'reviews', 'reviews'.tr()),
      ],
    );
  }

  Widget _buildTypeChip(IconData icon, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _selectedChartType == value;
    
    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? scheme.primary : scheme.onSurface.withOpacity(0.5),
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedChartType = value),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[200],
      selectedColor: scheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? scheme.primary : scheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: scheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: isSelected ? BorderSide(color: scheme.primary, width: 1) : BorderSide.none,
      ),
    );
  }

  Widget _buildMainChart() {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Map<String, dynamic>> chartData = _getChartData();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getChartTitle(),
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '+15.3%',
                      style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(chartData.length, (index) {
                final data = chartData[index];
                final height = data['value'] * 1.5;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [scheme.primary.withOpacity(0.3), scheme.primary],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['label'],
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total_for_period'.tr(),
                      style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTotalValue(),
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getChartIcon(), color: scheme.primary, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getChartData() {
    switch (_selectedChartType) {
      case 'visits':
        return const [
          {'label': 'Mon', 'value': 120},
          {'label': 'Tue', 'value': 145},
          {'label': 'Wed', 'value': 132},
          {'label': 'Thu', 'value': 168},
          {'label': 'Fri', 'value': 189},
          {'label': 'Sat', 'value': 210},
          {'label': 'Sun', 'value': 156},
        ];
      case 'users':
        return const [
          {'label': 'Mon', 'value': 12},
          {'label': 'Tue', 'value': 18},
          {'label': 'Wed', 'value': 15},
          {'label': 'Thu', 'value': 22},
          {'label': 'Fri', 'value': 28},
          {'label': 'Sat', 'value': 35},
          {'label': 'Sun', 'value': 24},
        ];
      case 'stores':
        return const [
          {'label': 'Mon', 'value': 2},
          {'label': 'Tue', 'value': 1},
          {'label': 'Wed', 'value': 3},
          {'label': 'Thu', 'value': 2},
          {'label': 'Fri', 'value': 4},
          {'label': 'Sat', 'value': 1},
          {'label': 'Sun', 'value': 2},
        ];
      case 'reviews':
        return const [
          {'label': 'Mon', 'value': 45},
          {'label': 'Tue', 'value': 52},
          {'label': 'Wed', 'value': 48},
          {'label': 'Thu', 'value': 63},
          {'label': 'Fri', 'value': 71},
          {'label': 'Sat', 'value': 84},
          {'label': 'Sun', 'value': 56},
        ];
      default:
        return [];
    }
  }

  String _getChartTitle() {
    switch (_selectedChartType) {
      case 'visits':
        return 'visits_over_time'.tr();
      case 'users':
        return 'users_over_time'.tr();
      case 'stores':
        return 'stores_over_time'.tr();
      case 'reviews':
        return 'reviews_over_time'.tr();
      default:
        return 'analytics'.tr();
    }
  }

  String _getTotalValue() {
    final data = _getChartData();
    final total = data.fold<int>(0, (sum, item) => sum + (item['value'] as int));
    
    switch (_selectedChartType) {
      case 'visits':
        return '$total ' + 'visits'.tr();
      case 'users':
        return '$total ' + 'users'.tr();
      case 'stores':
        return '$total ' + 'stores'.tr();
      case 'reviews':
        return '$total ' + 'reviews'.tr();
      default:
        return '$total';
    }
  }

  IconData _getChartIcon() {
    switch (_selectedChartType) {
      case 'visits':
        return Icons.visibility;
      case 'users':
        return Icons.people;
      case 'stores':
        return Icons.store;
      case 'reviews':
        return Icons.rate_review;
      default:
        return Icons.analytics;
    }
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          icon: Icons.visibility,
          title: 'avg_daily_visits'.tr(),
          value: '245',
          change: '+12%',
          color: Colors.blue,
        ),
        _buildMetricCard(
          icon: Icons.people,
          title: 'avg_daily_users'.tr(),
          value: '28',
          change: '+8%',
          color: Colors.green,
        ),
        _buildMetricCard(
          icon: Icons.store,
          title: 'active_stores'.tr(),
          value: '42',
          change: '+3',
          color: Colors.orange,
        ),
        _buildMetricCard(
          icon: Icons.rate_review,
          title: 'avg_rating'.tr(),
          value: '4.7',
          change: '+0.2',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (change.startsWith('+') ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: change.startsWith('+') ? Colors.green : Colors.red,
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

  Widget _buildDetailedAnalysis() {
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
          _buildAnalysisItem(
            icon: Icons.access_time,
            title: 'peak_hours'.tr(),
            subtitle: 'peak_hours_desc'.tr(args: ['12:00 - 14:00', '18:00 - 20:00']),
            value: '2.5x',
            color: Colors.blue,
          ),
          _buildDivider(),
          _buildAnalysisItem(
            icon: Icons.location_on,
            title: 'top_location'.tr(),
            subtitle: 'top_location_desc'.tr(args: ['Riyadh']),
            value: '42%',
            color: Colors.green,
          ),
          _buildDivider(),
          _buildAnalysisItem(
            icon: Icons.devices,
            title: 'device_usage'.tr(),
            subtitle: 'device_usage_desc'.tr(args: ['Mobile', 'Desktop']),
            value: '78%',
            color: Colors.orange,
          ),
          _buildDivider(),
          _buildAnalysisItem(
            icon: Icons.trending_up,
            title: 'growth_rate'.tr(),
            subtitle: 'growth_rate_desc'.tr(args: ['15.3%']),
            value: '+15.3%',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
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

  void _showFilterDialog(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'filter_analytics'.tr(),
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: scheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.date_range, color: scheme.primary),
              title: Text('custom_range'.tr()),
              trailing: Icon(Icons.chevron_right, color: scheme.onSurface),
              onTap: () {
                Navigator.pop(context);
                // TODO: فتح منتقي التاريخ
              },
            ),
            ListTile(
              leading: Icon(Icons.compare_arrows, color: scheme.primary),
              title: Text('compare_with'.tr()),
              trailing: Icon(Icons.chevron_right, color: scheme.onSurface),
              onTap: () {
                Navigator.pop(context);
                // TODO: فتح خيارات المقارنة
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: scheme.primary),
              title: Text('export_data'.tr()),
              trailing: Icon(Icons.chevron_right, color: scheme.onSurface),
              onTap: () {
                Navigator.pop(context);
                // TODO: تصدير البيانات
              },
            ),
          ],
        ),
      ),
    );
  }
}