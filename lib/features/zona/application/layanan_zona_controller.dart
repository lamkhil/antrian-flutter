import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:antrian/data/services/zona/zona_services.dart';
import 'package:antrian/features/zona/application/zona_controller.dart';
import 'package:antrian/globals/widgets/app_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'layanan_zona_controller.g.dart';

enum LayananZonaStatus { initial, loading, success, error }

class LayananZonaState {
  final String? error;
  final List<Layanan> layanan;
  final LayananZonaStatus status;

  const LayananZonaState({
    this.error,
    this.layanan = const [],
    this.status = LayananZonaStatus.initial,
  });

  LayananZonaState copyWith({
    String? error,
    List<Layanan>? layanan,
    LayananZonaStatus? status,
  }) {
    return LayananZonaState(
      error: error ?? this.error,
      layanan: layanan ?? this.layanan,
      status: status ?? this.status,
    );
  }
}

@riverpod
class LayananZonaController extends _$LayananZonaController {
  @override
  LayananZonaState build() => const LayananZonaState();

  void loadLayanan(String zonaId) async {
    state = state.copyWith(status: LayananZonaStatus.loading);
    final result = await ZonaServices.fetchLayananByZona(zonaId);
    if (result.success) {
      state = state.copyWith(
        layanan: result.data,
        status: LayananZonaStatus.success,
      );
    } else {
      state = state.copyWith(
        error: result.message,
        status: LayananZonaStatus.error,
      );
    }
  }

  Future<void> tambahLayanan({
    required Zona zona,
    required String kode,
    required String nama,
    required String deskripsi,
    required int durasiMenit,
    required int biaya,
    required StatusLayanan status,
  }) async {
    final id = FirebaseFirestore.instance.collection('services').doc().id;
    final newLayanan = Layanan(
      id: id,
      zonaId: zona.id,
      lokasiId: zona.lokasiId,
      lokasi: zona.lokasi,
      zona: zona,
      kode: kode,
      nama: nama,
      deskripsi: deskripsi,
      durasiMenit: durasiMenit,
      biaya: biaya,
      status: status,
    );
    AppDialog.loading(message: 'Menambahkan layanan...');
    final result = await ZonaServices.addLayanan(newLayanan);
    AppDialog.close();
    if (result.success) {
      state = state.copyWith(
        layanan: [...state.layanan, newLayanan],
        status: LayananZonaStatus.success,
      );
    } else {
      state = state.copyWith(
        error: result.message,
        status: LayananZonaStatus.error,
      );
    }
  }

  void editLayanan(
    String id, {
    required String kode,
    required String nama,
    required String deskripsi,
    required int durasiMenit,
    required int biaya,
    required StatusLayanan status,
  }) {
    state = state.copyWith(
      layanan: state.layanan.map((l) {
        if (l.id != id) return l;
        return l.copyWith(
          kode: kode,
          nama: nama,
          deskripsi: deskripsi,
          durasiMenit: durasiMenit,
          biaya: biaya,
          status: status,
        );
      }).toList(),
    );
  }

  void hapusLayanan(String id) => state = state.copyWith(
    layanan: state.layanan.where((l) => l.id != id).toList(),
  );
}
