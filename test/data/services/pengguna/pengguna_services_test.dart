import 'package:antrian/data/models/pengguna.dart';
import 'package:antrian/data/services/pengguna/pengguna_services.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fs;

  setUp(() {
    fs = FakeFirebaseFirestore();
    PenggunaServices.db = fs;
  });

  const p = Pengguna(
    id: 'u1',
    nama: 'Siti',
    email: 'siti@example.com',
    role: RolePengguna.operator,
    status: StatusPengguna.aktif,
    lokasiIds: ['l1'],
  );

  group('PenggunaServices', () {
    test('add writes doc and returns ResponseApi.success', () async {
      final res = await PenggunaServices.add(p);
      expect(res.success, isTrue);
      final doc = await fs.collection('users').doc('u1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['nama'], 'Siti');
      expect(doc.data()?['role'], 'operator');
    });

    test('fetchAll returns list with existing users', () async {
      await fs.collection('users').doc('u1').set(p.toJson());
      await fs.collection('users').doc('u2').set(
            p.copyWith(nama: 'Budi').toJson()
              ..['id'] = 'u2',
          );

      final res = await PenggunaServices.fetchAll();
      expect(res.success, isTrue);
      expect(res.data?.length, 2);
    });

    test('fetchAll on empty collection returns empty list', () async {
      final res = await PenggunaServices.fetchAll();
      expect(res.success, isTrue);
      expect(res.data, isEmpty);
    });

    test('update overwrites fields', () async {
      await fs.collection('users').doc('u1').set(p.toJson());
      final updated = p.copyWith(nama: 'Siti B', role: RolePengguna.admin);
      final res = await PenggunaServices.update(updated);
      expect(res.success, isTrue);
      final doc = await fs.collection('users').doc('u1').get();
      expect(doc.data()?['nama'], 'Siti B');
      expect(doc.data()?['role'], 'admin');
    });

    test('update returns error when doc does not exist', () async {
      // Firestore update throws if doc missing.
      final res = await PenggunaServices.update(p);
      expect(res.success, isFalse);
      expect(res.message, isNotNull);
    });

    test('delete removes doc', () async {
      await fs.collection('users').doc('u1').set(p.toJson());
      final res = await PenggunaServices.delete('u1');
      expect(res.success, isTrue);
      final doc = await fs.collection('users').doc('u1').get();
      expect(doc.exists, isFalse);
    });
  });
}
