// widgets/filter_chips_row.dart
import 'package:flutter/material.dart';
import 'status_filter_chip.dart';
import 'package:easy_localization/easy_localization.dart';

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
            final isSelected = filter.value == selectedRole || filter.value == selectedStatus;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: StatusFilterChip(
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

enum ScrollDirection {
  horizontal,
  vertical,
}