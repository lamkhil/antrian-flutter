import 'package:antrian/data/models/pengguna.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pengguna', () {
    test('fromJson/toJson roundtrip', () {
      const p = Pengguna(
        id: 'u1',
        nama: 'Siti',
        email: 'siti@example.com',
        role: RolePengguna.supervisor,
        status: StatusPengguna.aktif,
        lokasiIds: ['l1', 'l2'],
      );
      final parsed = Pengguna.fromJson(p.toJson());
      expect(parsed.id, p.id);
      expect(parsed.role, p.role);
      expect(parsed.status, p.status);
      expect(parsed.lokasiIds, p.lokasiIds);
    });

    test('unknown role falls back to operator', () {
      final parsed = Pengguna.fromJson({
        'id': 'x',
        'nama': 'A',
        'email': 'a@b',
        'role': 'unknown',
        'status': 'aktif',
        'lokasiIds': <String>[],
      });
      expect(parsed.role, RolePengguna.operator);
    });

    test('role is case-insensitive', () {
      final parsed = Pengguna.fromJson({
        'id': 'x',
        'nama': 'A',
        'email': 'a@b',
        'role': 'ADMIN',
        'status': 'AKTIF',
        'lokasiIds': <String>[],
      });
      expect(parsed.role, RolePengguna.admin);
      expect(parsed.status, StatusPengguna.aktif);
    });

    test('unknown status falls back to aktif', () {
      final parsed = Pengguna.fromJson({
        'id': 'x',
        'nama': 'A',
        'email': 'a@b',
        'role': 'operator',
        'status': 'entahlah',
        'lokasiIds': <String>[],
      });
      expect(parsed.status, StatusPengguna.aktif);
    });

    test('legacy single lokasiId is wrapped to list', () {
      final parsed = Pengguna.fromJson({
        'id': 'x',
        'nama': 'A',
        'email': 'a@b',
        'role': 'operator',
        'status': 'aktif',
        'lokasiId': 'lok-legacy',
      });
      expect(parsed.lokasiIds, ['lok-legacy']);
    });

    test('missing lokasiIds defaults to empty list', () {
      final parsed = Pengguna.fromJson({
        'id': 'x',
        'nama': 'A',
        'email': 'a@b',
        'role': 'operator',
        'status': 'aktif',
      });
      expect(parsed.lokasiIds, isEmpty);
    });

    test('legacy empty lokasiId string → empty list', () {
      final parsed = Pengguna.fromJson({
        'id': 'x',
        'nama': 'A',
        'email': 'a@b',
        'role': 'operator',
        'status': 'aktif',
        'lokasiId': '',
      });
      expect(parsed.lokasiIds, isEmpty);
    });

    test('nama/email missing → empty strings', () {
      final parsed = Pengguna.fromJson({
        'id': 'x',
        'role': 'admin',
        'status': 'aktif',
        'lokasiIds': <String>[],
      });
      expect(parsed.nama, '');
      expect(parsed.email, '');
    });

    test('copyWith preserves id', () {
      const p = Pengguna(id: 'u1', nama: 'A', email: 'a@b');
      final copy = p.copyWith(nama: 'B', role: RolePengguna.admin);
      expect(copy.id, 'u1');
      expect(copy.nama, 'B');
      expect(copy.role, RolePengguna.admin);
      expect(copy.email, 'a@b');
    });

    test('equality by id only', () {
      const a = Pengguna(id: 'u1', nama: 'A', email: 'a@b');
      const b = Pengguna(
        id: 'u1',
        nama: 'different',
        email: 'x@y',
        role: RolePengguna.admin,
      );
      expect(a, b);
    });

    test('toJson serializes role/status as enum name', () {
      const p = Pengguna(
        id: 'u1',
        nama: 'A',
        email: 'a@b',
        role: RolePengguna.admin,
        status: StatusPengguna.nonAktif,
      );
      final json = p.toJson();
      expect(json['role'], 'admin');
      expect(json['status'], 'nonAktif');
    });
  });
}
