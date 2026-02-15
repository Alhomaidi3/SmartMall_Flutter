import 'package:flutter/material.dart';

/// 🎨 Interactive Settings Tile with full tap support
class SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.isDark,
    this.onTap,
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) => setState(() => _scale = 0.95);
  void _onTapUp(TapUpDetails _) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: (details) {
          _onTapUp(details);

          if (widget.trailing is Switch) {
            final switchWidget = widget.trailing as Switch;
            switchWidget.onChanged?.call(!switchWidget.value);
          }

          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[850] : Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: scheme.onSurface),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            color: scheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                widget.trailing ??
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}