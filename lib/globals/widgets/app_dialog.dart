import 'package:flutter/material.dart';
import 'package:antrian/globals/app_navigator.dart';

class AppDialog {
  /// ================= LOADING =================
  static Future<void> loading({String? message}) {
    final context = AppNavigator.context;
    if (context == null) return Future.value();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ],
        ),
      ),
    );
  }

  static void close() {
    AppNavigator.navigator?.pop();
  }

  /// ================= BASIC =================
  static Future<bool?> basic({
    required String title,
    required String message,
    String? positiveText,
    String? negativeText,
  }) {
    final context = AppNavigator.context;
    if (context == null) return Future.value(false);

    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (negativeText != null)
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(negativeText),
            ),
          if (positiveText != null)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(positiveText),
            ),
        ],
      ),
    );
  }

  /// ================= ERROR =================
  static Future<void> error({
    String title = "Terjadi Kesalahan",
    required String message,
  }) {
    final context = AppNavigator.context;
    if (context == null) return Future.value();

    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  /// ================= WARNING =================
  static Future<bool?> warning({
    required String message,
    String confirmText = "Ya",
    String cancelText = "Batal",
  }) {
    final context = AppNavigator.context;
    if (context == null) return Future.value(false);

    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text("Peringatan"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
