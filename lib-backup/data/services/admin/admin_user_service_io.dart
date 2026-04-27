import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admin_sdk/auth.dart' as admin_auth;

import '../../models/pengguna.dart';
import 'admin_sdk_io.dart';

/// CRUD user via Firebase Admin SDK + sinkronisasi dokumen
/// `users/{uid}` di Firestore.
///
/// Semua operasi butuh [AdminSdk.ensureReady] sudah pernah sukses
/// (service account sudah di-upload).
class AdminUserService {
  AdminUserService._();

  static CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users');

  /// Bikin user baru di Auth + dokumen Firestore.
  /// UID dari Auth jadi ID dokumen Firestore.
  static Future<Pengguna> createUser({
    required String nama,
    required String email,
    required String password,
    required RolePengguna role,
    required StatusPengguna status,
    List<String> lokasiIds = const [],
  }) async {
    final auth = await AdminSdk.ensureReady();

    final created = await auth.createUser(
      admin_auth.CreateRequest(
        email: email,
        password: password,
        displayName: nama,
        disabled: status == StatusPengguna.nonAktif,
      ),
    );

    await auth.setCustomUserClaims(
      created.uid,
      customUserClaims: _claimsFor(role, lokasiIds),
    );

    final pengguna = Pengguna(
      id: created.uid,
      nama: nama,
      email: email,
      role: role,
      status: status,
      lokasiIds: lokasiIds,
    );
    await _col.doc(created.uid).set(pengguna.toJson());
    return pengguna;
  }

  /// Update profil + role + status. Password tidak diubah di sini —
  /// gunakan [resetPassword].
  static Future<Pengguna> updateUser({
    required String uid,
    required String nama,
    required String email,
    required RolePengguna role,
    required StatusPengguna status,
    List<String> lokasiIds = const [],
  }) async {
    final auth = await AdminSdk.ensureReady();

    await auth.updateUser(
      uid,
      admin_auth.UpdateRequest(
        email: email,
        displayName: nama,
        disabled: status == StatusPengguna.nonAktif,
      ),
    );

    await auth.setCustomUserClaims(
      uid,
      customUserClaims: _claimsFor(role, lokasiIds),
    );

    final pengguna = Pengguna(
      id: uid,
      nama: nama,
      email: email,
      role: role,
      status: status,
      lokasiIds: lokasiIds,
    );
    await _col.doc(uid).set(pengguna.toJson(), SetOptions(merge: true));
    return pengguna;
  }

  /// Set password baru untuk user. User akan otomatis logout dari
  /// semua session existing.
  static Future<void> resetPassword({
    required String uid,
    required String newPassword,
  }) async {
    final auth = await AdminSdk.ensureReady();
    await auth.updateUser(
      uid,
      admin_auth.UpdateRequest(password: newPassword),
    );
  }

  /// Hapus user dari Auth + dokumen Firestore-nya.
  static Future<void> deleteUser(String uid) async {
    final auth = await AdminSdk.ensureReady();
    await auth.deleteUser(uid);
    await _col.doc(uid).delete();
  }

  static Map<String, dynamic> _claimsFor(
    RolePengguna role,
    List<String> lokasiIds,
  ) => {
    'role': role.name,
    if (role != RolePengguna.admin) 'lokasiIds': lokasiIds,
  };
}
