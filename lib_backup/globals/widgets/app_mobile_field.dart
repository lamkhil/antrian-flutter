import 'package:flutter/material.dart';

class AppMobileField extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const AppMobileField({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? const Color(0xFF111827),
            fontWeight: valueColor != null
                ? FontWeight.w500
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
