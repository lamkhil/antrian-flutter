import 'package:antrian/data/models/lokasi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lokasi', () {
    test('fromJson/toJson roundtrip', () {
      const lokasi = Lokasi(id: 'l1', nama: 'Pusat', alamat: 'Jl. A');
      final parsed = Lokasi.fromJson(lokasi.toJson());
      expect(parsed.id, lokasi.id);
      expect(parsed.nama, lokasi.nama);
      expect(parsed.alamat, lokasi.alamat);
    });

    test('copyWith preserves id, replaces other fields', () {
      const lokasi = Lokasi(id: 'l1', nama: 'Pusat', alamat: 'Jl. A');
      final copy = lokasi.copyWith(nama: 'Cabang');
      expect(copy.id, 'l1');
      expect(copy.nama, 'Cabang');
      expect(copy.alamat, 'Jl. A');
    });

    test('equality by id only', () {
      const a = Lokasi(id: 'l1', nama: 'Pusat', alamat: 'Jl. A');
      const b = Lokasi(id: 'l1', nama: 'X', alamat: 'Y');
      const c = Lokasi(id: 'l2', nama: 'Pusat', alamat: 'Jl. A');
      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
