import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/services/layanan/layanan_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_layanan_controller.g.dart';

enum DetailLayananStatus { initial, loading, success, error }

class DetailLayananState {
  final String? error;
  final Layanan? layanan;
  final DetailLayananStatus status;

  const DetailLayananState({
    this.error,
    this.layanan,
    this.status = DetailLayananStatus.initial,
  });

  DetailLayananState copyWith({
    String? error,
    Layanan? layanan,
    DetailLayananStatus? status,
  }) {
    return DetailLayananState(
      error: error ?? this.error,
      layanan: layanan ?? this.layanan,
      status: status ?? this.status,
    );
  }
}

@riverpod
class DetailLayananController extends _$DetailLayananController {
  @override
  DetailLayananState build() => const DetailLayananState();

  Future<void> loadLayanan(String id) async {
    state = state.copyWith(status: DetailLayananStatus.loading);
    final result = await LayananServices.fetchById(id);
    if (result.success) {
      state = state.copyWith(
        layanan: result.data,
        status: DetailLayananStatus.success,
      );
    } else {
      state = state.copyWith(
        error: result.message,
        status: DetailLayananStatus.error,
      );
    }
  }
}
