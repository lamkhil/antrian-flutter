import 'package:antrian/data/models/loket.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures.dart';

void main() {
  group('Loket', () {
    test('fromJson/toJson roundtrip', () {
      final json = fixLoket.toJson();
      expect(json['status'], 'aktif'); // enum.name

      final parsed = Loket.fromJson(json);
      expect(parsed.id, fixLoket.id);
      expect(parsed.petugas, 'Budi');
      expect(parsed.status, StatusLoket.aktif);
      expect(parsed.layanan.id, fixLoket.layanan.id);
    });

    test('each StatusLoket value roundtrips', () {
      for (final s in StatusLoket.values) {
        final loket = fixLoket.copyWith(status: s);
        expect(Loket.fromJson(loket.toJson()).status, s,
            reason: 'status $s harus roundtrip');
      }
    });

    test('petugas nullable', () {
      final without = fixLoket.copyWith(petugas: null);
      // copyWith with null petugas — but copyWith uses `??` so null preserves existing.
      // Build fresh instead.
      final fresh = Loket(
        id: fixLoket.id,
        layananId: fixLoket.layananId,
        zonaId: fixLoket.zonaId,
        lokasiId: fixLoket.lokasiId,
        kode: fixLoket.kode,
        nama: fixLoket.nama,
        layanan: fixLoket.layanan,
        zona: fixLoket.zona,
        lokasi: fixLoket.lokasi,
      );
      expect(fresh.petugas, isNull);
      final json = fresh.toJson();
      expect(json['petugas'], isNull);
      expect(Loket.fromJson(json).petugas, isNull);
      // verify copyWith quirk — stays same value, not null
      expect(without.petugas, 'Budi');
    });

    test('unknown status falls back to aktif', () {
      final json = fixLoket.toJson()..['status'] = 'wat';
      expect(Loket.fromJson(json).status, StatusLoket.aktif);
    });

    test('StatusLoket labels', () {
      expect(StatusLoket.aktif.label, 'Aktif');
      expect(StatusLoket.tutup.label, 'Tutup');
      expect(StatusLoket.istirahat.label, 'Istirahat');
    });
  });
}
