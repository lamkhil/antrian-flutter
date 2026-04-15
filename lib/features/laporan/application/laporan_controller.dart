import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/data/services/laporan/laporan_services.dart';
import 'package:antrian/globals/providers/lokasi/lokasi_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'laporan_controller.g.dart';

enum LaporanStatus { initial, loading, success, error }

class GrupLaporan {
  final String label;
  final int total;
  const GrupLaporan({required this.label, required this.total});
}

class LaporanState {
  final LaporanStatus status;
  final String? error;
  final DateTime tanggalDari;
  final DateTime tanggalSampai;
  final List<Antrian> antrian;

  const LaporanState({
    this.status = LaporanStatus.initial,
    this.error,
    required this.tanggalDari,
    required this.tanggalSampai,
    this.antrian = const [],
  });

  LaporanState copyWith({
    LaporanStatus? status,
    String? error,
    DateTime? tanggalDari,
    DateTime? tanggalSampai,
    List<Antrian>? antrian,
  }) => LaporanState(
    status: status ?? this.status,
    error: error,
    tanggalDari: tanggalDari ?? this.tanggalDari,
    tanggalSampai: tanggalSampai ?? this.tanggalSampai,
    antrian: antrian ?? this.antrian,
  );

  static DateTime defaultDari() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime defaultSampai() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  int get total => antrian.length;

  int countByStatus(StatusAntrian s) =>
      antrian.where((a) => a.status == s).length;

  /// Rata-rata durasi tunggu (menit) — dari `waktuDaftar` ke `waktuDipanggil`.
  double get rataTungguMenit {
    final called = antrian
        .where((a) => a.waktuDipanggil != null)
        .map((a) => a.waktuDipanggil!.difference(a.waktuDaftar).inSeconds)
        .toList();
    if (called.isEmpty) return 0;
    final avgSec = called.reduce((a, b) => a + b) / called.length;
    return avgSec / 60.0;
  }

  List<GrupLaporan> get perZona => _groupBy((a) => a.zona.nama);
  List<GrupLaporan> get perLayanan => _groupBy((a) => a.layanan.nama);
  List<GrupLaporan> get perLoket {
    final withLoket = antrian.where((a) => a.loket != null).toList();
    return _groupByList(withLoket, (a) => a.loket!.nama);
  }

  List<GrupLaporan> _groupBy(String Function(Antrian) keyFn) =>
      _groupByList(antrian, keyFn);

  List<GrupLaporan> _groupByList(
    List<Antrian> source,
    String Function(Antrian) keyFn,
  ) {
    final map = <String, int>{};
    for (final a in source) {
      final k = keyFn(a);
      map[k] = (map[k] ?? 0) + 1;
    }
    final list = map.entries
        .map((e) => GrupLaporan(label: e.key, total: e.value))
        .toList();
    list.sort((a, b) => b.total.compareTo(a.total));
    return list;
  }
}

@riverpod
class LaporanController extends _$LaporanController {
  @override
  LaporanState build() {
    Future.microtask(load);
    return LaporanState(
      tanggalDari: LaporanState.defaultDari(),
      tanggalSampai: LaporanState.defaultSampai(),
    );
  }

  Future<void> load() async {
    final lokasi = ref.read(lokasiControllerProvider).aktif;
    state = state.copyWith(status: LaporanStatus.loading);
    final result = await LaporanServices.fetchAntrianRange(
      dari: state.tanggalDari,
      sampai: state.tanggalSampai,
      lokasi: lokasi,
    );
    if (result.success) {
      state = state.copyWith(
        antrian: result.data,
        status: LaporanStatus.success,
      );
    } else {
      state = state.copyWith(
        error: result.message,
        status: LaporanStatus.error,
      );
    }
  }

  void setTanggal({required DateTime dari, required DateTime sampai}) {
    state = state.copyWith(tanggalDari: dari, tanggalSampai: sampai);
    load();
  }
}
