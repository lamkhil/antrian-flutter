import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/data/models/zona.dart';

class RingkasanLayanan {
  final String nama;
  final int total;
  final int selesai;
  final int menunggu;

  const RingkasanLayanan({
    required this.nama,
    required this.total,
    required this.selesai,
    required this.menunggu,
  });
}

class HomeState {
  final bool isLoading;
  final String? error;
  final List<Antrian> antrianHariIni;
  final List<Zona> zonaList;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.antrianHariIni = const [],
    this.zonaList = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    List<Antrian>? antrianHariIni,
    List<Zona>? zonaList,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      antrianHariIni: antrianHariIni ?? this.antrianHariIni,
      zonaList: zonaList ?? this.zonaList,
    );
  }

  int get totalHariIni => antrianHariIni.length;

  int countByStatus(StatusAntrian s) =>
      antrianHariIni.where((a) => a.status == s).length;

  int get selesai => countByStatus(StatusAntrian.selesai);
  int get menunggu => countByStatus(StatusAntrian.menunggu);
  int get dilewati => countByStatus(StatusAntrian.dilewati);

  /// Rata-rata durasi tunggu (menit) — waktuDaftar → waktuDipanggil.
  double get rataTungguMenit {
    final called = antrianHariIni
        .where((a) => a.waktuDipanggil != null)
        .map((a) => a.waktuDipanggil!.difference(a.waktuDaftar).inSeconds)
        .toList();
    if (called.isEmpty) return 0;
    final avgSec = called.reduce((a, b) => a + b) / called.length;
    return avgSec / 60.0;
  }

  /// Antrian yang sedang berjalan hari ini (maksimal 5, terbaru dulu).
  List<Antrian> get antrianAktif {
    final active = antrianHariIni
        .where(
          (a) =>
              a.status == StatusAntrian.menunggu ||
              a.status == StatusAntrian.dipanggil ||
              a.status == StatusAntrian.dilayani,
        )
        .toList();
    active.sort((a, b) => b.waktuDaftar.compareTo(a.waktuDaftar));
    return active.take(5).toList();
  }

  /// Riwayat transaksi hari ini (maksimal 5, terbaru dulu).
  List<Antrian> get riwayat {
    final done = antrianHariIni
        .where(
          (a) =>
              a.status == StatusAntrian.selesai ||
              a.status == StatusAntrian.dilewati,
        )
        .toList();
    done.sort((a, b) {
      final at = a.waktuSelesai ?? a.waktuDipanggil ?? a.waktuDaftar;
      final bt = b.waktuSelesai ?? b.waktuDipanggil ?? b.waktuDaftar;
      return bt.compareTo(at);
    });
    return done.take(5).toList();
  }

  /// Ringkasan jumlah antrian per nama layanan.
  List<RingkasanLayanan> get ringkasanLayanan {
    final totals = <String, int>{};
    final selesais = <String, int>{};
    final menunggus = <String, int>{};
    for (final a in antrianHariIni) {
      final k = a.layanan.nama;
      totals[k] = (totals[k] ?? 0) + 1;
      if (a.status == StatusAntrian.selesai) {
        selesais[k] = (selesais[k] ?? 0) + 1;
      }
      if (a.status == StatusAntrian.menunggu) {
        menunggus[k] = (menunggus[k] ?? 0) + 1;
      }
    }
    final list = totals.entries
        .map(
          (e) => RingkasanLayanan(
            nama: e.key,
            total: e.value,
            selesai: selesais[e.key] ?? 0,
            menunggu: menunggus[e.key] ?? 0,
          ),
        )
        .toList();
    list.sort((a, b) => b.total.compareTo(a.total));
    return list;
  }
}
