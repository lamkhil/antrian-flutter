import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/loket.dart';
import 'package:antrian/data/services/loket/loket_services.dart';
import 'package:antrian/globals/widgets/app_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loket_layanan_controller.g.dart';

enum LoketLayananStatus { initial, loading, success, error }

class LoketLayananState {
  final String? error;
  final List<Loket> loket;
  final LoketLayananStatus status;

  const LoketLayananState({
    this.error,
    this.loket = const [],
    this.status = LoketLayananStatus.initial,
  });

  LoketLayananState copyWith({
    String? error,
    List<Loket>? loket,
    LoketLayananStatus? status,
  }) {
    return LoketLayananState(
      error: error ?? this.error,
      loket: loket ?? this.loket,
      status: status ?? this.status,
    );
  }
}

@riverpod
class LoketLayananController extends _$LoketLayananController {
  @override
  LoketLayananState build() => const LoketLayananState();

  Future<void> loadLoket(String layananId) async {
    state = state.copyWith(status: LoketLayananStatus.loading);
    final result = await LoketServices.fetchByLayanan(layananId);
    if (result.success) {
      state = state.copyWith(
        loket: result.data,
        status: LoketLayananStatus.success,
      );
    } else {
      state = state.copyWith(
        error: result.message,
        status: LoketLayananStatus.error,
      );
    }
  }

  Future<void> tambahLoket({
    required Layanan layanan,
    required String kode,
    required String nama,
    String? petugas,
    required StatusLoket status,
  }) async {
    final id = FirebaseFirestore.instance.collection('counters').doc().id;
    final newLoket = Loket(
      id: id,
      layananId: layanan.id,
      zonaId: layanan.zonaId,
      lokasiId: layanan.lokasiId,
      layanan: layanan,
      zona: layanan.zona,
      lokasi: layanan.lokasi,
      kode: kode,
      nama: nama,
      petugas: petugas,
      status: status,
    );
    AppDialog.loading(message: 'Menambahkan loket...');
    final result = await LoketServices.add(newLoket);
    AppDialog.close();
    if (result.success) {
      state = state.copyWith(
        loket: [...state.loket, newLoket],
        status: LoketLayananStatus.success,
      );
    } else {
      state = state.copyWith(
        error: result.message,
        status: LoketLayananStatus.error,
      );
    }
  }

  Future<void> editLoket(Loket loket) async {
    final index = state.loket.indexWhere((l) => l.id == loket.id);
    if (index == -1) {
      AppDialog.error(message: 'Loket tidak ditemukan');
      return;
    }
    AppDialog.loading(message: 'Menyimpan perubahan...');
    final result = await LoketServices.update(loket);
    AppDialog.close();
    if (!result.success) {
      AppDialog.error(message: result.message ?? 'Gagal menyimpan perubahan');
      return;
    }
    final updated = [...state.loket];
    updated[index] = loket;
    state = state.copyWith(loket: updated);
  }

  Future<void> hapusLoket(String id) async {
    AppDialog.loading(message: 'Menghapus loket...');
    final result = await LoketServices.delete(id);
    AppDialog.close();
    if (result.success) {
      state = state.copyWith(
        loket: state.loket.where((l) => l.id != id).toList(),
      );
    } else {
      AppDialog.error(message: result.message ?? 'Gagal menghapus loket');
    }
  }
}
