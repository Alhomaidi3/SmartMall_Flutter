import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: CustomAppBar(
        title: 'saved_beneficiary'.tr(),
        showBackButton: true,
        showProfileIcon: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // 👤 Favorites Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.favorite, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UserName'.tr(),
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@Alhomaidi',
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 36),

            // عرض العناصر المفضلة
            for (var i = 1; i <= 5; i++)
              SettingsTile(
                icon: Icons.store,
                title: 'Favorite Shop $i',
                subtitle: 'Shop description $i',
                isDark: isDark,
                onTap: () {
                  // Navigation لتفاصيل العنصر
                },
              ),

            const SizedBox(height: 24),

            // زر لتعديل المفضلات أو خيارات أخرى
            SettingsTile(
              icon: Icons.edit,
              title: 'edit_favorites'.tr(),
              isDark: isDark,
              onTap: () {
                // Navigation لتعديل المفضلات
              },
            ),
            SettingsTile(
              icon: Icons.delete,
              title: 'remove_favorites'.tr(),
              isDark: isDark,
              onTap: () {
                // Navigation لإزالة المفضلات
              },
            ),
          ],
        ),
      ),
    );
  }
}
