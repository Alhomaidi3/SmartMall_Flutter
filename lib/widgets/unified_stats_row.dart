// widgets/unified_stats_row.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UnifiedStatsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final VoidCallback? onAddPressed;
  final String? addButtonText;
  final Widget? customAction;
  final Color? iconColor;

  const UnifiedStatsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    this.onAddPressed,
    this.addButtonText,
    this.customAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? scheme.primary).withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? scheme.primary, size: 18),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha:0.7),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          if (customAction != null)
            customAction!
          else if (onAddPressed != null)
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: Text(addButtonText ?? 'add'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
        ],
      ),
    );
  }
}