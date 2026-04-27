import 'admin_sdk_exceptions.dart';

/// Web stub untuk [AdminSdk]. Package `firebase_admin_sdk` butuh `dart:io`
/// untuk JWT signing, jadi di web semua operasi langsung gagal dengan
/// [AdminSdkNotConfigured] supaya UI bisa arahkan admin ke platform lain.
class AdminSdk {
  AdminSdk._();

  static bool get isSupportedPlatform => false;

  static bool get isReady => false;

  static String? get projectId => null;

  static Future<Never> ensureReady() async {
    throw const AdminSdkNotConfigured(
      'Admin SDK tidak didukung di Web. Buka halaman ini dari aplikasi desktop atau mobile.',
    );
  }

  static void reset() {}
}
