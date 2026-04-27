import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-device override gambar latar kios. Saat aktif, halaman kios pakai
/// gambar ini sebagai background — menggantikan apa pun yang di-set
/// admin (gradient/color/URL). Hapus untuk kembali ke pengaturan admin.
///
/// Strategi penyimpanan:
/// - **Native** (Android/iOS/Linux/Windows/macOS): file di-copy ke
///   `getApplicationDocumentsDirectory()`, path-nya disimpan di
///   SharedPreferences. Hemat memori dan tahan reboot.
/// - **Web** (browser): file di-encode base64 dan disimpan di
///   SharedPreferences (yaitu `localStorage`). Dibatasi 3 MB sebelum
///   encode untuk menghindari `QuotaExceededError` dari browser.
class KioskLocalBg {
  static const _prefPath = 'kiosk_bg_local_path_';
  static const _prefData = 'kiosk_bg_local_data_';
  static const _webMaxBytes = 3 * 1024 * 1024;

  static Future<ImageProvider?> read(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      final b64 = prefs.getString('$_prefData$deviceId');
      if (b64 == null) return null;
      try {
        return MemoryImage(base64Decode(b64));
      } catch (_) {
        await prefs.remove('$_prefData$deviceId');
        return null;
      }
    }
    final path = prefs.getString('$_prefPath$deviceId');
    if (path == null) return null;
    final f = File(path);
    if (!await f.exists()) {
      await prefs.remove('$_prefPath$deviceId');
      return null;
    }
    return FileImage(f);
  }

  static Future<ImageProvider?> pickAndSave(String deviceId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2160,
    );
    if (picked == null) return null;
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      if (bytes.length > _webMaxBytes) {
        throw 'Gambar terlalu besar untuk disimpan di browser '
            '(${(bytes.length / 1024 / 1024).toStringAsFixed(1)}MB > 3MB). '
            'Kompres dulu atau buka kios di aplikasi desktop/mobile.';
      }
      await prefs.setString('$_prefData$deviceId', base64Encode(bytes));
      return MemoryImage(bytes);
    }
    final docs = await getApplicationDocumentsDirectory();
    await _purgeFiles(docs, deviceId);
    final ext = picked.path.contains('.')
        ? picked.path.split('.').last.toLowerCase()
        : 'jpg';
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dest = File('${docs.path}/kiosk_bg_${deviceId}_$stamp.$ext');
    await File(picked.path).copy(dest.path);
    await prefs.setString('$_prefPath$deviceId', dest.path);
    return FileImage(dest);
  }

  static Future<void> clear(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefPath$deviceId');
    await prefs.remove('$_prefData$deviceId');
    if (kIsWeb) return;
    try {
      final docs = await getApplicationDocumentsDirectory();
      await _purgeFiles(docs, deviceId);
    } catch (_) {}
  }

  static Future<void> _purgeFiles(Directory docs, String deviceId) async {
    try {
      await for (final e in docs.list()) {
        if (e is File && e.path.contains('kiosk_bg_${deviceId}_')) {
          try {
            await e.delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}
