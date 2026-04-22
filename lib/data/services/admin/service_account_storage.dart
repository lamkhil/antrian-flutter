import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Enkripsi service-account JSON di storage OS (Keystore/Keychain/DPAPI/libsecret).
///
/// JSON **tidak pernah** ikut ke binary aplikasi — admin upload sekali,
/// tersimpan per-device, bisa di-revoke lewat [clear].
class ServiceAccountStorage {
  static const _key = 'firebase_service_account_json_v1';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static bool get isSupportedPlatform => !kIsWeb;

  /// Parse + validasi JSON mentah. Throw [FormatException] kalau invalid.
  static Map<String, dynamic> validate(String raw) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      throw const FormatException('File bukan JSON yang valid.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('File harus berisi objek JSON.');
    }
    const required = [
      'type',
      'project_id',
      'private_key',
      'client_email',
      'client_id',
    ];
    for (final k in required) {
      final v = decoded[k];
      if (v is! String || v.isEmpty) {
        throw FormatException('Field "$k" tidak ada atau kosong.');
      }
    }
    if (decoded['type'] != 'service_account') {
      throw const FormatException(
        'Field "type" harus "service_account" (ini bukan service account key).',
      );
    }
    if (!(decoded['private_key'] as String).contains('BEGIN PRIVATE KEY')) {
      throw const FormatException('Field "private_key" tidak valid.');
    }
    return decoded;
  }

  static Future<void> save(String raw) async {
    if (!isSupportedPlatform) {
      throw UnsupportedError('Service account tidak bisa disimpan di Web.');
    }
    validate(raw);
    await _storage.write(key: _key, value: raw);
  }

  static Future<String?> read() async {
    if (!isSupportedPlatform) return null;
    return _storage.read(key: _key);
  }

  static Future<Map<String, dynamic>?> readJson() async {
    final raw = await read();
    if (raw == null) return null;
    try {
      return validate(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isConfigured() async {
    final raw = await read();
    return raw != null && raw.isNotEmpty;
  }

  static Future<void> clear() async {
    if (!isSupportedPlatform) return;
    await _storage.delete(key: _key);
  }
}
