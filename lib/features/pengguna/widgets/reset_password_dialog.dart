import 'package:flutter/material.dart';

import '../../../data/models/pengguna.dart';
import '../../../globals/app_navigator.dart';

/// Dialog input password baru. Return password string kalau admin
/// konfirmasi, atau `null` kalau batal.
class ResetPasswordDialog extends StatefulWidget {
  final Pengguna target;
  const ResetPasswordDialog({super.key, required this.target});

  static Future<String?> show(Pengguna target) {
    final ctx = AppNavigator.context;
    if (ctx == null) return Future.value(null);
    return showDialog<String>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => ResetPasswordDialog(target: target),
    );
  }

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter.');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password baru untuk ${widget.target.nama} (${widget.target.email})',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Password baru',
                border: const OutlineInputBorder(),
                errorText: _error,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            const Text(
              'User akan otomatis logout dari semua sesi aktif.',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
