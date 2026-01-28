import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // استخدم getter بدل final لتطبيق الترجمة ديناميكيًا
  List<Category> get categories => [
        Category(
          title: 'supermarkets_title'.tr(),
          items: [
            Store(name: 'lulu'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'carrefour'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'ramez'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'aljazira'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'ansar'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'market24'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
        Category(
          title: 'shoes_title'.tr(),
          items: [
            Store(name: 'nike'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'adidas'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'skechers'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'puma'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'reebok'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'decathlon'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
        Category(
          title: 'women_title'.tr(),
          items: [
            Store(name: 'zara'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'hm'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'mango'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'bershka'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'stradivarius'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'max'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
        Category(
          title: 'men_title'.tr(),
          items: [
            Store(name: 'zara'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'hm'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'jack_jones'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'american_eagle'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'mango'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'centrepoint'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
        Category(
          title: 'kids_title'.tr(),
          items: [
            Store(name: 'mothercare'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'babyshop'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'centrepoint'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'carters'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'chicco'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'toysrus'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
        Category(
          title: 'perfumes_title'.tr(),
          items: [
            Store(name: 'sephora'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'faces'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'bodyshop'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'arabian_oud'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'abdulqurashi'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'ajmal'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
        Category(
          title: 'restaurants_title'.tr(),
          items: [
            Store(name: 'mcd'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'kfc'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'pizzahut'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'herfy'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'dominos'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'local_restaurant'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
        Category(
          title: 'cafes_title'.tr(),
          items: [
            Store(name: 'starbucks'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'dunkin'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'costa'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'cinnabon'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'krispy'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'local_cafe'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
        Category(
          title: 'electronics_title'.tr(),
          items: [
            Store(name: 'extra'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'jarir'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'stc'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'batelco'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'zain'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'samsung'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
        Category(
          title: 'home_title'.tr(),
          items: [
            Store(name: 'ikea'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'homecentre'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'homebox'.tr(), image: 'assets/images/store3.png'),
            Store(name: 'daiso'.tr(), image: 'assets/images/store1.jpg'),
            Store(name: 'miniso'.tr(), image: 'assets/images/store2.jpeg'),
            Store(name: 'ansar'.tr(), image: 'assets/images/store3.png'),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cats = categories; // كل النصوص مترجمة حسب اللغة الحالية

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
              itemCount: cats.length,
              itemBuilder: (context, index) {
                final category = cats[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            padding: EdgeInsetsDirectional.only(
                              start: i == 0 ? 16 : 10,
                              end: i == category.items.length - 1 ? 16 : 0,
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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            border: const Border(
              top: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: Text(
            store.name,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
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
