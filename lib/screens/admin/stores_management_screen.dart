import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/services/store_service.dart';
import '/services/category_service.dart';
import '/models/store.dart';
import '/models/category.dart';
import 'store_form_screen.dart';

class StoresManagementScreen extends StatefulWidget {
  const StoresManagementScreen({super.key});

  @override
  State<StoresManagementScreen> createState() => _StoresManagementScreenState();
}

class _StoresManagementScreenState extends State<StoresManagementScreen> {
  String searchQuery = '';
  String selectedCategory = 'all';
  String selectedStatus = 'all';
  final TextEditingController searchController = TextEditingController();
  
  List<StoreDto> _stores = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isSearching = false;
  
  final StoreService _storeService = StoreService();
  final CategoryService _categoryService = CategoryService();
  final List<FilterChipData> statusFilters = [
    const FilterChipData(value: 'all', labelKey: 'all_stores', icon: Icons.store_outlined),
    const FilterChipData(value: 'active', labelKey: 'active', icon: Icons.check_circle_outline, selectedColor: Colors.green),
    const FilterChipData(value: 'inactive', labelKey: 'inactive', icon: Icons.remove_circle_outline, selectedColor: Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _fetchCategories(),
      _fetchStores(),
    ]);
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryService.getAllCategoriesForAdmin(
        language: context.locale.languageCode,
      );
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchStores({bool refresh = false}) async {
    if (!_hasMore && !refresh) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      if (mounted) setState(() => _isLoading = true);
    } else if (_currentPage == 1) {
      if (mounted) setState(() => _isLoading = true);
    }
    
    try {
      final response = await _storeService.getAllStoresForAdmin(
        page: _currentPage,
        pageSize: 20,
        category: selectedCategory == 'all' ? null : selectedCategory,
        language: context.locale.languageCode,
      );
      
      if (!mounted) return;
      
      setState(() {
        if (refresh || _currentPage == 1) {
          _stores = response.data;
        } else {
          _stores.addAll(response.data);
        }
        _hasMore = response.hasNext;
        _isLoading = false;
      });
      
      if (response.hasNext) {
        _currentPage++;
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

  Future<void> _searchStores(String query) async {
    if (query.isEmpty) {
      _isSearching = false;
      _currentPage = 1;
      _hasMore = true;
      await _fetchStores(refresh: true);
      return;
    }
    
    if (query.length < 2) return;
    
    setState(() {
      _isSearching = true;
      _isLoading = true;
    });
    
    try {
      final results = await _storeService.searchStores(
        query,
        language: context.locale.languageCode,
      );
      
      if (mounted) {
        setState(() {
          _stores = results;
          _isLoading = false;
        });
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

  List<StoreDto> get filteredStores {
    return _stores.where((store) {
      if (selectedStatus == 'active' && !store.isActive) {
        return false;
      }
      if (selectedStatus == 'inactive' && store.isActive) {
        return false;
      }
      return true;
    }).toList();
  }

  List<FilterChipData> get categoryFilters {
    final filters = [
      const FilterChipData(
        value: 'all',
        labelKey: 'all_categories',
        icon: Icons.category_outlined,
      ),
      ..._categories.map((c) => FilterChipData(
        value: c.getName(context.locale.languageCode),
        dynamicLabel: c.getName(context.locale.languageCode),
        icon: Icons.category,
        selectedColor: Theme.of(context).colorScheme.primary,
      )),
    ];
    return filters;
  }

  Future<void> _deleteStore(StoreDto store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_store'.tr()),
        content: Text(
          'delete_store_confirmation'.tr(
            args: [store.getName(context.locale.languageCode)],
          ),
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
        await _storeService.deleteStore(store.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('store_deleted'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          await _fetchStores(refresh: true);
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = context.locale.languageCode;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: 'stores_management'.tr(),
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: searchController,
              onChanged: (value) {
                setState(() => searchQuery = value);
                _searchStores(value);
              },
              hintText: 'search_stores'.tr(),
            ),
          ),
          
          // Stats Row with Add Button
          UnifiedStatsRow(
            icon: Icons.store,
            title: 'total_stores'.tr(),
            count: filteredStores.length,
            onAddPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StoreFormScreen(),
                ),
              );
              if (result == true) {
                _fetchStores(refresh: true);
              }
            },
            addButtonText: 'add_store'.tr(),
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
            // Status Filter Chips
            if (statusFilters.isNotEmpty)
              FilterChipsRow(
                filters: statusFilters,
                selectedStatus: selectedStatus,
                onSingleSelected: (value) {
                  setState(() {
                    selectedStatus = value;
                    if (value == 'all') selectedCategory = 'all';
                    _fetchStores(refresh: true);
                  });
                },
              ),
            // Category Filter Chips
            if (categoryFilters.isNotEmpty)
              FilterChipsRow(
                filters: categoryFilters,
                selectedStatus: selectedCategory,
                onSingleSelected: (value) {
                  setState(() {
                    selectedCategory = value;
                    if (value == 'all') selectedStatus = 'all';
                    _currentPage = 1;
                    _hasMore = true;
                    _fetchStores(refresh: true);
                  });
                },
              ),

            // Stores List
            UnifiedLoadingState(
              isLoading: _isLoading && _stores.isEmpty,
              isEmpty: filteredStores.isEmpty,
              emptyIcon: 'store',
              emptyTitle: 'no_stores_found'.tr(),
              emptySubtitle: 'try_adjusting_search'.tr(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!_isLoading && _hasMore && !_isSearching &&
                      scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                    _fetchStores();
                  }
                  return false;
                },
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStores.length + (_hasMore && !_isSearching ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredStores.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final store = filteredStores[index];
                    return _buildStoreCard(context, store);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)  )      ],
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, StoreDto store) {
    final locale = context.locale.languageCode;
    
    // بناء معلومات إضافية للبطاقة
    final additionalInfo = [
      Row(
        children: [
          Icon(Icons.layers, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            '${'floor'.tr()}: ${store.floor}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(
            store.averageRating.toStringAsFixed(1),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${store.ratingsCount})',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    ];

    return UnifiedCard(
      type: CardType.store,
      data: store,
      title: store.getName(locale),
      subtitle: store.getCategoryName(locale) ?? 'no_category'.tr(),
      isActive: store.isActive,
      onEdit: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreFormScreen(store: store),
          ),
        );
        if (result == true) {
          _fetchStores(refresh: true);
        }
      },
      onDelete: () => _deleteStore(store),
      additionalInfo: additionalInfo,
    );
  }
}