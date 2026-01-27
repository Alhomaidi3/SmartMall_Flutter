import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final void Function(bool) onThemeChanged;
  final void Function(String) onLanguageChanged;

  const ProfileScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface, // ✅ بدل background

      appBar: AppBar(
        backgroundColor: scheme.surface, // ✅ بدل background
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface, // ✅ بدل onBackground
          ),
        ),
        iconTheme: IconThemeData(color: scheme.onSurface), // ✅ بدل onBackground
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
                          color: scheme.onSurface.withValues(alpha: 0.6), // ✅ الجديد
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
              'Account',
              style: TextStyle(
                color: scheme.onSurface, // ✅ بدل onBackground
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SettingsTile(
              icon: Icons.person_outline,
              title: 'My Account',
              subtitle: 'Make changes to your account',
              trailing: Icon(Icons.warning, color: Colors.red, size: 18),
            ),
            SettingsTile(
              icon: Icons.bookmark_border,
              title: 'Saved Beneficiary',
              subtitle: 'Manage your saved account',
            ),

            /// 🎨 Appearance
            SettingsTile(
              icon: Icons.color_lens_outlined,
              title: 'Appearance',
              subtitle: 'Switch between dark and light mode',
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (val) => onThemeChanged(val),
                activeThumbColor: Colors.orange,
              ),
            ),

            /// 🌐 Language
            SettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'Change app language',
              trailing: DropdownButton<String>(
                value: Localizations.localeOf(context).languageCode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (val) {
                  if (val != null) onLanguageChanged(val);
                },
              ),
            ),

            SettingsTile(
              icon: Icons.logout,
              title: 'Log out',
              subtitle: 'Sign out from this account',
            ),

            const SizedBox(height: 24),

            /// ℹ More Section
            Text(
              'More',
              style: TextStyle(
                color: scheme.onSurface, // ✅ بدل onBackground
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: 'About App',
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
                      color: scheme.onSurface.withValues(alpha: 0.7), // ✅ الجديد
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          trailing ??
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: scheme.onSurface.withValues(alpha: 0.6)), // ✅ الجديد
        ],
      ),
    );
  }
}
