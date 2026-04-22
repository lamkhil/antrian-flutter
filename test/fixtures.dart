import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/loket.dart';
import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/pengguna.dart';
import 'package:antrian/data/models/zona.dart';

/// Shared test fixtures. Use `.copyWith(...)` when a test needs a variant.
final fixLokasi = Lokasi(id: 'lok1', nama: 'Kantor Pusat', alamat: 'Jl. Merdeka 1');

final fixZona = Zona(
  id: 'zon1',
  kode: 'Z1',
  nama: 'Zona A',
  lokasiId: fixLokasi.id,
  lokasi: fixLokasi,
  kapasitas: 20,
  antrianAktif: 3,
  jumlahLayanan: 2,
);

final fixLayanan = Layanan(
  id: 'lay1',
  zonaId: fixZona.id,
  lokasiId: fixLokasi.id,
  kode: 'LGL',
  nama: 'Legalisasi',
  zona: fixZona,
  lokasi: fixLokasi,
  durasiMenit: 10,
);

final fixLoket = Loket(
  id: 'lok-a',
  layananId: fixLayanan.id,
  zonaId: fixZona.id,
  lokasiId: fixLokasi.id,
  kode: 'L01',
  nama: 'Loket 1',
  petugas: 'Budi',
  layanan: fixLayanan,
  zona: fixZona,
  lokasi: fixLokasi,
);

Antrian buildAntrian({
  String id = 'a1',
  String nomor = 'L-001',
  StatusAntrian status = StatusAntrian.menunggu,
  DateTime? waktuDaftar,
  DateTime? waktuDipanggil,
  DateTime? waktuSelesai,
}) =>
    Antrian(
      id: id,
      nomorAntrian: nomor,
      nama: '',
      layananId: fixLayanan.id,
      zonaId: fixZona.id,
      lokasiId: fixLokasi.id,
      status: status,
      waktuDaftar: waktuDaftar ?? DateTime(2026, 4, 22, 9),
      waktuDipanggil: waktuDipanggil,
      waktuSelesai: waktuSelesai,
      layanan: fixLayanan,
      zona: fixZona,
      lokasi: fixLokasi,
    );

final fixPengguna = Pengguna(
  id: 'u1',
  nama: 'Siti',
  email: 'siti@example.com',
  role: RolePengguna.operator,
  status: StatusPengguna.aktif,
  lokasiIds: [fixLokasi.id],
);
