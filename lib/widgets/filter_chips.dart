import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum FilterType {
  single,
  multi,
}

enum ScrollDirection {
  horizontal,
  vertical,
}

class _StatusFilterChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Color? selectedColor;
  final FilterType type;

  const _StatusFilterChip({
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
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[200],
      selectedColor: scheme.primary.withValues(alpha:0.1),
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
    if (!isSelected) return scheme.onSurface.withValues(alpha:0.5);
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

class FilterChipData {
  final String value;
  final String? labelKey;
  final String? dynamicLabel;
  final IconData icon;
  final Color? selectedColor;

  const FilterChipData({
    required this.value,
    this.labelKey,
    this.dynamicLabel,
    required this.icon,
    this.selectedColor,
  }) : assert(
    labelKey != null || dynamicLabel != null,
    'Either labelKey or dynamicLabel must be provided'
  );

  String getLabel(BuildContext context) {
    if (dynamicLabel != null) return dynamicLabel!;
    if (labelKey != null) return labelKey!.tr();
    return '';
  }
}

class FilterChipsRow extends StatelessWidget {
  final List<FilterChipData> filters;
  final Function(String)? onSingleSelected;
  final ScrollDirection scrollDirection;
  final String? selectedRole;
  final String? selectedStatus;
  final String? filterGroup;

  const FilterChipsRow({
    super.key,
    required this.filters,
    this.onSingleSelected,
    this.scrollDirection = ScrollDirection.horizontal,
    this.filterGroup,
    this.selectedRole,
    this.selectedStatus,
  }) : assert(
    onSingleSelected != null,
    'Provide onSingleSelected callback'
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: SingleChildScrollView(
        scrollDirection: scrollDirection == ScrollDirection.horizontal
            ? Axis.horizontal
            : Axis.vertical,
        child: Row(
          children: filters.map((filter) {
            final isSelected = filter.value == selectedRole || 
                               filter.value == selectedStatus;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _StatusFilterChip(
                value: filter.value,
                label: filter.getLabel(context),
                icon: filter.icon,
                isSelected: isSelected,
                selectedColor: filter.selectedColor,
                type: FilterType.single,
                onSelected: (_) => onSingleSelected!(filter.value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}