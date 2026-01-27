import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _gender;
  final TextEditingController _dobController = TextEditingController();

  InputDecoration _decoration(String hint, {Widget? prefix, Widget? suffix}) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withOpacity(0.6),
          ),
      prefixIcon: prefix,
      suffixIcon: suffix,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: scheme.onSurface),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: scheme.primary),
      ),
    );
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
                const SizedBox(height: 10),

                Text(
                  'sign_up'.tr(),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),

                const SizedBox(height: 12),

                _buildProfileImage(size),

                const SizedBox(height: 12),

                _buildTextField('enter_your_name'.tr()),
                _buildTextField('email'.tr()),
                _buildTextField(
                  'phone_number'.tr(),
                  prefix: Icon(Icons.flag, color: scheme.onSurface, size: 18),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                _buildGenderDropdown(),

                _buildDateOfBirth(),

                _buildPasswordField(
                  'choose_password'.tr(),
                  _obscurePassword,
                  () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),

                _buildPasswordField(
                  'confirm_password'.tr(),
                  _obscureConfirmPassword,
                  () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),

                const SizedBox(height: 20),

                _buildCreateAccountButton(),

                const SizedBox(height: 6),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    'already_have_account'.tr(),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.7),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Text(
            'skip'.tr(),
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
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
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        decoration: _decoration(hint, prefix: prefix),
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
        decoration: _decoration('select_gender'.tr()),
        dropdownColor: scheme.surface,
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        items: [
          DropdownMenuItem(value: 'Male', child: Text('male'.tr())),
          DropdownMenuItem(value: 'Female', child: Text('female'.tr())),
        ],
        onChanged: (value) {
          setState(() => _gender = value);
        },
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
        decoration: _decoration(
          'date_of_birth'.tr(),
          suffix: Icon(Icons.calendar_today, color: scheme.onSurface, size: 18),
        ),
        onTap: _pickDate,
      ),
    );
  }

  Widget _buildPasswordField(
    String hint,
    bool obscure,
    VoidCallback onToggle,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        obscureText: obscure,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        decoration: _decoration(
          hint,
          suffix: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: scheme.onSurface,
              size: 18,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 50,
      width: 250,
      child: ElevatedButton(
        onPressed: () {},
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
