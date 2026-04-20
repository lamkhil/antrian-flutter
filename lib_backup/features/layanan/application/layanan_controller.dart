import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:antrian/data/services/layanan/layanan_services.dart';
import 'package:antrian/features/zona/application/layanan_zona_controller.dart';
import 'package:antrian/globals/providers/lokasi/lokasi_provider.dart';
import 'package:antrian/globals/widgets/app_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'layanan_controller.g.dart';

enum LayananStatus { initial, loading, success, error }

class LayananState {
  final String? error;
  final List<Layanan> layanan;
  final LayananStatus status;

  const LayananState({
    this.error,
    this.layanan = const [],
    this.status = LayananStatus.initial,
  });

  LayananState copyWith({
    String? error,
    List<Layanan>? layanan,
    LayananStatus? status,
  }) {
    return LayananState(
      error: error ?? this.error,
      layanan: layanan ?? this.layanan,
      status: status ?? this.status,
    );
  }
}

@riverpod
class LayananController extends _$LayananController {
  @override
  LayananState build() {
    Future.microtask(load);
    return const LayananState();
  }

  Future<void> load() async {
    final lokasi = ref.read(lokasiControllerProvider).aktif;
    state = state.copyWith(status: LayananStatus.loading);
    final result = await LayananServices.fetchByLokasi(lokasi);
    if (result.success) {
      state = state.copyWith(
        layanan: result.data,
        status: LayananStatus.success,
      );
    } else {
      state = state.copyWith(
        error: result.message,
        status: LayananStatus.error,
      );
    }
  }

  Future<void> tambah({
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
    final result = await LayananServices.add(newLayanan);
    AppDialog.close();
    if (result.success) {
      state = state.copyWith(layanan: [...state.layanan, newLayanan]);
    } else {
      AppDialog.error(message: result.message ?? 'Gagal menambahkan layanan');
    }
  }

  Future<void> edit(Layanan layanan) async {
    final index = state.layanan.indexWhere((l) => l.id == layanan.id);
    if (index != -1) {
      final updatedLayanan = state.layanan[index].copyWith(
        kode: layanan.kode,
        nama: layanan.nama,
        deskripsi: layanan.deskripsi,
        durasiMenit: layanan.durasiMenit,
        biaya: layanan.biaya,
        status: layanan.status,
      );
      AppDialog.loading(message: 'Menyimpan perubahan...');
      final result = await LayananServices.update(updatedLayanan);
      AppDialog.close();
      if (!result.success) {
        AppDialog.error(message: result.message ?? 'Gagal menyimpan perubahan');
        return;
      }
      final updatedList = [...state.layanan];
      updatedList[index] = updatedLayanan;
      state = state.copyWith(layanan: updatedList);
    } else {
      AppDialog.error(message: 'Layanan tidak ditemukan');
    }
  }

  Future<void> hapus(String id) async {
    AppDialog.loading(message: 'Menghapus layanan...');
    final result = await LayananServices.delete(id);
    AppDialog.close();
    if (result.success) {
      state = state.copyWith(
        layanan: state.layanan.where((l) => l.id != id).toList(),
      );
    } else {
      AppDialog.error(message: result.message ?? 'Gagal menghapus layanan');
    }
  }
}
