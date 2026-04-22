import 'package:antrian/data/models/layanan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures.dart';

void main() {
  group('Layanan', () {
    test('fromJson/toJson roundtrip — status serialized as label', () {
      final json = fixLayanan.toJson();
      // toJson writes "Aktif"/"Non-aktif" via .label, not enum name
      expect(json['status'], 'Aktif');

      final parsed = Layanan.fromJson(json);
      expect(parsed.id, fixLayanan.id);
      expect(parsed.status, StatusLayanan.aktif);
    });

    test('fromJson is case-insensitive on status', () {
      final json = fixLayanan.toJson()..['status'] = 'AKTIF';
      expect(Layanan.fromJson(json).status, StatusLayanan.aktif);
    });

    test('non-aktif status roundtrips', () {
      final nonAktif = fixLayanan.copyWith(status: StatusLayanan.nonAktif);
      final parsed = Layanan.fromJson(nonAktif.toJson());
      expect(parsed.status, StatusLayanan.nonAktif);
    });

    test('defaults for missing optional fields', () {
      final json = fixLayanan.toJson()
        ..remove('deskripsi')
        ..remove('durasiMenit')
        ..remove('biaya');
      final parsed = Layanan.fromJson(json);
      expect(parsed.deskripsi, '');
      expect(parsed.durasiMenit, 15);
      expect(parsed.biaya, 0);
    });

    test('equality by id only', () {
      final other = fixLayanan.copyWith(nama: 'Berubah', biaya: 999);
      expect(fixLayanan, other);
    });

    test('StatusLayanan.label', () {
      expect(StatusLayanan.aktif.label, 'Aktif');
      expect(StatusLayanan.nonAktif.label, 'Non-aktif');
    });
  });
}
