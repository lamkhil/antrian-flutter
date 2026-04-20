import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  final String message;
  final double verticalPadding;

  const AppEmptyState({
    super.key,
    required this.message,
    this.verticalPadding = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
        ),
      ),
    );
  }
}
