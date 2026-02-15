import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/data/data.dart';
import 'store_edit_screen.dart';

class StoresManagementScreen extends StatefulWidget {
  const StoresManagementScreen({super.key});

  @override
  State<StoresManagementScreen> createState() => _StoresManagementScreenState();
}

class _StoresManagementScreenState extends State<StoresManagementScreen> {
  String searchQuery = '';
  String selectedCategory = 'all';
  final TextEditingController searchController = TextEditingController();

  List<StoreData> get filteredStores {
    return storesData.where((store) {
      final matchesSearch = store.nameEn.toLowerCase().contains(searchQuery.toLowerCase()) ||
          store.nameAr.contains(searchQuery) ||
          store.category.toLowerCase().contains(searchQuery.toLowerCase());
      
      final matchesCategory = selectedCategory == 'all' || store.category == selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get categories {
    return ['all', ...storesData.map((s) => s.category).toSet()];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scheme.surface,
            appBar: CustomAppBar(
        title: 'stores_management'.tr(),
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              hintText: 'search_stores'.tr(),
            ),
          ),

          // Category Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category == 'all' ? 'all_categories'.tr() : '${category}_title'.tr(),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selectedCategory = category);
                    },
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    selectedColor: scheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? scheme.primary : scheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    checkmarkColor: scheme.primary,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'total_stores'.tr(),
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
                    '${filteredStores.length}',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StoreEditScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text('add_store'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Stores List
          Expanded(
            child: filteredStores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block,
                          size: 80,
                          color: scheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_stores_found'.tr(),
                          style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStores.length,
                    itemBuilder: (context, index) {
                      final store = filteredStores[index];
                      return _buildStoreCard(context, store);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, StoreData store) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = context.locale.languageCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreEditScreen(store: store),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Store Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  store.image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: Icon(Icons.store, color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Store Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale == 'ar' ? store.nameAr : store.nameEn,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${store.category}_title'.tr(),
                      style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${store.rating}',
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${store.ratingCount})',
                          style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: scheme.primary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreEditScreen(store: store),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, store),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, StoreData store) async {
    final scheme = Theme.of(context).colorScheme;
    final locale = context.locale.languageCode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_store'.tr()),
        content: Text(
          'delete_store_confirmation'.tr(
            args: [locale == 'ar' ? store.nameAr : store.nameEn],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
            ),
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
      // Here you would delete the store
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('store_deleted'.tr()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}