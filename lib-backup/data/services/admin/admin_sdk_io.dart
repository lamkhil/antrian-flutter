import 'package:firebase_admin_sdk/auth.dart' as admin_auth;
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart' as admin;

import 'admin_sdk_exceptions.dart';
import 'service_account_storage.dart';

/// Lazy singleton untuk Firebase Admin SDK.
///
/// Kalau service account belum di-upload → [ensureReady] lempar
/// [AdminSdkNotConfigured] supaya UI bisa arahkan admin ke setup screen.
class AdminSdk {
  AdminSdk._();

  static admin.FirebaseApp? _app;
  static admin_auth.Auth? _auth;
  static String? _projectId;

  static bool get isSupportedPlatform => true;

  static bool get isReady => _app != null;

  static String? get projectId => _projectId;

  /// Bikin app baru kalau belum ada, return auth instance.
  /// Throw [AdminSdkNotConfigured] kalau JSON belum di-upload.
  static Future<admin_auth.Auth> ensureReady() async {
    if (_auth != null) return _auth!;

    final data = await ServiceAccountStorage.readJson();
    if (data == null) {
      throw const AdminSdkNotConfigured(
        'Service account belum di-upload.',
      );
    }

    try {
      _app = admin.FirebaseApp.initializeApp(
        options: admin.AppOptions(
          credential: admin.Credential.fromServiceAccountParams(
            privateKey: data['private_key'] as String,
            email: data['client_email'] as String,
            projectId: data['project_id'] as String,
            clientId: data['client_id'] as String,
          ),
          projectId: data['project_id'] as String,
        ),
      );
      _projectId = data['project_id'] as String;
      _auth = _app!.auth();
      return _auth!;
    } catch (e) {
      _app = null;
      _auth = null;
      _projectId = null;
      throw AdminSdkInitFailed('Gagal inisialisasi Admin SDK: $e');
    }
  }

  /// Reset singleton — dipanggil setelah service account di-clear atau
  /// di-replace dengan yang baru.
  static void reset() {
    _app = null;
    _auth = null;
    _projectId = null;
  }
}
