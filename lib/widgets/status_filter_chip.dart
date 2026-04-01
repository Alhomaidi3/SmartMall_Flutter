// widgets/status_filter_chip.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// تعريف FilterType داخل الملف نفسه
enum FilterType {
  single,
  multi,
}

class StatusFilterChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;
  final FilterType type;

  const StatusFilterChip({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
    this.selectedColor,
    this.type = FilterType.single,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _getIconColor(scheme);

    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: color,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[200],
      selectedColor: scheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? color : scheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: isSelected
            ? BorderSide(color: color, width: 1)
            : BorderSide.none,
      ),
    );
  }

  Color _getIconColor(ColorScheme scheme) {
    if (!isSelected) return scheme.onSurface.withOpacity(0.5);
    if (selectedColor != null) return selectedColor!;
    
    switch (value) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'admin':
        return Colors.blue;
      case 'user':
        return Colors.green;
      default:
        return scheme.primary;
    }
  }
}