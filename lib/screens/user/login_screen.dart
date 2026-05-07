import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../models/user.dart';
import '../../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty) {
      showMessage(context, 'email_required'.tr(), type: MessageType.error);
      return;
    }
    if (!_emailController.text.contains('@')) {
      showMessage(context, 'invalid_email'.tr(), type: MessageType.error);
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
    
    setState(() => _isLoading = true);
    
    try {
      final response = await _apiService.post(
        '/users/login',
        {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
        requiresAuth: false,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        final data = response['data'];

        await StorageService.saveToken(data['token']);
        await StorageService.saveUser(data['user']);

        final user = User.fromJson(data['user']);

        if (!mounted) return;

        showMessage(context, 'login_success'.tr(), type: MessageType.success);

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          user.isAdmin ? '/admin' : '/home',
        );
      } else {
        if (!mounted) return;

        showMessage(
          context,
          response['message'] ?? 'login_failed'.tr(),
          type: MessageType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceAll('Exception: ', '');
      showMessage(context, errorMessage, type: MessageType.error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: size.height - padding.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: size.height * 0.08),
                _buildLogo(size),
                const SizedBox(height: 25),
                Text(
                  'app_title'.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                
                _CustomTextField(
                  hint: 'email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 25),
                
                _CustomTextField(
                  hint: 'enter_password'.tr(),
                  isPassword: true,
                  controller: _passwordController,
                  onToggleObscure: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  obscure: _obscurePassword,
                ),
                const SizedBox(height: 35),
                
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : AnimatedButton(
                          text: 'login'.tr(),
                          onPressed: _login,
                        ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      "dont_have_account".tr(),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text('skip'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(Size size) {
    return Center(
      child: Hero(
        tag: 'logo',
        child: Image.asset(
          'assets/images/logo.png',
          width: 220,
          height: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const AnimatedButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: Transform.scale(
        scale: _scale,
        child: SizedBox(
          width: 250,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              shadowColor: scheme.shadow,
              elevation: 8,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: widget.onPressed,
            child: Text(widget.text),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  const _CustomTextField({
    required this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.controller,
    this.obscure = true,
    this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
      keyboardType: keyboardType,
      style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.6),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.onSurface),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.primary),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: scheme.onSurface,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }
}