import 'package:antrian/data/models/zona.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures.dart';

void main() {
  group('Zona', () {
    test('fromJson/toJson roundtrip', () {
      final parsed = Zona.fromJson(fixZona.toJson());
      expect(parsed.id, fixZona.id);
      expect(parsed.kode, fixZona.kode);
      expect(parsed.kapasitas, fixZona.kapasitas);
      expect(parsed.antrianAktif, fixZona.antrianAktif);
      expect(parsed.jumlahLayanan, fixZona.jumlahLayanan);
      expect(parsed.status, StatusZona.aktif);
      expect(parsed.lokasi.id, fixLokasi.id);
    });

    test('status "nonAktif" parsed correctly', () {
      final json = fixZona.toJson()..['status'] = 'nonAktif';
      expect(Zona.fromJson(json).status, StatusZona.nonAktif);
    });

    test('unknown status falls back to aktif', () {
      final json = fixZona.toJson()..['status'] = 'xyz';
      expect(Zona.fromJson(json).status, StatusZona.aktif);
    });

    test('missing numeric fields default to 0', () {
      final json = fixZona.toJson()
        ..remove('kapasitas')
        ..remove('antrianAktif')
        ..remove('jumlahLayanan');
      final parsed = Zona.fromJson(json);
      expect(parsed.kapasitas, 0);
      expect(parsed.antrianAktif, 0);
      expect(parsed.jumlahLayanan, 0);
    });

    test('copyWith preserves id', () {
      final copy = fixZona.copyWith(nama: 'Zona Baru', kapasitas: 99);
      expect(copy.id, fixZona.id);
      expect(copy.nama, 'Zona Baru');
      expect(copy.kapasitas, 99);
      expect(copy.kode, fixZona.kode);
    });

    test('equality by id only', () {
      final other = fixZona.copyWith(nama: 'X', kapasitas: 0);
      expect(fixZona, other);
    });

    test('StatusZona labels in Indonesian', () {
      expect(StatusZona.aktif.label, 'Aktif');
      expect(StatusZona.nonAktif.label, 'Non-aktif');
    });
  });
}
