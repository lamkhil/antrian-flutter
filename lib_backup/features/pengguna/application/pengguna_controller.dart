import 'package:antrian/data/models/pengguna.dart';
import 'package:antrian/data/services/pengguna/pengguna_services.dart';
import 'package:antrian/globals/widgets/app_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pengguna_controller.g.dart';

enum PenggunaStateStatus { initial, loading, success, error }

class PenggunaState {
  final String? error;
  final List<Pengguna> pengguna;
  final PenggunaStateStatus status;

  const PenggunaState({
    this.error,
    this.pengguna = const [],
    this.status = PenggunaStateStatus.initial,
  });

  PenggunaState copyWith({
    String? error,
    List<Pengguna>? pengguna,
    PenggunaStateStatus? status,
  }) => PenggunaState(
    error: error ?? this.error,
    pengguna: pengguna ?? this.pengguna,
    status: status ?? this.status,
  );
}

@riverpod
class PenggunaController extends _$PenggunaController {
  @override
  PenggunaState build() {
    Future.microtask(load);
    return const PenggunaState();
  }

  Future<void> load() async {
    state = state.copyWith(status: PenggunaStateStatus.loading);
    final result = await PenggunaServices.fetchAll();
    if (result.success) {
      state = state.copyWith(
        pengguna: result.data,
        status: PenggunaStateStatus.success,
      );
    } else {
      state = state.copyWith(
        error: result.message,
        status: PenggunaStateStatus.error,
      );
    }
  }

  Future<void> tambah({
    required String nama,
    required String email,
    required RolePengguna role,
    required StatusPengguna status,
    String? lokasiId,
  }) async {
    final id = FirebaseFirestore.instance.collection('users').doc().id;
    final newPengguna = Pengguna(
      id: id,
      nama: nama,
      email: email,
      role: role,
      status: status,
      lokasiId: lokasiId,
    );
    AppDialog.loading(message: 'Menambahkan pengguna...');
    final result = await PenggunaServices.add(newPengguna);
    AppDialog.close();
    if (result.success) {
      state = state.copyWith(pengguna: [...state.pengguna, newPengguna]);
    } else {
      AppDialog.error(message: result.message ?? 'Gagal menambahkan pengguna');
    }
  }

  Future<void> edit(Pengguna updated) async {
    final index = state.pengguna.indexWhere((p) => p.id == updated.id);
    if (index == -1) {
      AppDialog.error(message: 'Pengguna tidak ditemukan');
      return;
    }
    AppDialog.loading(message: 'Menyimpan perubahan...');
    final result = await PenggunaServices.update(updated);
    AppDialog.close();
    if (!result.success) {
      AppDialog.error(message: result.message ?? 'Gagal menyimpan perubahan');
      return;
    }
    final newList = [...state.pengguna];
    newList[index] = updated;
    state = state.copyWith(pengguna: newList);
  }

  Future<void> hapus(String id) async {
    AppDialog.loading(message: 'Menghapus pengguna...');
    final result = await PenggunaServices.delete(id);
    AppDialog.close();
    if (result.success) {
      state = state.copyWith(
        pengguna: state.pengguna.where((p) => p.id != id).toList(),
      );
    } else {
      AppDialog.error(message: result.message ?? 'Gagal menghapus pengguna');
    }
  }
}
