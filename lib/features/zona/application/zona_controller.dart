import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:antrian/data/services/zona/zona_services.dart';
import 'package:antrian/globals/widgets/app_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'zona_controller.g.dart';

enum ZonaStateStatus { initial, loading, success, error }

class ZonaState {
  final String? error;
  final List<Zona> zona;
  final ZonaStateStatus status;

  const ZonaState({
    this.error,
    this.zona = const [],
    this.status = ZonaStateStatus.initial,
  });

  ZonaState copyWith({
    String? error,
    List<Zona>? zona,
    ZonaStateStatus? status,
  }) {
    return ZonaState(
      error: error ?? this.error,
      zona: zona ?? this.zona,
      status: status ?? this.status,
    );
  }
}

@riverpod
class ZonaController extends _$ZonaController {
  @override
  ZonaState build() {
    Future.microtask(loadZona);
    return const ZonaState();
  }

  Future<void> loadZona({Lokasi? lokasi}) async {
    state = state.copyWith(status: ZonaStateStatus.loading);
    final result = await ZonaServices.fetchZona(lokasi: lokasi);
    // Simulasi fetch data
    state = state.copyWith(zona: result.data, status: ZonaStateStatus.success);
  }

  Future<void> tambah({
    required String kode,
    required String nama,
    required Lokasi lokasi,
    required int kapasitas,
    required StatusZona status,
  }) async {
    final id = FirebaseFirestore.instance.collection('zones').doc().id;
    final newZona = Zona(
      id: id,
      kode: kode,
      nama: nama,
      lokasiId: lokasi.id,
      lokasi: lokasi,
      kapasitas: kapasitas,
    );
    AppDialog.loading(message: 'Menambahkan zona...');
    final result = await ZonaServices.addZona(newZona);
    AppDialog.close();
    if (result.success) {
      state = state.copyWith(zona: [...state.zona, result.data!]);
    } else {
      AppDialog.error(message: result.message ?? 'Gagal menambahkan zona');
    }
  }

  Future<void> edit(
    String id, {
    required String kode,
    required String nama,
    required String lokasiId,
    required Lokasi lokasi,
    required int kapasitas,
    required StatusZona status,
  }) async {
    final index = state.zona.indexWhere((z) => z.id == id);
    if (index == -1) return;

    final updatedZona = state.zona[index].copyWith(
      kode: kode,
      nama: nama,
      lokasiId: lokasiId,
      lokasi: lokasi,
      kapasitas: kapasitas,
      status: status,
    );
    AppDialog.loading(message: 'Mengubah zona...');

    final result = await ZonaServices.updateZona(updatedZona);

    AppDialog.close();

    if (result.success) {
      final newZonaList = state.zona.toList();
      newZonaList[index] = result.data!;
      state = state.copyWith(zona: newZonaList);
    } else {
      AppDialog.error(message: result.message ?? 'Gagal mengubah zona');
    }
  }

  Future<void> hapus(String id) async {
    AppDialog.loading(message: 'Menghapus zona...');
    final result = await ZonaServices.deleteZona(id);
    AppDialog.close();
    if (result.success) {
      state = state.copyWith(
        zona: state.zona.where((z) => z.id != id).toList(),
      );
    } else {
      AppDialog.error(message: result.message ?? 'Gagal menghapus zona');
    }
  }
}
