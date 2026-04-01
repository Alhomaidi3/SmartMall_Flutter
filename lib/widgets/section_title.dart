// widgets/section_title.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final bool showSeeAll;

  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
    this.showSeeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showSeeAll) ...[
          const Spacer(),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'see_all'.tr(),
              style: TextStyle(
                color: scheme.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}