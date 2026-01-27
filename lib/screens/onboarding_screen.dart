import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 16,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text(
                  'skip'.tr(), // ✅ مفتاح الترجمة
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 60),
                      Hero(
                        tag: 'logo', // ✅ نفس التاج يستخدم في كل الشاشات
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 180,
                          height: 180,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'app_title'.tr(), // ✅ مفتاح الترجمة
                        style: textTheme.headlineSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedButton(
                        text: 'signup'.tr(), // ✅ مفتاح الترجمة
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                      ),
                      const SizedBox(height: 14),
                      AnimatedButton(
                        text: 'login'.tr(), // ✅ مفتاح الترجمة
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                      const SizedBox(height: 35),
                      Text(
                        'continue_with'.tr(), // ✅ مفتاح الترجمة
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          InteractiveSocialIcon(
                            icon: Icons.g_mobiledata,
                            color: Color(0xFFDB4437),
                          ),
                          SizedBox(width: 16),
                          InteractiveSocialIcon(
                            icon: Icons.travel_explore,
                            color: Color(0xFF1DA1F2),
                          ),
                          SizedBox(width: 16),
                          InteractiveSocialIcon(
                            icon: Icons.camera_alt,
                            color: Color(0xFFE4405F),
                          ),
                          SizedBox(width: 16),
                          InteractiveSocialIcon(
                            icon: Icons.facebook,
                            color: Color(0xFF1877F2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر متحرك مع تأثير عند الضغط
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
            ),
            onPressed: widget.onPressed,
            child: Text(widget.text),
          ),
        ),
      ),
    );
  }
}

/// أيقونات التواصل الاجتماعي مع تأثير عند الضغط
class InteractiveSocialIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const InteractiveSocialIcon({required this.icon, required this.color, super.key});

  @override
  State<InteractiveSocialIcon> createState() => _InteractiveSocialIconState();
}

class _InteractiveSocialIconState extends State<InteractiveSocialIcon> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.85),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: Transform.scale(
        scale: _scale,
        child: CircleAvatar(
          radius: 22,
          backgroundColor: widget.color,
          child: Icon(widget.icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
