import 'package:antrian/data/services/laporan/laporan_services.dart';
import 'package:antrian/data/services/zona/zona_services.dart';
import 'package:antrian/features/home/application/home_state.dart';
import 'package:antrian/globals/providers/lokasi/lokasi_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  HomeState build() {
    Future.microtask(load);
    return const HomeState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final lokasi = ref.read(lokasiControllerProvider).aktif;
    final now = DateTime.now();
    final dari = DateTime(now.year, now.month, now.day);
    final sampai = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final antrianResult = await LaporanServices.fetchAntrianRange(
      dari: dari,
      sampai: sampai,
      lokasi: lokasi,
    );
    final zonaResult = await ZonaServices.fetchZona(lokasi: lokasi);

    if (!antrianResult.success) {
      state = state.copyWith(isLoading: false, error: antrianResult.message);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      antrianHariIni: antrianResult.data,
      zonaList: zonaResult.success ? zonaResult.data : const [],
    );
  }

  Future<void> refresh() => load();
}
