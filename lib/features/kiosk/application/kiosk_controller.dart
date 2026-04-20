import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/services/layanan/layanan_services.dart';
import 'package:antrian/data/services/lokasi/lokasi_services.dart';
import 'package:antrian/data/services/antrian/antrian_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kiosk_controller.g.dart';

enum KioskStatus { loadingLokasi, pilihLokasi, pilihLayanan, cetak, error }

class KioskState {
  final KioskStatus status;
  final String? error;
  final List<Lokasi> lokasiList;
  final Lokasi? lokasi;
  final List<Layanan> layananList;
  final Antrian? tiket; // hasil cetak terakhir

  const KioskState({
    this.status = KioskStatus.loadingLokasi,
    this.error,
    this.lokasiList = const [],
    this.lokasi,
    this.layananList = const [],
    this.tiket,
  });

  KioskState copyWith({
    KioskStatus? status,
    String? error,
    List<Lokasi>? lokasiList,
    Lokasi? lokasi,
    List<Layanan>? layananList,
    Antrian? tiket,
    bool clearTiket = false,
  }) => KioskState(
    status: status ?? this.status,
    error: error,
    lokasiList: lokasiList ?? this.lokasiList,
    lokasi: lokasi ?? this.lokasi,
    layananList: layananList ?? this.layananList,
    tiket: clearTiket ? null : tiket ?? this.tiket,
  );
}

@riverpod
class KioskController extends _$KioskController {
  @override
  KioskState build() {
    Future.microtask(_loadLokasi);
    return const KioskState();
  }

  Future<void> _loadLokasi() async {
    final result = await LokasiServices.fetchLokasi();
    if (!result.success || result.data == null) {
      state = state.copyWith(
        status: KioskStatus.error,
        error: result.message,
      );
      return;
    }
    final list = result.data!;
    if (list.length == 1) {
      await pilihLokasi(list.first);
    } else {
      state = state.copyWith(
        status: KioskStatus.pilihLokasi,
        lokasiList: list,
      );
    }
  }

  Future<void> pilihLokasi(Lokasi lokasi) async {
    state = state.copyWith(
      lokasi: lokasi,
      status: KioskStatus.loadingLokasi,
    );
    final result = await LayananServices.fetchByLokasi(lokasi);
    if (!result.success || result.data == null) {
      state = state.copyWith(
        status: KioskStatus.error,
        error: result.message,
      );
      return;
    }
    final aktif = result.data!
        .where((l) => l.status == StatusLayanan.aktif)
        .toList();
    state = state.copyWith(
      status: KioskStatus.pilihLayanan,
      layananList: aktif,
    );
  }

  Future<void> ambilTiket(Layanan layanan) async {
    state = state.copyWith(status: KioskStatus.cetak);
    final result = await AntrianServices.ambilTiket(layanan);
    if (!result.success) {
      state = state.copyWith(
        status: KioskStatus.error,
        error: result.message,
      );
      return;
    }
    state = state.copyWith(tiket: result.data);
  }

  void kembaliKeLayanan() {
    state = state.copyWith(
      status: KioskStatus.pilihLayanan,
      clearTiket: true,
    );
  }

  void gantiLokasi() {
    state = state.copyWith(
      status: KioskStatus.pilihLokasi,
      lokasi: null,
      layananList: const [],
      clearTiket: true,
    );
  }
}
