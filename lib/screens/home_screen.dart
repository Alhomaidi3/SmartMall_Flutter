import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Category> categories = List.generate(10, (catIndex) {
    return Category(
      title: 'category_title'.tr(args: ['${catIndex + 1}']),
      items: List.generate(6, (storeIndex) {
        return Store(
          name: 'store_name'.tr(args: ['${storeIndex + 1}']),
          image: storeIndex % 3 == 0
              ? 'assets/images/store1.jpg'
              : storeIndex % 3 == 1
                  ? 'assets/images/store2.jpeg'
                  : 'assets/images/store3.png',
        );
      }),
    );
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(title: 'smart_mall_guide'.tr()),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: CustomSearchBar(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        category.title,
                        style: textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: category.items.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: i == 0 ? 16 : 10,
                              right: i == category.items.length - 1 ? 16 : 0,
                            ),
                            child: StoreCard(store: category.items[i]),
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

class StoreCard extends StatelessWidget {
  final Store store;

  const StoreCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: AssetImage(store.image),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Text(
            store.name,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class Store {
  final String name;
  final String image;

  Store({required this.name, required this.image});
}

class Category {
  final String title;
  final List<Store> items;

  Category({required this.title, required this.items});
}
