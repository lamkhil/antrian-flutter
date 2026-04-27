import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_filament/flutter_filament.dart';

/// Implementasi [TenantAccess] untuk project Antrian.
///
/// Membaca dokumen Firestore `users/{uid}` milik user yang sedang login
/// dan menentukan:
/// - apakah dia admin global (role == 'admin')
/// - lokasi mana saja yang dia punya akses (`lokasiIds`)
class AntrianTenantAccess extends TenantAccess {
  @override
  Future<TenantPermissions> permissions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('[TenantAccess] user belum login');
      return TenantPermissions.empty;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        debugPrint(
          '[TenantAccess] users/$uid TIDAK DITEMUKAN.\n'
          'Buat dokumen di Firestore collection `users` dengan id = $uid,\n'
          'berisi field:\n'
          '  role: "admin"  (atau "supervisor" / "operator")\n'
          '  lokasiIds: ["id-lokasi-1", "id-lokasi-2"]',
        );
        return TenantPermissions.empty;
      }

      final data = doc.data() ?? const <String, dynamic>{};
      final role = (data['role'] as String?)?.toLowerCase();
      final ids = _readLokasiIds(data);

      debugPrint(
        '[TenantAccess] uid=$uid role=$role lokasiIds=$ids '
        '(isGlobalAdmin=${role == 'admin'})',
      );

      return TenantPermissions(
        isGlobalAdmin: role == 'admin',
        allowedIds: ids,
      );
    } catch (e, st) {
      debugPrint('[TenantAccess] error membaca users/$uid: $e\n$st');
      return TenantPermissions.empty;
    }
  }

  List<String> _readLokasiIds(Map<String, dynamic> data) {
    final list = data['lokasiIds'];
    if (list is List) return list.map((e) => e.toString()).toList();
    final single = data['lokasiId'];
    if (single is String && single.isNotEmpty) return [single];
    return const [];
  }
}
