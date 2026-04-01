import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '../../services/category_service.dart';
import '../../models/category.dart';

class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  State<CategoriesManagementScreen> createState() => _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState extends State<CategoriesManagementScreen> {
  String searchQuery = '';
  String selectedStatus = 'all';
  final TextEditingController searchController = TextEditingController();
  
  List<Category> _categories = [];
  bool _isLoading = true;
  
  final CategoryService _categoryService = CategoryService();

  // 🔹 ألوان افتراضية للفئات
  final List<Color> _categoryColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategories();
    });
  }
  
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final categories = await _categoryService.getAllCategoriesForAdmin(
        language: context.locale.languageCode,
      );
      
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showMessage(context, e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchCategories(String query) async {
    if (query.isEmpty) {
      await _fetchCategories();
      return;
    }
    
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final allCategories = await _categoryService.getAllCategoriesForAdmin(
        language: context.locale.languageCode,
      );
      
      final filtered = allCategories.where((category) {
        final name = category.getName(context.locale.languageCode).toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
      
      if (!mounted) return;
      setState(() {
        _categories = filtered;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showMessage(context, e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Category> get filteredCategories {
    return _categories.where((category) {
      if (selectedStatus == 'active') {
        return category.isActive;
      } else if (selectedStatus == 'inactive') {
        return !category.isActive;
      }
      return true;
    }).toList();
  }

  Future<void> _showAddCategoryDialog() async {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    final iconUrlController = TextEditingController();
    bool isActive = true;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('add_category'.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UnifiedTextField(
                    controller: nameArController,
                    label: 'category_name_ar'.tr(),
                    icon: Icons.text_fields,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  UnifiedTextField(
                    controller: nameEnController,
                    label: 'category_name_en'.tr(),
                    icon: Icons.text_fields,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  UnifiedTextField(
                    controller: iconUrlController,
                    label: 'icon_url'.tr(),
                    icon: Icons.link,
                    hintText: 'https://example.com/icon.png',
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('active'.tr()),
                    value: isActive,
                    onChanged: (value) {
                      setDialogState(() => isActive = value);
                    },
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nameAr = nameArController.text.trim();
                  final nameEn = nameEnController.text.trim();
                  
                  if (nameAr.isEmpty) {
                    if (!mounted) return;
                    showMessage(context, 'category_name_ar_required'.tr(), type: MessageType.error);
                    return;
                  }
                  
                  if (nameEn.isEmpty) {
                    if (!mounted) return;
                    showMessage(context, 'category_name_en_required'.tr(), type: MessageType.error);
                    return;
                  }
                  
                  Navigator.pop(context);
                  
                  if (!mounted) return;
                  setState(() => _isLoading = true);
                  
                  try {
                    await _categoryService.createCategory(
                      CategoryCreateDto(
                        nameAr: nameAr,
                        nameEn: nameEn,
                        iconUrl: iconUrlController.text.trim().isEmpty 
                            ? null 
                            : iconUrlController.text.trim(),
                      ),
                    );
                    
                    if (!mounted) return;
                    showMessage(context, 'category_added'.tr(), type: MessageType.success);
                    await _fetchCategories();
                  } catch (e) {
                    if (!mounted) return;
                    showMessage(context, e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('save'.tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editCategory(Category category) async {
    final nameArController = TextEditingController(text: category.nameAr);
    final nameEnController = TextEditingController(text: category.nameEn);
    final iconUrlController = TextEditingController(text: category.iconUrl ?? '');
    bool isActive = category.isActive;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('edit_category'.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UnifiedTextField(
                    controller: nameArController,
                    label: 'category_name_ar'.tr(),
                    icon: Icons.text_fields,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  UnifiedTextField(
                    controller: nameEnController,
                    label: 'category_name_en'.tr(),
                    icon: Icons.text_fields,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  UnifiedTextField(
                    controller: iconUrlController,
                    label: 'icon_url'.tr(),
                    icon: Icons.link,
                    hintText: 'https://example.com/icon.png',
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('active'.tr()),
                    value: isActive,
                    onChanged: (value) {
                      setDialogState(() => isActive = value);
                    },
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  if (!mounted) return;
                  setState(() => _isLoading = true);
                  
                  try {
                    await _categoryService.updateCategory(
                      category.id,
                      CategoryUpdateDto(
                        nameAr: nameArController.text.trim().isEmpty ? null : nameArController.text.trim(),
                        nameEn: nameEnController.text.trim().isEmpty ? null : nameEnController.text.trim(),
                        iconUrl: iconUrlController.text.trim().isEmpty ? null : iconUrlController.text.trim(),
                        isActive: isActive,
                      ),
                    );
                    
                    if (!mounted) return;
                    showMessage(context, 'category_updated'.tr(), type: MessageType.success);
                    await _fetchCategories();
                  } catch (e) {
                    if (!mounted) return;
                    showMessage(context, e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('save'.tr()),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_category'.tr()),
        content: Text(
          'delete_category_confirmation'.tr(args: [category.getName(context.locale.languageCode)]),
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
        await _categoryService.deleteCategory(category.id);
        showMessage(context, 'category_deleted'.tr(), type: MessageType.success);
        await _fetchCategories();
      } catch (e) {
        showMessage(context, e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getCategoryColor(int id) {
    return _categoryColors[id % _categoryColors.length];
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('cloth') || name.contains('fashion') || name.contains('wear')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('shoe') || name.contains('foot')) {
      return Icons.shopping_basket_outlined;
    } else if (name.contains('perfume') || name.contains('cosmetic')) {
      return Icons.spa_outlined;
    } else if (name.contains('electro') || name.contains('tech')) {
      return Icons.devices_outlined;
    } else if (name.contains('accessor')) {
      return Icons.watch_outlined;
    } else if (name.contains('restaurant') || name.contains('food')) {
      return Icons.restaurant_outlined;
    } else {
      return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: 'categories_management'.tr(),
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
                _searchCategories(value);
              },
              hintText: 'search_categories'.tr(),
            ),
          ),

          // Stats Row with Add Button
          UnifiedStatsRow(
            icon: Icons.category,
            title: 'total_categories'.tr(),
            count: filteredCategories.length,
            onAddPressed: _showAddCategoryDialog,
            addButtonText: 'add_category'.tr(),
          ),

          // Scrollable Content مع زوايا منحنية
Expanded(
      child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), 
child: ClipRRect(
    borderRadius: BorderRadius.circular(20), // زاوية منحنية 20
    child: Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter Chips
            FilterChipsRow(
              filters: [
                const FilterChipData(
                  value: 'all',
                  labelKey: 'all_categories',
                  icon: Icons.category_outlined,
                ),
                const FilterChipData(
                  value: 'active',
                  labelKey: 'active',
                  icon: Icons.check_circle_outline,
                  selectedColor: Colors.green,
                ),
                const FilterChipData(
                  value: 'inactive',
                  labelKey: 'inactive',
                  icon: Icons.remove_circle_outline,
                  selectedColor: Colors.red,
                ),
              ],
              selectedStatus: selectedStatus,
              onSingleSelected: (value) => setState(() {
                selectedStatus = value;
              }),
            ),

            // Categories List
            UnifiedLoadingState(
              isLoading: _isLoading,
              isEmpty: filteredCategories.isEmpty,
              emptyIcon: 'category',
              emptyTitle: 'no_categories_found'.tr(),
              emptySubtitle: 'try_adjusting_search'.tr(),
              child: RefreshIndicator(
                onRefresh: _fetchCategories,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return _buildCategoryCard(context, category);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
))
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    final locale = context.locale.languageCode;
    final categoryColor = _getCategoryColor(category.id);
    final categoryIcon = _getCategoryIcon(category.getName(locale));

    // بناء معلومات إضافية للبطاقة
    final additionalInfo = [
      Row(
        children: [
          Icon(
            Icons.store_outlined,
            size: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${category.storesCount} ${'stores'.tr()}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ];

    return UnifiedCard(
      type: CardType.category,
      data: category,
      title: category.getName(locale),
      subtitle: category.nameAr,
      isActive: category.isActive,
      customColor: categoryColor,
      onEdit: () => _editCategory(category),
      onDelete: () => _deleteCategory(category),
      additionalInfo: additionalInfo,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: categoryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          categoryIcon,
          color: categoryColor,
          size: 28,
        ),
      ),
    );
  }
}