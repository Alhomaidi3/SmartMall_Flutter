import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/data/data.dart';

class StoreDetailsScreen extends StatefulWidget {
  final StoreData store;

  const StoreDetailsScreen({super.key, required this.store});

  @override
  _StoreDetailsScreenState createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  bool isFavorite = false; // متغير لتتبع حالة المفضلة

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });

    // هنا يمكن إضافة منطق لتخزين المتاجر المفضلة، مثل تخزين في SharedPreferences أو قاعدة بيانات.
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme; // استخدم colorScheme للحصول على ألوان الثيم
    final isDark = Theme.of(context).brightness == Brightness.dark; // تحديد الوضع الداكن أو الفاتح
    final locale = context.locale; // 🔹 معرفة اللغة الحالية

    final textColor = isDark ? Colors.white : Colors.black; // تحديد لون النص بناءً على الوضع

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white, // الخلفية بناءً على الوضع
      appBar: CustomAppBar(
        title: 'smart_mall_guide'.tr(),
        showBackButton: true,
        showProfileIcon: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),  // مسافة padding موحدة
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 👤 Store Info Card (اسم المتجر + الوصف)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة المتجر
                  SizedBox(
                    width: double.infinity,
                    height: 240,
                    child: widget.store.image.startsWith('http')
                        ? Image.network(widget.store.image, fit: BoxFit.cover)
                        : Image.asset(widget.store.image, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),

                  // اسم المتجر حسب اللغة
                  Text(
                    locale.languageCode == 'ar' ? widget.store.nameAr : widget.store.nameEn,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,  // تغيير اللون بناءً على الوضع
                    ),
                  ),
                  const SizedBox(height: 6),

                  // الوصف حسب اللغة
                  Text(
                    locale.languageCode == 'ar'
                        ? widget.store.descriptionAr
                        : widget.store.descriptionEn,
                    style: textTheme.bodyMedium?.copyWith(
                      color: textColor.withOpacity(0.7),  // تغيير اللون بناءً على الوضع
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'store_details'.tr(),
              style: TextStyle(
                color: textColor,  // تغيير اللون بناءً على الوضع
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // عرض الحقول المطلوبة داخل بطاقة واحدة
            Card(
              color: isDark ? Colors.grey[850] : Colors.grey[200],  // اللون الثابت المناسب
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Category', widget.store.category, textColor),
                    _buildInfoRow('Floor', widget.store.floor.toString(), textColor),
                    _buildInfoRow('Rating', '${widget.store.rating} (${widget.store.ratingCount})', textColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // عرض رقم الهاتف
            Card(
              color: isDark ? Colors.grey[850] : Colors.grey[200],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildInfoRow('Phone', widget.store.phone, textColor),
              ),
            ),

            const SizedBox(height: 18),

            // عرض الموقع الإلكتروني
            Card(
              color: isDark ? Colors.grey[850] : Colors.grey[200],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildInfoRow('Website', widget.store.website, textColor),
              ),
            ),

            const SizedBox(height: 24),

            // زر لتعديل المفضلة
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                onPressed: toggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isDark ? Colors.black : Colors.white, 
                ),
                label: Text(
                  isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,  // تغيير لون النص حسب الوضع
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFavorite ? scheme.secondary : scheme.primary, // تغيير اللون حسب الثيم
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget لعرض المعلومات داخل البطاقة الواحدة
  Widget _buildInfoRow(String title, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.tr(),  // عنوان الحقل (مثلاً "Phone Number")
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,  // تغيير اللون بناءً على الوضع
            ),
          ),
          Text(
            value,  // القيمة المعروضة (مثل "+1 234 567 890")
            style: TextStyle(
              fontSize: 16,
              color: textColor.withOpacity(0.7),  // تغيير اللون بناءً على الوضع
            ),
          ),
        ],
      ),
    );
  }
}
