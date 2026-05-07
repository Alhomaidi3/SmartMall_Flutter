import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _gender;
  bool _isLoading = false;
  double _scale = 1.0;
  
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty) {
      showMessage(context, 'name_required'.tr(), type: MessageType.error);
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      showMessage(context, 'email_required'.tr(), type: MessageType.error);
      return;
    }
    
    if (!_emailController.text.contains('@')) {
      showMessage(context, 'invalid_email'.tr(), type: MessageType.error);
      return;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      showMessage(context, 'phone_required'.tr(), type: MessageType.error);
      return;
    }
    
    if (_gender == null) {
      showMessage(context, 'gender_required'.tr(), type: MessageType.error);
      return;
    }
    
    if (_dobController.text.isEmpty) {
      showMessage(context, 'date_of_birth_required'.tr(), type: MessageType.error);
      return;
    }

    if (_passwordController.text.isEmpty) {
      showMessage(context, 'password_required'.tr(), type: MessageType.error);
      return;
    }
    
    if (_passwordController.text.length < 6) {
      showMessage(context, 'password_too_short'.tr(), type: MessageType.error);
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      showMessage(context, 'passwords_not_match'.tr(), type: MessageType.error);
      return;
    }

    setState(() => _isLoading = true);
      try {
      final response = await _apiService.post(
        '/users/register',
        {
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'phone': _phoneController.text.trim(),
          'gender': _gender,
          'dateOfBirth': _formatDateForApi(_dobController.text),
        },
        requiresAuth: false,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        final data = response['data'];

        await StorageService.saveToken(data['token']);
        await StorageService.saveUser(data['user']);

        if (!mounted) return;

        showMessage(
          context,
          'account_created_successfully'.tr(),
          type: MessageType.success,
        );

        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (!mounted) return;

        final errorMessage =
            response['message'] ?? 'registration_failed'.tr();

        showMessage(
          context,
          errorMessage,
          type: MessageType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage;

      if (e is ApiException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');

        if (errorMessage.isEmpty || errorMessage == 'Unknown error') {
          errorMessage = 'network_error'.tr();
        }
      }

      showMessage(
        context,
        errorMessage,
        type: MessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateForApi(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('/');
    if (parts.length == 3) {
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      return '$year-$month-${day}T00:00:00Z';
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Text(
                  'sign_up'.tr(),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 100),
                _buildProfileImage(size),
                const SizedBox(height: 50),
                _buildTextField('enter_your_name'.tr(), controller: _nameController),
                _buildTextField('email'.tr(), controller: _emailController, keyboardType: TextInputType.emailAddress),
                _buildTextField(
                  'phone_number'.tr(),
                  controller: _phoneController,
                  prefix: Icon(Icons.flag, color: scheme.onSurface, size: 18),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                _buildGenderDropdown(),
                _buildDateOfBirth(),
                _buildPasswordField(
                  'choose_password'.tr(),
                  _obscurePassword,
                  () => setState(() => _obscurePassword = !_obscurePassword),
                  controller: _passwordController,
                ),
                _buildPasswordField(
                  'confirm_password'.tr(),
                  _obscureConfirmPassword,
                  () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCreateAccountButton(),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(
                    'already_have_account'.tr(),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            iconSize: 26,
            padding: const EdgeInsets.all(12),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            ),
            icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: Text('skip'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(Size size) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      children: [
        Container(
          width: size.width * 0.20,
          height: size.width * 0.20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surfaceContainerHighest,
          ),
          child: Icon(Icons.person, color: scheme.onSurface, size: 36),
        ),
        const SizedBox(height: 4),
        Text(
          'upload_profile_picture'.tr(),
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String hint, {
    Widget? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextEditingController? controller,
  }) {
    final scheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: prefix,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.onSurface),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: _gender,
        decoration: InputDecoration(
          hintText: 'select_gender'.tr(),
          hintStyle: textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.onSurface),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.primary),
          ),
        ),
        dropdownColor: scheme.surface,
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        items: const [
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Female', child: Text('Female')),
        ],
        onChanged: (value) => setState(() => _gender = value),
      ),
    );
  }

  Widget _buildDateOfBirth() {
    final scheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: _dobController,
        readOnly: true,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: 'date_of_birth'.tr(),
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: scheme.onSurface, size: 18),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.onSurface),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.primary),
          ),
        ),
        onTap: _pickDate,
      ),
    );
  }

  Widget _buildPasswordField(
    String hint,
    bool obscure,
    VoidCallback onToggle, {
    TextEditingController? controller,
  }) {
    final scheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: scheme.onSurface,
              size: 18,
            ),
            onPressed: onToggle,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.onSurface),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: scheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: _register,
      child: Transform.scale(
        scale: _scale,
        child: SizedBox(
          height: 50,
          width: 250,
          child: ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text('create_account'.tr()),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );

    if (date != null) {
      _dobController.text = '${date.day}/${date.month}/${date.year}';
    }
  }
}