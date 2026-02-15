import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // البيانات التي تم إدخالها في التسجيل
    final String username = 'UserName'.tr();  // اسم المستخدم
    final String email = '@Alhomaidi';  // البريد الإلكتروني
    final String phone = '+973 33733531';  // رقم الهاتف
    final String gender = 'Male';  // الجنس
    final String dateOfBirth = '2004-01-01';  // تاريخ الميلاد

    // تحديد لون الخط بناءً على الوضع
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: CustomAppBar(
        title: 'my_account'.tr(),
        showBackButton: true,
        showProfileIcon: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // 👤 Account Info Card (اسم المستخدم + البريد الإلكتروني)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,  // اسم المستخدم المعروض
                        style: TextStyle(
                          color: textColor,  // تغيير اللون بناءً على الوضع
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,  // البريد الإلكتروني المعروض
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),  // تغيير اللون بناءً على الوضع
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 36),

            Text(
              'account_settings'.tr(),
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
                    _buildInfoRow('Phone Number', phone, textColor),
                    _buildInfoRow('Gender', gender, textColor),
                    _buildInfoRow('Date of Birth', dateOfBirth, textColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // زر لتعديل البيانات (إن أردت إضافته)
            SettingsTile(
              icon: Icons.edit,
              title: 'edit_profile'.tr(),
              isDark: isDark,
              onTap: () {
                // Navigation لتعديل الحساب
              },
            ),
            SettingsTile(
              icon: Icons.lock_outline,
              title: 'change_password'.tr(),
              isDark: isDark,
              onTap: () {
                // Navigation لتغيير كلمة المرور
              },
            ),
            SettingsTile(
              icon: Icons.notifications,
              title: 'notifications'.tr(),
              isDark: isDark,
              onTap: () {
                // Navigation لإعدادات الإشعارات
              },
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
