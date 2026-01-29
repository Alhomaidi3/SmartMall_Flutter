import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/data/data.dart';

class StoreDetailsScreen extends StatelessWidget {
  final StoreData store;

  const StoreDetailsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locale = context.locale; // 🔹 معرفة اللغة الحالية

    return Scaffold(
      // 🔹 استخدم نفس CustomAppBar مع سهم رجوع
      appBar: CustomAppBar(
        title: 'smart_mall_guide'.tr(),
        showBackButton: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40), 
            // 🔹 صورة المتجر
            SizedBox(
              width: double.infinity,
              height: 240,
              child: store.image.startsWith('http')
                  ? Image.network(store.image, fit: BoxFit.cover)
                  : Image.asset(store.image, fit: BoxFit.cover),
            ),

            const SizedBox(height: 16),

            // 🔹 محتوى الصفحة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المتجر حسب اللغة
                  Text(
                    locale.languageCode == 'ar' ? store.nameAr : store.nameEn,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // الوصف حسب اللغة
                  Text(
                    locale.languageCode == 'ar'
                        ? store.descriptionAr
                        : store.descriptionEn,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // التصنيف والطابق
                  Row(
                    children: [
                      Chip(label: Text(store.category.toUpperCase())),
                      const SizedBox(width: 12),
                      Chip(label: Text('Floor ${store.floor}')),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // التقييم
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text('${store.rating} (${store.ratingCount})'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // المميزات
                  Row(
                    children: [
                      if (store.hasLux) ...[
                        Icon(Icons.star, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text('Luxury', style: TextStyle(color: scheme.primary)),
                      ],
                      if (store.hasWifi) ...[
                        const SizedBox(width: 16),
                        Icon(Icons.wifi, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text('Wi-Fi', style: TextStyle(color: scheme.primary)),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // أوقات العمل
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 6),
                      Text('${store.openTime} - ${store.closeTime}'),
                      
                    ],
                  ),

                  const SizedBox(height: 12),

                  // الهاتف
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 20),
                      const SizedBox(width: 6),
                      Text(store.phone),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // الموقع الإلكتروني
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.link, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          store.website,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
