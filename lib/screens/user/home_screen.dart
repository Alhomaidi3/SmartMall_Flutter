import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'store_details_screen.dart';
import '/widgets/widgets.dart';
import '/services/store_service.dart';
import '/services/category_service.dart';
import '/models/store.dart';
import '/models/category.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onProfilePressed;
  final void Function(int storeId) onDirectionsRequested; // ✅ إضافة هذا

  const HomeScreen({
    super.key,
    required this.onProfilePressed,
        required this.onDirectionsRequested, // ✅ إضافة هذا

  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  // ✅ متغيرات API
  final StoreService _storeService = StoreService();
  final CategoryService _categoryService = CategoryService();
  
  List<StoreDto> _allStores = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // ✅ لا تستخدم الترجمة هنا
    // فقط قم بتهيئة الـ Controller
  }
  void _requestDirections(int storeId) {
    widget.onDirectionsRequested(storeId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ استخدم الترجمة هنا بعد أن تصبح جاهزة
    _loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _storeService.getStores(
        page: 1,
        pageSize: 100,
        language: context.locale.languageCode,
      );
      
      final categories = await _categoryService.getCategories(
        language: context.locale.languageCode,
      );

      if (mounted) {
        setState(() {
          _allStores = response.data;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // 🔹 دالة لتحويل الحروف العربية إلى شكل موحد لتسهيل البحث
  String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll(RegExp(r'ى'), 'ي')
        .replaceAll(RegExp(r'ؤ'), 'و')
        .replaceAll(RegExp(r'ئ'), 'ي')
        .replaceAll(RegExp(r'ّ'), '')
        .replaceAll(RegExp(r'َ|ً|ُ|ٌ|ِ|ٍ|ْ'), '');
  }

  // 🔹 الحصول على المتاجر المفلترة حسب البحث
  List<StoreDto> get filteredStores {
    if (searchQuery.isEmpty) return _allStores;
    
    final query = normalize(searchQuery);
    return _allStores.where((store) {
      final nameAr = normalize(store.nameAr);
      final nameEn = store.nameEn.toLowerCase();
      final descAr = normalize(store.descriptionAr ?? '');
      final descEn = store.descriptionEn?.toLowerCase() ?? '';

      return nameAr.contains(query) ||
          nameEn.contains(query) ||
          descAr.contains(query) ||
          descEn.contains(query);
    }).toList();
  }

  // 🔹 تجميع المتاجر حسب الفئة
  List<CategoryGroup> get groupedStores {
    final Map<int, List<StoreDto>> grouped = {};
    final stores = filteredStores;

    for (final store in stores) {
      final categoryId = store.categoryId ?? 0;
      grouped.putIfAbsent(categoryId, () => []);
      grouped[categoryId]!.add(store);
    }

    return grouped.entries.map((entry) {
      final category = _categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(
          id: 0,
          nameAr: 'other'.tr(),
          nameEn: 'Other',
          iconUrl: null,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          storesCount: 0,
        ),
      );
      
      return CategoryGroup(
        title: category.getName(context.locale.languageCode),
        items: entry.value,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final groups = groupedStores;
    
    final categoryNames = _categories.map((c) => c.getName(context.locale.languageCode)).toList();

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: CustomAppBar(
        title: 'smart_mall_guide'.tr(),
        categories: categoryNames,
        onCategorySelected: (cat) {
          setState(() {
            searchQuery = cat;
            searchController.text = cat;
          });
        },
        onProfilePressed: widget.onProfilePressed,
      ),
      body: _isLoading
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
                        onPressed: _loadData,
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    CustomSearchBar(
                      controller: searchController,
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),

                    Expanded(
                      child: groups.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isEmpty ? 'no_stores'.tr() : 'no_results'.tr(),
                                style: textTheme.bodyLarge,
                              ),
                            )
                          : ListView.builder(
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                final group = groups[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Text(
                                        group.title,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: group.items.length,
                                        itemBuilder: (context, i) {
                                          final store = group.items[i];
                                          return Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: i == 0 ? 16 : 10,
                                              end: i == group.items.length - 1 ? 16 : 0,
                                            ),
                                            child: StoreCard(
                                              store: store,
    onDirectionsPressed: () => _requestDirections(store.id), // ✅ تمرير store.id
                                                                                    )                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

// 🔹 بطاقة المتجر
class StoreCard extends StatefulWidget {
  final StoreDto store;
  final VoidCallback? onDirectionsPressed; // ✅ إضافة هذا

  const StoreCard({
    super.key, 
    required this.store,
    this.onDirectionsPressed, // ✅ إضافة هذا
  });

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = context.locale.languageCode;
    final imageUrl = widget.store.imageUrl ?? '';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.95),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: () async {
          // ✅ انتظار النتيجة من StoreDetailsScreen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreDetailsScreen(storeId: widget.store.id),
            ),
          );
          
          // ✅ إذا تم طلب الاتجاهات، قم باستدعاء المعالج
          if (result != null && result['navigateToMap'] == true && widget.onDirectionsPressed != null) {
            widget.onDirectionsPressed!();
          }
        },
                  child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.1), BlendMode.darken),
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/images/placeholder.png'),
                      fit: BoxFit.cover,
                    ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.store.getName(locale),
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 🔹 فئة تجميع الفئات
class CategoryGroup {
  final String title;
  final List<StoreDto> items;
  CategoryGroup({required this.title, required this.items});
}