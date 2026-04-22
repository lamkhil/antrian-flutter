import 'package:antrian/features/pengguna/pengguna_admin_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures.dart';

/// Smoke tests untuk validasi input sebelum `PenggunaAdminDataSource` hit
/// Admin SDK. Operasi yang perlu admin SDK live (create/update/delete
/// sukses) tidak bisa ditest di sini tanpa mocking layer yang lebih dalam
/// — yang dites di sini cuma guard di depan, memastikan payload bermasalah
/// tidak lolos ke AdminUserService.
void main() {
  group('PenggunaAdminDataSource.create (input validation)', () {
    test('rejects missing password', () async {
      final ds = PenggunaAdminDataSource();
      expect(
        () => ds.create({
          'nama': fixPengguna.nama,
          'email': fixPengguna.email,
          'role': 'operator',
          'status': 'aktif',
          'lokasiIds': const <String>[],
        }),
        throwsException,
      );
    });

    test('rejects password shorter than 6 characters', () async {
      final ds = PenggunaAdminDataSource();
      expect(
        () => ds.create({
          'nama': fixPengguna.nama,
          'email': fixPengguna.email,
          'password': 'abc',
          'role': 'operator',
          'status': 'aktif',
          'lokasiIds': const <String>[],
        }),
        throwsException,
      );
    });

    test('rejects whitespace-only password', () async {
      final ds = PenggunaAdminDataSource();
      expect(
        () => ds.create({
          'nama': fixPengguna.nama,
          'email': fixPengguna.email,
          'password': '         ',
          'role': 'operator',
          'status': 'aktif',
          'lokasiIds': const <String>[],
        }),
        throwsException,
      );
    });
  });
}
