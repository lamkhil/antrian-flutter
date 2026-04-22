import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/data/services/antrian/antrian_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures.dart';

void main() {
  late FakeFirebaseFirestore fs;

  setUp(() {
    fs = FakeFirebaseFirestore();
    AntrianServices.db = fs;
  });

  group('AntrianServices.ambilTiket', () {
    test('generates ticket L-001 when no prior antrian today', () async {
      final res = await AntrianServices.ambilTiket(fixLayanan);
      expect(res.success, isTrue);
      expect(res.data?.nomorAntrian, 'L-001');
      expect(res.data?.status, StatusAntrian.menunggu);
      expect(res.data?.layananId, fixLayanan.id);
    });

    test('sequence increments per existing antrian today', () async {
      // seed 2 tiket hari ini untuk layanan yang sama
      for (var i = 1; i <= 2; i++) {
        await fs.collection('antrians').add({
          'layananId': fixLayanan.id,
          'waktuDaftar': Timestamp.now(),
        });
      }
      final res = await AntrianServices.ambilTiket(fixLayanan);
      expect(res.data?.nomorAntrian, 'L-003');
    });

    test('prefix uses first char of layanan.kode, uppercased', () async {
      final custom = fixLayanan.copyWith(kode: 'pas');
      final res = await AntrianServices.ambilTiket(custom);
      expect(res.data?.nomorAntrian, 'P-001');
    });

    test('empty kode uses "X" as prefix', () async {
      final custom = fixLayanan.copyWith(kode: '');
      final res = await AntrianServices.ambilTiket(custom);
      expect(res.data?.nomorAntrian, 'X-001');
    });

    test('antrian doc is actually written to Firestore', () async {
      final res = await AntrianServices.ambilTiket(fixLayanan);
      final all = await fs.collection('antrians').get();
      expect(all.docs.length, 1);
      expect(all.docs.single.id, res.data?.id);
    });
  });

  group('AntrianServices.streamAktifByZona', () {
    test('emits only aktif (menunggu/dipanggil/dilayani) in specified zona',
        () async {
      await fs.collection('antrians').add({
        ...buildAntrian(id: 'a1', status: StatusAntrian.menunggu).toJson(),
        'waktuDaftar': Timestamp.now(),
      });
      await fs.collection('antrians').add({
        ...buildAntrian(id: 'a2', status: StatusAntrian.selesai).toJson(),
        'waktuDaftar': Timestamp.now(),
      });
      // antrian di zona lain
      final lainZonaJson = buildAntrian(
        id: 'a3',
        status: StatusAntrian.menunggu,
      ).toJson();
      lainZonaJson['zonaId'] = 'zona-lain';
      await fs
          .collection('antrians')
          .add({...lainZonaJson, 'waktuDaftar': Timestamp.now()});

      final list = await AntrianServices.streamAktifByZona(fixZona.id).first;
      expect(list.length, 1);
      expect(list.single.id, 'a1');
    });
  });
}
