import 'package:flutter/material.dart';

enum MessageType { error, success, warning, info }

void showMessage(
  BuildContext context,
  String message, {
  MessageType type = MessageType.error,
}) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  Color iconColor;
  Color borderColor;
  IconData icon;

  switch (type) {
    case MessageType.success:
      iconColor = Colors.greenAccent.shade400;
      borderColor = Colors.greenAccent.shade200;
      icon = Icons.check_circle;
      break;

    case MessageType.warning:
      iconColor = Colors.orangeAccent.shade400;
      borderColor = Colors.orangeAccent.shade200;
      icon = Icons.warning_amber_rounded;
      break;

    case MessageType.info:
      iconColor = Colors.blueAccent.shade400;
      borderColor = Colors.blueAccent.shade200;
      icon = Icons.info_rounded;
      break;

    case MessageType.error:
      iconColor = Colors.redAccent.shade400;
      borderColor = Colors.redAccent.shade200;
      icon = Icons.error_rounded;
      break;
  }

  final containerColor =
      isDark ? Colors.grey[900]! : Colors.white;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),

      content: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: containerColor.withValues(alpha:0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha:0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}