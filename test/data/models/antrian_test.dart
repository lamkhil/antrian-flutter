import 'package:antrian/data/models/antrian.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures.dart';

/// Build an "from-Firestore" shape: waktu* fields are Timestamp, not ISO8601.
Map<String, dynamic> _firestoreShape(Antrian antrian) {
  return {
    ...antrian.toJson(),
    'waktuDaftar': Timestamp.fromDate(antrian.waktuDaftar),
    if (antrian.waktuDipanggil != null)
      'waktuDipanggil': Timestamp.fromDate(antrian.waktuDipanggil!),
    if (antrian.waktuSelesai != null)
      'waktuSelesai': Timestamp.fromDate(antrian.waktuSelesai!),
  };
}

void main() {
  group('Antrian', () {
    test('fromJson parses Timestamp → DateTime (same moment, Timestamp always returns local tz)', () {
      final a = buildAntrian(
        waktuDaftar: DateTime.utc(2026, 4, 22, 9, 30),
        waktuDipanggil: DateTime.utc(2026, 4, 22, 9, 45),
        waktuSelesai: DateTime.utc(2026, 4, 22, 9, 55),
      );
      final parsed = Antrian.fromJson(_firestoreShape(a));
      expect(parsed.waktuDaftar.isAtSameMomentAs(a.waktuDaftar), isTrue);
      expect(parsed.waktuDipanggil!.isAtSameMomentAs(a.waktuDipanggil!), isTrue);
      expect(parsed.waktuSelesai!.isAtSameMomentAs(a.waktuSelesai!), isTrue);
    });

    test('fromJson handles null optional timestamps', () {
      final a = buildAntrian();
      final parsed = Antrian.fromJson(_firestoreShape(a));
      expect(parsed.waktuDipanggil, isNull);
      expect(parsed.waktuSelesai, isNull);
      expect(parsed.loket, isNull);
    });

    test('each StatusAntrian value parses correctly', () {
      for (final s in StatusAntrian.values) {
        final a = buildAntrian(status: s);
        final parsed = Antrian.fromJson(_firestoreShape(a));
        expect(parsed.status, s, reason: 'status $s harus parse');
      }
    });

    test('unknown status falls back to menunggu', () {
      final shape = _firestoreShape(buildAntrian())..['status'] = 'unknown';
      expect(Antrian.fromJson(shape).status, StatusAntrian.menunggu);
    });

    test('toJson writes status.name and ISO8601 dates', () {
      final a = buildAntrian(
        status: StatusAntrian.dilayani,
        waktuDaftar: DateTime.utc(2026, 4, 22, 9, 30),
      );
      final json = a.toJson();
      expect(json['status'], 'dilayani');
      expect(json['waktuDaftar'], '2026-04-22T09:30:00.000Z');
    });

    test('equality by id', () {
      final a = buildAntrian(id: 'x');
      final b = buildAntrian(id: 'x', status: StatusAntrian.selesai);
      final c = buildAntrian(id: 'y');
      expect(a, b);
      expect(a, isNot(c));
    });

    test('StatusAntrian labels', () {
      expect(StatusAntrian.menunggu.label, 'Menunggu');
      expect(StatusAntrian.dipanggil.label, 'Dipanggil');
      expect(StatusAntrian.dilayani.label, 'Dilayani');
      expect(StatusAntrian.dilewati.label, 'Dilewati');
      expect(StatusAntrian.selesai.label, 'Selesai');
    });
  });
}
