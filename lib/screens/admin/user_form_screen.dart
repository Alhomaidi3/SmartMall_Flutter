import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/services/user_service.dart';
import '/models/user.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _genderController;
  
  String? _selectedRole;
  bool _isActive = true;
  bool _isEditing = false;
  bool _isLoading = false;
  
  final UserService _userService = UserService();
  
  final List<String> _roles = ['user', 'admin'];
  final List<String> _genders = ['male', 'female'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.user != null;
    
    _fullNameController = TextEditingController(text: widget.user?.fullName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _genderController = TextEditingController(text: widget.user?.gender ?? '');
    
    _selectedRole = widget.user?.role.toLowerCase() ?? 'user';
    _isActive = widget.user?.isActive ?? true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    super.dispose();
  }

Future<void> _saveUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    if (_isEditing) {
      // بيانات عامة
      final updateData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _genderController.text.trim(),
      };
      
      // تحديث البيانات العامة
      await _userService.updateUser(widget.user!.id, updateData);

      // تحديث الحالة فقط إذا تغيرت
      if (_isActive != widget.user!.isActive) {
        await _userService.toggleUserStatus(widget.user!.id, _isActive);
      }

      // تغيير الدور إذا تغير
      if (_selectedRole != widget.user!.role.toLowerCase()) {
        await _userService.changeUserRole(
          widget.user!.id,
          _selectedRole!.toLowerCase(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('user_updated'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      // إضافة مستخدم جديد (قيد التطوير)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('add_user_feature_coming'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
  Future<void> _deleteUser() async {
    final confirmed = await _confirmAction(
      title: 'delete_user'.tr(),
      message: 'delete_user_confirmation'.tr(args: [_fullNameController.text]),
      isDestructive: true,
    );

    if (confirmed) {
      setState(() => _isLoading = true);
      
      try {
        await _userService.deleteUser(widget.user!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('user_deleted'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required bool isDestructive,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(isDestructive ? 'delete'.tr() : 'confirm'.tr()),
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
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: _isEditing ? 'edit_user'.tr() : 'add_user'.tr(),
        showBackButton: true,
        showProfileIcon: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Avatar
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.primary,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: widget.user?.profileImageUrl != null
                                  ? Image.network(
                                      widget.user!.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        size: 60,
                                        color: scheme.primary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 60,
                                      color: scheme.primary,
                                    ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('feature_coming_soon'.tr())),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Personal Info
                    SectionTitle(title: 'personal_info'.tr()),
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _fullNameController,
                      label: 'full_name'.tr(),
                      icon: Icons.person_outline,
                      isRequired: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _emailController,
                      label: 'email'.tr(),
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required_field'.tr();
                        }
                        if (!value.contains('@')) {
                          return 'invalid_email'.tr();
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _phoneController,
                      label: 'phone_number'.tr(),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Gender Dropdown
                    UnifiedDropdown<String>(
                      value: _genderController.text.isNotEmpty 
                          ? _genderController.text.toLowerCase() 
                          : null,
                      items: _genders.map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender.tr()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _genderController.text = value ?? '';
                        });
                      },
                      label: 'gender'.tr(),
                      icon: Icons.person_outline,
                      isRequired: true,
                    ),

                    const SizedBox(height: 24),

                    // Role Info
                    SectionTitle(title: 'role_info'.tr()),
                    const SizedBox(height: 16),
                    
                    // Role Dropdown
                    UnifiedDropdown<String>(
                      value: _selectedRole,
                      items: _roles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Row(
                            children: [
                              Icon(
                                role == 'admin' 
                                    ? Icons.admin_panel_settings 
                                    : Icons.person_outline,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(role.tr()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                      label: 'role'.tr(),
                      icon: _selectedRole == 'admin' 
                          ? Icons.admin_panel_settings 
                          : Icons.person_outline,
                      isRequired: true,
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    UnifiedFormButton(
                      onPressed: _saveUser,
                      text: _isEditing ? 'update_user'.tr() : 'create_user'.tr(),
                      icon: Icons.save,
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 16),
                                          
                      // Enable/Disable Button
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isActive = !_isActive; // تغيير الحالة محلياً فقط
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !(_isActive) ? Colors.green : Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              !(_isActive) ? 'active'.tr() : 'inactive'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Delete Button
                      UnifiedFormButton(
                        onPressed: _deleteUser,
                        text: 'delete_user'.tr(),
                        isOutlined: true,
                        isDestructive: true,
                        icon: Icons.delete_outline,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}