import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكد من أنك أضفت هذه المكتبة

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
            Align(
              alignment: AlignmentDirectional.topEnd, // ✅ يتغير حسب اتجاه اللغة
              child: Padding(
                padding: const EdgeInsets.all(16.0), // بدل الـ top و right
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Text('skip'.tr()),
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
                      const SizedBox(height: 200),
                      Hero(
                        tag: 'logo', // ✅ نفس التاج يستخدم في كل الشاشات
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 220,
                          height: 220,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'app_title'.tr(), // ✅ مفتاح الترجمة
                        style: textTheme.headlineMedium?.copyWith(
                          letterSpacing: 1.2,
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
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InteractiveSocialIcon(
                            icon: Icons.g_mobiledata,
                            color: Color(0xFFDB4437),
                            url: 'https://www.google.com/', // رابط Google
                          ),
                          SizedBox(width: 16),
                          InteractiveSocialIcon(
                            icon: Icons.travel_explore,
                            color: Color(0xFF1DA1F2),
                            url: 'https://twitter.com/', // رابط Twitter
                          ),
                          SizedBox(width: 16),
                          InteractiveSocialIcon(
                            icon: Icons.camera_alt,
                            color: Color(0xFFE4405F),
                            url: 'https://www.instagram.com/', // رابط Instagram
                          ),
                          SizedBox(width: 16),
                          InteractiveSocialIcon(
                            icon: Icons.facebook,
                            color: Color(0xFF1877F2),
                            url: 'https://www.facebook.com/', // رابط Facebook
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
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 16,        // ⬅️ هنا تحدد الحجم
                fontWeight: FontWeight.w600,
              ),
            ),
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
  final String url; // رابط الشبكة الاجتماعية

  const InteractiveSocialIcon({required this.icon, required this.color, required this.url, super.key});

  @override
  State<InteractiveSocialIcon> createState() => _InteractiveSocialIconState();
}

class _InteractiveSocialIconState extends State<InteractiveSocialIcon> {
  double _scale = 1.0;

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    final confirmed = await _showConfirmationDialog(context, url); // رسالة تأكيد قبل فتح الرابط

    if (confirmed ?? false) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('cannot_launch'.tr())),
        );
      }
    }
  }

  // دالة لإظهار نافذة تأكيد قبل فتح الرابط
  Future<bool?> _showConfirmationDialog(BuildContext context, String url) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('confirmation'.tr()),
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'open_link_confirmation'.tr() + '\n', // النص المترجم
              style: TextStyle(color: textColor),
                ),
                TextSpan(
                  text: url, // الرابط الفعلي
                  style: TextStyle(color: Colors.blue), // النص باللون الأزرق
                ),
              ],
            ),
          ),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.85),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () => _launchUrl(context, widget.url),  // استخدام الرابط هنا
      child: Transform.scale(
        scale: _scale,
        child: CircleAvatar(
          radius: 26,
          backgroundColor: widget.color,
          child: Icon(widget.icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
