import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '/widgets/widgets.dart';
import '/services/user_service.dart';
import '/models/user.dart';
import 'account_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  final void Function(bool) onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('confirmation'.tr()),
        content: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'open_link_confirmation'.tr()),
              TextSpan(
                text: '\n$url',
                style: const TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );

    if (!mounted || !(confirmed ?? false)) return;

    final uri = Uri.parse(url);

    final canLaunch = await canLaunchUrl(uri);

    if (!mounted) return;

    if (canLaunch) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      showMessage(
        context,
        'cannot_launch'.tr(),
        type: MessageType.error,
      );
    }
  }
    Future<bool> _confirmAction(
      BuildContext context, {
      required String title,
      required String message,
    }) async {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title.tr()),
          content: Text(message.tr()),
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

  Future<void> _logout() async {
    final confirmed = await _confirmAction(
      context,
      title: 'confirmation',
      message: 'logout_confirmation',
    );

    if (confirmed) {
      try {
        await _userService.logout();
      } catch (e) {
        // Ignore logout errors
      }
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: CustomAppBar(
        title: 'profile'.tr(),
        showProfileIcon: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserProfile,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(isDark, scheme),

                    const SizedBox(height: 24),

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
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AccountScreen()),
                        );
                        if (result == true) {
                          _loadUserProfile();
                        }
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

                    SettingsTile(
                      icon: Icons.color_lens_outlined,
                      title: 'appearance'.tr(),
                      subtitle: 'switch_theme'.tr(),
                      isDark: isDark,
                      trailing: Switch(
                        value: isDark,
                        onChanged: widget.onThemeChanged,
                        activeThumbColor: Colors.orange,
                      ),
                    ),

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
                      onTap: null,
                    ),

                    SettingsTile(
                      icon: Icons.logout,
                      title: 'logout'.tr(),
                      subtitle: 'signout_account'.tr(),
                      isDark: isDark,
                      onTap: _logout,
                    ),

                    const SizedBox(height: 24),

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
                      onTap: () => _launchUrl('https://www.google.com'),
                    ),
                    SettingsTile(
                      icon: Icons.info_outline,
                      title: 'about_app'.tr(),
                      isDark: isDark,
                      onTap: () => _launchUrl('https://www.google.com'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(bool isDark, ColorScheme scheme) {
    return Container(
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
            backgroundImage: _user?.profileImageUrl != null
                ? NetworkImage(_user!.profileImageUrl!)
                : null,
            child: _user?.profileImageUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user?.fullName ?? '—',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? '—',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (_user?.isActive == false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'inactive'.tr(),
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}