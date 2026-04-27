import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/services/user_service.dart';
import '/models/user.dart';
import '/screens/admin/user_form_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final UserService _userService = UserService();
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

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
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: CustomAppBar(
        title: 'my_account'.tr(),
        showBackButton: true,
        showProfileIcon: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // 👤 Account Info Card
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _user?.email ?? '—',
                                    style: TextStyle(
                                      color: scheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_user?.isActive == false)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'inactive'.tr(),
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      Text(
                        'account_settings'.tr(),
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // معلومات الحساب
                      Card(
                        color: isDark ? Colors.grey[850] : Colors.grey[200],
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('full_name'.tr(), _user?.fullName ?? '—', scheme.onSurface),
                              const Divider(),
                              _buildInfoRow('email'.tr(), _user?.email ?? '—', scheme.onSurface),
                              const Divider(),
                              _buildInfoRow('phone_number'.tr(), _user?.phone ?? '—', scheme.onSurface),
                              const Divider(),
                              _buildInfoRow('gender'.tr(), _user?.gender?.tr() ?? '—', scheme.onSurface),
                              const Divider(),
                              _buildInfoRow('role'.tr(), _user?.role.tr() ?? '—', scheme.onSurface),
                              const Divider(),
                              _buildInfoRow('date_of_birth'.tr(), _formatDate(_user?.dateOfBirth), scheme.onSurface),
                              const Divider(),
                              _buildInfoRow('member_since'.tr(), _formatDate(_user?.createdAt), scheme.onSurface),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // أزرار الإجراءات
                      SettingsTile(
                        icon: Icons.edit,
                        title: 'edit_profile'.tr(),
                        isDark: isDark,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserFormScreen(user: _user),
                            ),
                          );
                          if (result == true) {
                            _loadUserProfile();
                          }
                        },
                      ),
                      SettingsTile(
                        icon: Icons.lock_outline,
                        title: 'change_password'.tr(),
                        isDark: isDark,
                        onTap: () {
                          // TODO: نافذة تغيير كلمة المرور
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('feature_coming_soon'.tr())),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String title, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}