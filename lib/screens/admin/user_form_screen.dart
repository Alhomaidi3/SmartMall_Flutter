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
  DateTime? _selectedDate;
  String? _selectedRole;
  bool _isActive = true;
  bool _isEditing = false;
  bool _isLoading = false;
  
  final UserService _userService = UserService();
  
  final List<String> _roles = ['user', 'admin'];
  final List<String> _genders = ['male', 'female'];
  
  bool _isCurrentUserAdmin = false;
  bool _isLoadingCurrentUser = true;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.user != null;
    
    _fullNameController = TextEditingController(text: widget.user?.fullName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _genderController = TextEditingController(text: widget.user?.gender ?? '');
    _selectedDate = widget.user?.dateOfBirth;
    _selectedRole = widget.user?.role.toLowerCase() ?? 'user';
    _isActive = widget.user?.isActive ?? true;
    
    _checkIfCurrentUserIsAdmin();
  }
  
  Future<void> _checkIfCurrentUserIsAdmin() async {
    setState(() => _isLoadingCurrentUser = true);
    try {
      final currentUser = await _userService.getCurrentUser();
      setState(() {
        _isCurrentUserAdmin = currentUser.role.toLowerCase() == 'admin';
        _isLoadingCurrentUser = false;
      });
    } catch (e) {
      setState(() {
        _isCurrentUserAdmin = false;
        _isLoadingCurrentUser = false;
      });
    }
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
        final updateData = {
          'fullName': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'gender': _genderController.text.trim(),
          'dateOfBirth': _selectedDate?.toIso8601String(),
        };
        
        if (_isCurrentUserAdmin) {
          await _userService.updateUser(widget.user!.id, updateData);
          
          if (_isActive != widget.user!.isActive) {
            await _userService.toggleUserStatus(widget.user!.id, _isActive);
          }
          if (_selectedRole != widget.user!.role.toLowerCase()) {
            await _userService.changeUserRole(
              widget.user!.id,
              _selectedRole!.toLowerCase(),
            );
          }
        } else {
          await _userService.updateProfile(updateData);
        }

        if (mounted) {
          showMessage(context, 'user_updated'.tr(), type: MessageType.success);
          Navigator.pop(context, true);
        }
      } else {
        showMessage(
          context,
          'add_user_feature_coming'.tr(),
          type: MessageType.info,
        );
      }
    } catch (e) {
      if (mounted) {
        showMessage(
          context,
          e.toString().replaceAll('Exception: ', ''),
          type: MessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser() async {
    if (!_isCurrentUserAdmin) {
      showMessage(
        context,
        'only_admin_can_delete'.tr(),
        type: MessageType.warning,
      );
      return;
    }

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
          showMessage(context, 'user_deleted'.tr(), type: MessageType.success);
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          showMessage(
            context,
            e.toString().replaceAll('Exception: ', ''),
            type: MessageType.error,
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

  void _toggleActive() {
    setState(() {
      _isActive = !_isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_isLoadingCurrentUser) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: CustomAppBar(
          title: _isEditing ? 'edit_user'.tr() : 'add_user'.tr(),
          showBackButton: true,
          showProfileIcon: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                    _buildAvatar(),

                    const SizedBox(height: 32),

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
                      readOnly: true,
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
                    
                    const SizedBox(height: 16),

                    _buildDatePicker(),

                    if (_isCurrentUserAdmin) ...[
                      const SizedBox(height: 24),

                      SectionTitle(title: 'role_info'.tr()),
                      const SizedBox(height: 16),
                      
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
                                  color: scheme.primary,
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
                    ],

                    const SizedBox(height: 40),

                    UnifiedButton.form(
                      onPressed: _saveUser,
                      text: _isEditing ? 'update_user'.tr() : 'create_user'.tr(),
                      icon: Icons.save,
                    ),

                    if (_isEditing && _isCurrentUserAdmin) ...[
                      const SizedBox(height: 16),

                      UnifiedButton.form(
                        onPressed: _toggleActive,
                        text: _isActive ? 'deactivate'.tr() : 'activate'.tr(),
                        isDestructive: _isActive,
                        icon: _isActive ? Icons.block : Icons.check_circle,
                      ),

                      const SizedBox(height: 16),

                      UnifiedButton.form(
                        onPressed: _deleteUser,
                        text: 'delete_user'.tr(),
                        isDestructive: true,
                        isOutlined: true,
                        icon: Icons.delete_outline,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvatar() {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
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
                      errorBuilder: (_, _, _) => Icon(
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
                    showMessage(
                      context,
                      'feature_coming_soon'.tr(),
                      type: MessageType.info,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final scheme = Theme.of(context).colorScheme;
    final displayDate = _selectedDate ?? widget.user?.dateOfBirth;
    
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: displayDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: scheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayDate != null
                    ? DateFormat('yyyy-MM-dd').format(displayDate)
                    : 'date_of_birth'.tr(),
                style: TextStyle(
                  color: displayDate != null
                      ? scheme.onSurface
                      : scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: scheme.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}