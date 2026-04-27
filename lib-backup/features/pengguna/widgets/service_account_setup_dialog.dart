import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../data/services/admin/admin_sdk.dart';
import '../../../data/services/admin/service_account_storage.dart';
import '../../../globals/app_navigator.dart';

/// Dialog upload service-account JSON. Return `true` kalau berhasil disimpan.
///
/// File dibaca in-memory via `file_picker` (withData: true), divalidasi
/// oleh [ServiceAccountStorage.validate], lalu disimpan encrypted ke
/// [FlutterSecureStorage]. Tidak pernah ditulis ke disk plaintext.
class ServiceAccountSetupDialog extends StatefulWidget {
  const ServiceAccountSetupDialog({super.key});

  static Future<bool?> show() {
    final ctx = AppNavigator.context;
    if (ctx == null) return Future.value(false);
    return showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const ServiceAccountSetupDialog(),
    );
  }

  @override
  State<ServiceAccountSetupDialog> createState() =>
      _ServiceAccountSetupDialogState();
}

class _ServiceAccountSetupDialogState extends State<ServiceAccountSetupDialog> {
  String? _fileName;
  String? _rawJson;
  String? _projectId;
  String? _clientEmail;
  String? _error;
  bool _saving = false;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _error = 'Gagal membaca isi file.');
      return;
    }
    try {
      final raw = utf8.decode(bytes);
      final data = ServiceAccountStorage.validate(raw);
      setState(() {
        _fileName = file.name;
        _rawJson = raw;
        _projectId = data['project_id'] as String;
        _clientEmail = data['client_email'] as String;
        _error = null;
      });
    } on FormatException catch (e) {
      setState(() {
        _error = e.message;
        _rawJson = null;
        _projectId = null;
        _clientEmail = null;
      });
    } catch (e) {
      setState(() {
        _error = 'File tidak valid: $e';
        _rawJson = null;
      });
    }
  }

  Future<void> _save() async {
    final raw = _rawJson;
    if (raw == null) return;
    setState(() => _saving = true);
    try {
      await ServiceAccountStorage.save(raw);
      AdminSdk.reset();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Gagal menyimpan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.vpn_key_outlined),
          SizedBox(width: 8),
          Text('Setup Service Account'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload file serviceAccount.json dari Google Cloud Console '
              '(Project Settings → Service Accounts → Generate new private key).',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text(
              'File disimpan terenkripsi di perangkat ini saja dan tidak '
              'dikirim ke server manapun.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pick,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Pilih file...'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _fileName ?? 'Belum ada file dipilih',
                    style: TextStyle(
                      fontSize: 13,
                      color: _fileName == null ? Colors.black54 : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (_rawJson != null) ...[
              const SizedBox(height: 16),
              _Row(label: 'Project ID', value: _projectId ?? '-'),
              _Row(label: 'Client email', value: _clientEmail ?? '-'),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 18,
                      color: Color(0xFFB91C1C),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _rawJson == null || _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
