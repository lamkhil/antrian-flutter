import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:antrian/data/services/zona/zona_services.dart';
import 'package:antrian/features/zona/application/zona_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_zona_controller.g.dart';

enum DetailZonaStatus { initial, loading, success, error }

class DetailZonaState {
  final String? error;
  final Zona? zona;
  final DetailZonaStatus status;

  const DetailZonaState({
    this.error,
    this.zona,
    this.status = DetailZonaStatus.initial,
  });

  DetailZonaState copyWith({
    List<Layanan>? layanan,
    String? error,
    Zona? zona,
    DetailZonaStatus? status,
  }) {
    return DetailZonaState(
      error: error ?? this.error,
      zona: zona ?? this.zona,
      status: status ?? this.status,
    );
  }
}

@riverpod
class DetailZonaController extends _$DetailZonaController {
  @override
  DetailZonaState build() {
    return const DetailZonaState();
  }

  void loadZona(String id) async {
    state = state.copyWith(status: DetailZonaStatus.loading);
    final result = await ZonaServices.fetchZonaById(id);
    if (result.success) {
      state = state.copyWith(
        zona: result.data,
        status: DetailZonaStatus.success,
      );
    } else {
      state = state.copyWith(
        error: result.message,
        status: DetailZonaStatus.error,
      );
    }
  }
}
