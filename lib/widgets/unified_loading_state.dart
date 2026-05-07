// widgets/unified_loading_state.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UnifiedLoadingState extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final Widget child;
  final String? emptyIcon;
  final String? emptyTitle;
  final String? emptySubtitle;
  final VoidCallback? onRetry;

  const UnifiedLoadingState({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.child,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getEmptyIcon(),
                size: 60,
                color: scheme.primary.withValues(alpha:0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle ?? 'no_data_found'.tr(),
              style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha:0.7),
              ),
            ),
            if (emptySubtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                emptySubtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha:0.5),
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text('retry'.tr()),
              ),
            ],
          ],
        ),
      );
    }

    return child;
  }

  IconData _getEmptyIcon() {
    switch (emptyIcon) {
      case 'category':
        return Icons.category_outlined;
      case 'store':
        return Icons.store_outlined;
      case 'user':
        return Icons.people_outline;
      default:
        return Icons.inbox_outlined;
    }
  }
}