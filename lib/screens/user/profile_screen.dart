import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '/widgets/widgets.dart';
import 'account_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  final void Function(bool) onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.onThemeChanged,
  });
  Future<void> _launchUrl(BuildContext context, String url) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('confirmation'.tr()),
      content: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'open_link_confirmation'.tr() + '\n',  // إضافة فاصل بين النص والرابط
              style: TextStyle(color: textColor),
            ),
            TextSpan(
              text: url,  // الرابط الفعلي
              style: TextStyle(color: Colors.blue),  // استخدام اللون المناسب
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('ok'.tr()),
        ),
      ],
    ),
  );

  if (confirmed ?? false) {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cannot_launch'.tr())),
      );
    }
  }
}

Future<bool> _confirmAction(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title.tr()),
      content: Text(
        message.tr(),
        style: TextStyle(color: textColor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('ok'.tr()),
        ),
      ],
    ),
  );

  return result ?? false;
}

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,

      appBar: CustomAppBar(
  title: 'profile'.tr(),
  showProfileIcon: false,     // ✅ لا يظهر أيقونة بروفايل (احنا فيها)
  onProfilePressed: null,     // ✅ غير مطلوب
),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 Profile Card
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
                        'UserName'.tr(),
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@Alhomaidi',
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ⚙ Account Section
            Text(
              'account'.tr(),
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SettingsTile(
              icon: Icons.person_outline,
              title: 'my_account'.tr(),
              subtitle: 'make_changes_account'.tr(),
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.bookmark_border,
              title: 'saved_beneficiary'.tr(),
              subtitle: 'manage_saved_account'.tr(),
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),

            /// 🎨 Appearance
            SettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'appearance'.tr(),
              subtitle: 'switch_theme'.tr(),
              isDark: isDark,
              trailing: Switch(
                value: isDark,
                onChanged: onThemeChanged,
                activeThumbColor: Colors.orange,
              ),
            ),

            /// 🌐 Language
            SettingsTile(
              icon: Icons.language,
              title: 'language'.tr(),
              subtitle: 'change_language'.tr(),
              isDark: isDark,
              trailing: DropdownButton<String>(
                value: context.locale.languageCode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    context.setLocale(Locale(val));
                  }
                },
              ),
              onTap: null, // هنا نلغي الضغط على Tile كله
            ),

            SettingsTile(
              icon: Icons.logout,
              title: 'logout'.tr(),
              subtitle: 'signout_account'.tr(),
              isDark: isDark,
              onTap: () async {
                final confirmed = await _confirmAction(
                  context,
                  title: 'confirmation',
                  message: 'logout_confirmation',
                );

                if (confirmed) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                }
              },
            ),


            const SizedBox(height: 24),

            /// ℹ More Section
            Text(
              'more'.tr(),
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SettingsTile(
              icon: Icons.help_outline,
              title: 'help_support'.tr(),
              isDark: isDark,
              onTap: () => _launchUrl(context, 'https://www.google.com'),
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: 'about_app'.tr(),
              isDark: isDark,
              onTap: () => _launchUrl(context, 'https://www.google.com'),
            ),
          ],
        ),
      ),
    );
  }
}
