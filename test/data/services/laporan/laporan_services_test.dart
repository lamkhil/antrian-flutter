import 'package:antrian/data/services/laporan/laporan_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures.dart';

void main() {
  late FakeFirebaseFirestore fs;

  setUp(() {
    fs = FakeFirebaseFirestore();
    LaporanServices.db = fs;
  });

  Future<void> seed(String id, DateTime waktu, {String? lokasiId}) async {
    final json = buildAntrian(id: id, waktuDaftar: waktu).toJson();
    if (lokasiId != null) json['lokasiId'] = lokasiId;
    await fs
        .collection('antrians')
        .doc(id)
        .set({...json, 'waktuDaftar': Timestamp.fromDate(waktu)});
  }

  group('LaporanServices.fetchAntrianRange', () {
    test('returns only antrian within [dari, sampai]', () async {
      await seed('before', DateTime(2026, 4, 20, 10));
      await seed('in1', DateTime(2026, 4, 22, 10));
      await seed('in2', DateTime(2026, 4, 22, 15));
      await seed('after', DateTime(2026, 4, 23, 10));

      final res = await LaporanServices.fetchAntrianRange(
        dari: DateTime(2026, 4, 22),
        sampai: DateTime(2026, 4, 22, 23, 59, 59),
      );
      expect(res.success, isTrue);
      expect(res.data?.map((a) => a.id).toSet(), {'in1', 'in2'});
    });

    test('filters by lokasi when provided', () async {
      await seed('a', DateTime(2026, 4, 22, 10), lokasiId: 'lok1');
      await seed('b', DateTime(2026, 4, 22, 11), lokasiId: 'lok2');

      final res = await LaporanServices.fetchAntrianRange(
        dari: DateTime(2026, 4, 22),
        sampai: DateTime(2026, 4, 22, 23, 59, 59),
        lokasi: fixLokasi, // fixLokasi.id == 'lok1'
      );
      expect(res.data?.length, 1);
      expect(res.data?.single.id, 'a');
    });

    test('returns empty list when no antrian in range', () async {
      await seed('x', DateTime(2026, 4, 20, 10));
      final res = await LaporanServices.fetchAntrianRange(
        dari: DateTime(2026, 4, 22),
        sampai: DateTime(2026, 4, 22, 23, 59, 59),
      );
      expect(res.success, isTrue);
      expect(res.data, isEmpty);
    });
  });
}
