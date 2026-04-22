import '../../data/models/pengguna.dart';
import '../../data/services/admin/admin_user_service.dart';
import '../../data/services/firestore_data_source.dart';

/// Data source untuk Pengguna yang routing create/update/delete lewat
/// [AdminUserService] (Firebase Admin SDK). `list`/`get`/`watch` tetap
/// pakai implementasi default [FirestoreDataSource] — baca dari koleksi
/// `users` di Firestore.
class PenggunaAdminDataSource extends FirestoreDataSource<Pengguna> {
  PenggunaAdminDataSource()
      : super(
          collectionPath: 'users',
          fromJson: Pengguna.fromJson,
          toJson: (r) => r.toJson(),
          idOf: (r) => r.id,
        );

  @override
  Future<Pengguna> create(Map<String, dynamic> data) {
    final password = (data['password'] as String? ?? '').trim();
    if (password.length < 6) {
      throw Exception('Password minimal 6 karakter.');
    }
    return AdminUserService.createUser(
      nama: (data['nama'] as String? ?? '').trim(),
      email: (data['email'] as String? ?? '').trim(),
      password: password,
      role: _role(data['role']),
      status: _status(data['status']),
      lokasiIds: _lokasiIds(data['lokasiIds']),
    );
  }

  @override
  Future<Pengguna> update(String id, Map<String, dynamic> data) {
    return AdminUserService.updateUser(
      uid: id,
      nama: (data['nama'] as String? ?? '').trim(),
      email: (data['email'] as String? ?? '').trim(),
      role: _role(data['role']),
      status: _status(data['status']),
      lokasiIds: _lokasiIds(data['lokasiIds']),
    );
  }

  @override
  Future<void> delete(String id) => AdminUserService.deleteUser(id);

  static RolePengguna _role(dynamic v) => RolePengguna.values.firstWhere(
        (r) => r.name == (v as String?)?.toLowerCase(),
        orElse: () => RolePengguna.operator,
      );

  static StatusPengguna _status(dynamic v) => StatusPengguna.values.firstWhere(
        (s) => s.name == (v as String?)?.toLowerCase(),
        orElse: () => StatusPengguna.aktif,
      );

  static List<String> _lokasiIds(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }
}
