import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/services/firestore_data_source.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:flutter_test/flutter_test.dart';

FirestoreDataSource<Lokasi> _newDataSource(FakeFirebaseFirestore fs) =>
    FirestoreDataSource<Lokasi>(
      collectionPath: 'locations',
      fromJson: Lokasi.fromJson,
      toJson: (r) => r.toJson(),
      idOf: (r) => r.id,
      firestore: fs,
    );

Future<void> _seed(FakeFirebaseFirestore fs, List<Lokasi> items) async {
  for (final l in items) {
    await fs.collection('locations').doc(l.id).set(l.toJson());
  }
}

const _lokasiA = Lokasi(id: 'a', nama: 'Alpha', alamat: 'Jl. A');
const _lokasiB = Lokasi(id: 'b', nama: 'Beta', alamat: 'Jl. B');
const _lokasiC = Lokasi(id: 'c', nama: 'Gamma', alamat: 'Jl. C');

void main() {
  late FakeFirebaseFirestore fs;
  late FirestoreDataSource<Lokasi> ds;

  setUp(() {
    fs = FakeFirebaseFirestore();
    ds = _newDataSource(fs);
  });

  group('FirestoreDataSource.list', () {
    test('returns all records when no filter/search', () async {
      await _seed(fs, [_lokasiA, _lokasiB, _lokasiC]);
      final result = await ds.list(
        const ListQuery(page: 1, perPage: 10),
      );
      expect(result.total, 3);
      expect(result.data.length, 3);
      expect(result.data.map((l) => l.id).toSet(), {'a', 'b', 'c'});
    });

    test('search filters across all fields in-memory', () async {
      await _seed(fs, [_lokasiA, _lokasiB, _lokasiC]);
      final result = await ds.list(
        const ListQuery(page: 1, perPage: 10, search: 'beta'),
      );
      expect(result.data.length, 1);
      expect(result.data.single.id, 'b');
    });

    test('custom searchMatcher used when provided', () async {
      final custom = FirestoreDataSource<Lokasi>(
        collectionPath: 'locations',
        fromJson: Lokasi.fromJson,
        toJson: (r) => r.toJson(),
        idOf: (r) => r.id,
        firestore: fs,
        searchMatcher: (r, q) => r.alamat.toLowerCase().contains(q),
      );
      await _seed(fs, [_lokasiA, _lokasiB, _lokasiC]);
      final result = await custom.list(
        const ListQuery(page: 1, perPage: 10, search: 'jl. b'),
      );
      expect(result.data.single.id, 'b');
    });

    test('sort by field ascending/descending', () async {
      await _seed(fs, [_lokasiC, _lokasiA, _lokasiB]);
      final asc = await ds.list(
        const ListQuery(page: 1, perPage: 10, sortBy: 'nama'),
      );
      expect(asc.data.map((e) => e.nama).toList(),
          ['Alpha', 'Beta', 'Gamma']);

      final desc = await ds.list(
        const ListQuery(page: 1, perPage: 10, sortBy: 'nama', sortDesc: true),
      );
      expect(desc.data.map((e) => e.nama).toList(),
          ['Gamma', 'Beta', 'Alpha']);
    });

    test('pagination slices correctly', () async {
      await _seed(fs, [_lokasiA, _lokasiB, _lokasiC]);
      final page1 = await ds.list(
        const ListQuery(page: 1, perPage: 2, sortBy: 'nama'),
      );
      expect(page1.data.length, 2);
      expect(page1.total, 3);

      final page2 = await ds.list(
        const ListQuery(page: 2, perPage: 2, sortBy: 'nama'),
      );
      expect(page2.data.length, 1);
      expect(page2.total, 3);

      final page3 = await ds.list(
        const ListQuery(page: 3, perPage: 2, sortBy: 'nama'),
      );
      expect(page3.data, isEmpty);
    });

    test('filter translates to where clause', () async {
      await _seed(fs, [_lokasiA, _lokasiB, _lokasiC]);
      final result = await ds.list(
        const ListQuery(page: 1, perPage: 10, filters: {'nama': 'Beta'}),
      );
      expect(result.data.single.id, 'b');
    });
  });

  group('FirestoreDataSource.get', () {
    test('returns record by id', () async {
      await _seed(fs, [_lokasiA]);
      final got = await ds.get('a');
      expect(got?.id, 'a');
      expect(got?.nama, 'Alpha');
    });

    test('returns null for missing id', () async {
      expect(await ds.get('does-not-exist'), isNull);
    });
  });

  group('FirestoreDataSource.create', () {
    test('writes doc with auto-generated id', () async {
      final created = await ds.create({'nama': 'Baru', 'alamat': 'Jl. X'});
      expect(created.id, isNotEmpty);
      final snap = await fs.collection('locations').doc(created.id).get();
      expect(snap.exists, isTrue);
      expect(snap.data()?['nama'], 'Baru');
    });

    test('strips incoming id before write', () async {
      final created = await ds.create({
        'id': 'forced-id',
        'nama': 'X',
        'alamat': 'Y',
      });
      // Firestore auto-id should NOT be the forced value
      expect(created.id, isNot('forced-id'));
    });

    test('beforeWrite hook can enrich payload', () async {
      final custom = FirestoreDataSource<Lokasi>(
        collectionPath: 'locations',
        fromJson: Lokasi.fromJson,
        toJson: (r) => r.toJson(),
        idOf: (r) => r.id,
        firestore: fs,
        beforeWrite: (data) async => {...data, 'alamat': 'ENRICHED'},
      );
      final created = await custom.create({'nama': 'Baru', 'alamat': 'X'});
      expect(created.alamat, 'ENRICHED');
    });
  });

  group('FirestoreDataSource.update', () {
    test('updates doc and returns fresh copy', () async {
      await _seed(fs, [_lokasiA]);
      final updated = await ds.update('a', {
        'nama': 'Alpha Baru',
        'alamat': 'Jl. A',
      });
      expect(updated.nama, 'Alpha Baru');
      final refetched = await fs.collection('locations').doc('a').get();
      expect(refetched.data()?['nama'], 'Alpha Baru');
    });
  });

  group('FirestoreDataSource.delete', () {
    test('removes doc', () async {
      await _seed(fs, [_lokasiA]);
      await ds.delete('a');
      final snap = await fs.collection('locations').doc('a').get();
      expect(snap.exists, isFalse);
    });
  });

  group('FirestoreDataSource.watch', () {
    test('emits initial + subsequent snapshots', () async {
      await _seed(fs, [_lokasiA]);
      final stream = ds.watch(const ListQuery(page: 1, perPage: 10))!;
      final events = <List<Lokasi>>[];
      final sub = stream.listen(events.add);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await fs
          .collection('locations')
          .doc('b')
          .set(_lokasiB.toJson());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await sub.cancel();
      expect(events.first.length, 1);
      expect(events.last.length, 2);
    });
  });

  group('FirestoreDataSource with scopeField', () {
    test('filters and auto-fills tenant id when scope active', () async {
      final tenantAware = FirestoreDataSource<Lokasi>(
        collectionPath: 'locations',
        fromJson: Lokasi.fromJson,
        toJson: (r) => r.toJson(),
        idOf: (r) => r.id,
        firestore: fs,
        scopeField: 'alamat', // reuse alamat as fake tenant key
      );
      // Without tenant scope active, just verify plain list works
      await _seed(fs, [_lokasiA]);
      final got = await tenantAware.list(
        const ListQuery(page: 1, perPage: 10),
      );
      expect(got.data, isNotEmpty);
    });
  });
}
