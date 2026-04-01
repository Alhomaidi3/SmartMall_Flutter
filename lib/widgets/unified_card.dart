// widgets/unified_card.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum CardType {
  category,
  store,
  user,
}

class UnifiedCard extends StatelessWidget {
  final CardType type;
  final dynamic data;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? customActions;
  final Color? customColor;
  final bool isActive;
  final String? statusLabel;
  final String title;
  final String subtitle;
  final String? secondaryInfo;
  final Widget? leading;
  final List<Widget>? additionalInfo;

  const UnifiedCard({
    super.key,
    required this.type,
    required this.data,
    required this.title,
    required this.isActive,
    this.onEdit,
    this.onDelete,
    this.customActions,
    this.customColor,
    this.statusLabel,
    this.subtitle = '',
    this.secondaryInfo,
    this.leading,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = type == CardType.user && data.isAdmin == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: !isActive
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1.5)
            : isAdmin
                ? Border.all(color: scheme.primary.withOpacity(0.3), width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading Widget
                  if (leading != null)
                    leading!
                  else
                    _buildDefaultLeading(context),
                  
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isAdmin)
                              _buildBadge(
                                label: 'admin'.tr(),
                                color: scheme.primary,
                              ),
                            if (!isActive)
                              _buildBadge(
                                label: statusLabel ?? 'inactive'.tr(),
                                color: Colors.red,
                              ),
                            if (isActive && statusLabel != null)
                              _buildBadge(
                                label: statusLabel!,
                                color: Colors.green,
                              ),
                          ],
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (additionalInfo?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          ...additionalInfo!,
                        ],
                      ],
                    ),
                  ),
                  
                  // Actions
                  if (customActions != null)
                    customActions!
                  else if (onEdit != null || onDelete != null)
                    _buildDefaultActions(context),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildDefaultLeading(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = customColor ?? scheme.primary;

    switch (type) {
      case CardType.category:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(title),
            color: color,
            size: 28,
          ),
        );
      case CardType.store:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: data.imageUrl != null
              ? Image.network(
                  data.imageUrl!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: Icon(Icons.store, color: Colors.grey[600]),
                  ),
                )
              : Container(
                  width: 70,
                  height: 70,
                  color: color.withOpacity(0.1),
                  child: Icon(Icons.store, color: color, size: 35),
                ),
        );
      case CardType.user:
        return Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: data.isAdmin == true
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: CircleAvatar(
            radius: 27,
            backgroundColor: Colors.transparent,
            child: data.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      data.profileImageUrl!,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        title[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Text(
                    title[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
    }
  }

  Widget _buildDefaultActions(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: Icon(Icons.edit_outlined, color: scheme.primary),
            onPressed: onEdit,
          ),
        if (onDelete != null)
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
      ],
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('cloth') || name.contains('fashion') || name.contains('wear')) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains('shoe') || name.contains('foot')) {
      return Icons.shopping_basket_outlined;
    } else if (name.contains('perfume') || name.contains('cosmetic')) {
      return Icons.spa_outlined;
    } else if (name.contains('electro') || name.contains('tech')) {
      return Icons.devices_outlined;
    } else if (name.contains('accessor')) {
      return Icons.watch_outlined;
    } else if (name.contains('restaurant') || name.contains('food')) {
      return Icons.restaurant_outlined;
    } else {
      return Icons.category_outlined;
    }
  }
}