import '../../models/pengguna.dart';
import 'admin_sdk_exceptions.dart';

/// Web stub untuk [AdminUserService]. Operasi admin (create/update/delete
/// user) butuh service-account signing yang tidak jalan di browser, jadi
/// semua method langsung throw [AdminSdkNotConfigured].
class AdminUserService {
  AdminUserService._();

  static const _msg = AdminSdkNotConfigured(
    'Manajemen user (Admin SDK) tidak didukung di Web. Buka halaman ini dari aplikasi desktop atau mobile.',
  );

  static Future<Pengguna> createUser({
    required String nama,
    required String email,
    required String password,
    required RolePengguna role,
    required StatusPengguna status,
    List<String> lokasiIds = const [],
  }) async {
    throw _msg;
  }

  static Future<Pengguna> updateUser({
    required String uid,
    required String nama,
    required String email,
    required RolePengguna role,
    required StatusPengguna status,
    List<String> lokasiIds = const [],
  }) async {
    throw _msg;
  }

  static Future<void> resetPassword({
    required String uid,
    required String newPassword,
  }) async {
    throw _msg;
  }

  static Future<void> deleteUser(String uid) async {
    throw _msg;
  }
}
