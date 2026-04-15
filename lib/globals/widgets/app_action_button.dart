import 'package:flutter/material.dart';

class AppActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final double size;
  final double iconSize;

  const AppActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.size = 28,
    this.iconSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFFCA5A5)
                : const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isDestructive
              ? const Color(0xFFEF4444)
              : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}
