import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/data/data.dart';
import '/screens/store_details_screen.dart';
import '/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController(); // ✅ Controller

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

  // 🔹 بناء التصنيفات مع البحث
  List<Category> get categories {
    final Map<String, List<StoreData>> grouped = {};
    final query = normalize(searchQuery);

    final filteredStores = storesData.where((store) {
      final nameAr = normalize(store.nameAr);
      final descAr = normalize(store.descriptionAr);
      final nameEn = store.nameEn.toLowerCase();
      final descEn = store.descriptionEn.toLowerCase();

      return nameAr.contains(query) ||
          descAr.contains(query) ||
          nameEn.contains(query) ||
          descEn.contains(query);
    }).toList();

    for (final store in filteredStores) {
      grouped.putIfAbsent(store.category, () => []);
      grouped[store.category]!.add(store);
    }

    return grouped.entries.map((entry) {
      return Category(
        title: '${entry.key}_title'.tr(),
        items: entry.value,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cats = categories;

    // 🔹 استخراج جميع الفئات لتمريرها إلى AppBar
    final allCategories = storesData.map((s) => s.category).toSet().toList();

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: CustomAppBar(
        title: 'smart_mall_guide'.tr(),
        categories: allCategories,
        onCategorySelected: (cat) {
          setState(() {
            searchQuery = cat;
            // ✅ كتابة اسم الفئة داخل مربع البحث
            searchController.text = cat.isEmpty ? '' : '${cat}_title'.tr();
          });
        },
      ),
      body: Column(
        children: [
          // 🔹 مربع البحث (مستقل من widgets.dart)
          CustomSearchBar(
            controller: searchController, // ✅ مرر الـ controller
            onChanged: (value) => setState(() => searchQuery = value),
          ),

          // 🔹 قائمة المتاجر
          Expanded(
            child: cats.isEmpty
                ? Center(
                    child: Text(
                      'no_results'.tr(),
                      style: textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: cats.length,
                    itemBuilder: (context, index) {
                      final category = cats[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              category.title,
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
                              itemCount: category.items.length,
                              itemBuilder: (context, i) {
                                final store = category.items[i];
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    start: i == 0 ? 16 : 10,
                                    end: i == category.items.length - 1 ? 16 : 0,
                                  ),
                                  child: StoreCard(store: store),
                                );
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
// 🔹 بطاقة المتجر مع تصميم أجمل
class StoreCard extends StatefulWidget {
  final StoreData store;
  const StoreCard({super.key, required this.store});

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = context.locale.languageCode;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.95),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreDetailsScreen(store: widget.store),
            ),
          );
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
              image: DecorationImage(
                image: NetworkImage(widget.store.image),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.1), BlendMode.darken),
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
                  locale == 'ar'
                      ? widget.store.nameAr
                      : widget.store.nameEn,
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

// 🔹 تصنيف المتاجر
class Category {
  final String title;
  final List<StoreData> items;
  Category({required this.title, required this.items});
}
