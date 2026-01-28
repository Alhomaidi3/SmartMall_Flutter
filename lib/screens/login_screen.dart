import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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

                _buildLogo(size), // ✅ Hero مع نفس التاج

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
                ),

                const SizedBox(height: 25),

                _CustomTextField(
                  hint: 'enter_password'.tr(),
                  isPassword: true,
                ),

                const SizedBox(height: 35),

                // ✅ الزر مركزي وثابت الحجم
                Center(
                  child: AnimatedButton(
                    text: 'login'.tr(),
                    onPressed: () {
                      // هنا كود تسجيل الدخول
                    },
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
                        color: scheme.onSurface.withOpacity(0.7),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
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

  Widget _buildLogo(Size size) {
  return Center(
    child: Hero(
      tag: 'logo',
      child: Image.asset(
        'assets/images/logo.png',
        width: 220,  // ✅ حجم ثابت
        height: 220, // ✅ حجم ثابت
        fit: BoxFit.contain, // ✅ بدون تمدد
      ),
    ),
  );
}
}

// ---------- زر متحرك مثل Onboarding ----------
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const AnimatedButton({required this.text, required this.onPressed, super.key});

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
        width: 250,  // ✅ نفس حجم زر Login
        height: 50,  // ✅ نفس الارتفاع
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
              fontSize: 16,      // ✅ حجم الخط
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

// ---------- TextField مخصص ----------
class _CustomTextField extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.hint,
    this.isPassword = false,
    this.keyboardType,
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<_CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurface.withOpacity(0.6),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.onSurface),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.primary),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: scheme.onSurface,
                ),
                onPressed: () {
                  setState(() => _obscure = !_obscure);
                },
              )
            : null,
      ),
    );
  }
}
