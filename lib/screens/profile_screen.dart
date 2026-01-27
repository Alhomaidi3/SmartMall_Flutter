import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatelessWidget {
  final void Function(bool) onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,

      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'profile'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
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
                color: scheme.surface,
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
                        'Abdulrahman Alhomaidi',
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
                          color: scheme.onSurface.withValues(alpha: 0.6),
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
              trailing: const Icon(Icons.warning, color: Colors.red, size: 18),
            ),
            SettingsTile(
              icon: Icons.bookmark_border,
              title: 'saved_beneficiary'.tr(),
              subtitle: 'manage_saved_account'.tr(),
            ),

            /// 🎨 Appearance
            SettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'appearance'.tr(),
              subtitle: 'switch_theme'.tr(),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: onThemeChanged,
                activeThumbColor: Colors.orange,
              ),
            ),

            /// 🌐 Language
            SettingsTile(
              icon: Icons.language,
              title: 'language'.tr(),
              subtitle: 'change_language'.tr(),
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
            ),

            SettingsTile(
              icon: Icons.logout,
              title: 'logout'.tr(),
              subtitle: 'signout_account'.tr(),
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
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: 'about_app'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Settings Tile Widget
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSurface),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          trailing ??
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
        ],
      ),
    );
  }
}
