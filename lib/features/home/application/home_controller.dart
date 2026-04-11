import 'package:antrian/features/home/application/home_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  HomeState build() => HomeState();

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    // Simulasi fetch — ganti dengan repo call sungguhan
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isLoading: false,
      stats: const DashboardStats(
        totalHariIni: 247,
        selesai: 189,
        menunggu: 42,
        dibatalkan: 16,
        rataWaktuMenit: 14,
      ),
      antrianAktif: _dummyAntrian,
      zonaList: _dummyZona,
      riwayat: _dummyRiwayat,
      ringkasanLayanan: _dummyRingkasan,
    );
  }

  Future<void> refresh() => load();
}

const _dummyAntrian = [
  AntrianItem(
    nomor: 'A-058',
    nama: 'Budi Santoso',
    layanan: 'Administrasi',
    loket: 'Loket 2',
    status: AntrianStatus.dipanggil,
  ),
  AntrianItem(
    nomor: 'A-059',
    nama: 'Siti Rahayu',
    layanan: 'Informasi',
    loket: '-',
    status: AntrianStatus.menunggu,
  ),
  AntrianItem(
    nomor: 'B-021',
    nama: 'Agus Wibowo',
    layanan: 'Keuangan',
    loket: 'Loket 3',
    status: AntrianStatus.dipanggil,
  ),
  AntrianItem(
    nomor: 'B-022',
    nama: 'Dewi Lestari',
    layanan: 'Keuangan',
    loket: '-',
    status: AntrianStatus.menunggu,
  ),
  AntrianItem(
    nomor: 'C-011',
    nama: 'Hendra Gunawan',
    layanan: 'Teknis',
    loket: 'Loket 1',
    status: AntrianStatus.selesai,
  ),
];

const _dummyZona = [
  ZonaItem(nama: 'Zona A — Administrasi', terisi: 18, kapasitas: 25),
  ZonaItem(nama: 'Zona B — Keuangan', terisi: 22, kapasitas: 25),
  ZonaItem(nama: 'Zona C — Teknis', terisi: 8, kapasitas: 20),
];

const _dummyRiwayat = [
  RiwayatItem(
    nomor: 'A-057',
    layanan: 'Administrasi',
    waktu: '10:42',
    status: AntrianStatus.selesai,
  ),
  RiwayatItem(
    nomor: 'B-020',
    layanan: 'Keuangan',
    waktu: '10:38',
    status: AntrianStatus.selesai,
  ),
  RiwayatItem(
    nomor: 'A-056',
    layanan: 'Administrasi',
    waktu: '10:31',
    status: AntrianStatus.dibatalkan,
  ),
  RiwayatItem(
    nomor: 'C-010',
    layanan: 'Teknis',
    waktu: '10:28',
    status: AntrianStatus.selesai,
  ),
  RiwayatItem(
    nomor: 'B-019',
    layanan: 'Keuangan',
    waktu: '10:15',
    status: AntrianStatus.selesai,
  ),
];

const _dummyRingkasan = [
  RingkasanLayanan(nama: 'Administrasi', total: 98, selesai: 76, menunggu: 22),
  RingkasanLayanan(nama: 'Keuangan', total: 87, selesai: 71, menunggu: 16),
  RingkasanLayanan(nama: 'Informasi', total: 42, selesai: 32, menunggu: 10),
  RingkasanLayanan(nama: 'Teknis', total: 20, selesai: 10, menunggu: 10),
];
