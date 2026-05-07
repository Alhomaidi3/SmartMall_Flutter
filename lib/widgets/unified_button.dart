// lib/widgets/unified_button.dart 
import 'package:flutter/material.dart';

class UnifiedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final bool fullWidth;

  const UnifiedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDestructive = false,
    this.width,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.fullWidth = false,
  });

  factory UnifiedButton.primary({
    required String text,
    required VoidCallback onPressed,
    double width = 250,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return UnifiedButton(
      onPressed: onPressed,
      text: text,
      width: width,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  factory UnifiedButton.form({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isOutlined = false,
    bool isDestructive = false,
  }) {
    return UnifiedButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      isOutlined: isOutlined,
      isDestructive: isDestructive,
      fullWidth: true,
      height: 55,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveWidth = fullWidth ? double.infinity : (width ?? 200);
    final effectiveBgColor = backgroundColor ?? 
        (isDestructive ? Colors.red : scheme.primary);
    final effectiveTextColor = textColor ?? scheme.onPrimary;

    Widget button;

    if (isOutlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDestructive ? Colors.red : scheme.primary,
          side: BorderSide(
            color: isDestructive ? Colors.red : scheme.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: Size(effectiveWidth, height),
        ),
        child: _buildChild(context, effectiveTextColor, isOutlined: true),
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
          minimumSize: Size(effectiveWidth, height),
        ),
        child: _buildChild(context, effectiveTextColor),
      );
    }

    if (!fullWidth && width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }

  Widget _buildChild(BuildContext context, Color defaultTextColor, {bool isOutlined = false}) {
    final scheme = Theme.of(context).colorScheme;
    
    if (isLoading) {
      final loaderColor = isOutlined ? scheme.primary : Colors.white;
      
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: defaultTextColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: defaultTextColor,
            fontSize: height == 55 ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}