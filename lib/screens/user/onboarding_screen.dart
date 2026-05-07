import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
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
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 100),

                      Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 220,
                          height: 220,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        'app_title'.tr(),
                        style: textTheme.headlineMedium?.copyWith(
                          letterSpacing: 1.2,
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 40),

                      AnimatedButton(
                        text: 'signup'.tr(),
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                      ),

                      const SizedBox(height: 14),

                      AnimatedButton(
                        text: 'login'.tr(),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),

                      const SizedBox(height: 35),

                      Text(
                        'continue_with'.tr(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InteractiveSocialIcon(
                            icon: Icons.g_mobiledata,
                            color: const Color(0xFFDB4437),
                            url: 'https://www.google.com/',
                          ),
                          const SizedBox(width: 16),
                          InteractiveSocialIcon(
                            icon: Icons.travel_explore,
                            color: const Color(0xFF1DA1F2),
                            url: 'https://twitter.com/',
                          ),
                          const SizedBox(width: 16),
                          InteractiveSocialIcon(
                            icon: Icons.camera_alt,
                            color: const Color(0xFFE4405F),
                            url: 'https://www.instagram.com/',
                          ),
                          const SizedBox(width: 16),
                          InteractiveSocialIcon(
                            icon: Icons.facebook,
                            color: const Color(0xFF1877F2),
                            url: 'https://www.facebook.com/',
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
              elevation: 8,
            ),
            onPressed: widget.onPressed,
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InteractiveSocialIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String url;

  const InteractiveSocialIcon({
    required this.icon,
    required this.color,
    required this.url,
    super.key,
  });

  @override
  State<InteractiveSocialIcon> createState() => _InteractiveSocialIconState();
}

class _InteractiveSocialIconState extends State<InteractiveSocialIcon> {
  double _scale = 1.0;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    final confirmed = await _showConfirmationDialog(url);

    if (!mounted || !(confirmed ?? false)) return;

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

  Future<bool?> _showConfirmationDialog(String url) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('confirmation'.tr()),
        content: Text(
          '${'open_link_confirmation'.tr()}\n$url',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.85),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () => _launchUrl(widget.url),
      child: Transform.scale(
        scale: _scale,
        child: CircleAvatar(
          radius: 26,
          backgroundColor: widget.color,
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}