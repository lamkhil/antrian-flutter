import 'dart:convert';

import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/services/lokasi/lokasi_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'lokasi_provider.g.dart';

enum LokasiStateStatus { inital, loading, success, error }

class LokasiState {
  final List<Lokasi> daftarLokasi;
  final Lokasi? aktif;
  final LokasiStateStatus status;
  final String? error;

  const LokasiState({
    this.daftarLokasi = const [],
    this.aktif,
    this.status = LokasiStateStatus.inital,
    this.error,
  });

  LokasiState copyWith({
    List<Lokasi>? daftarLokasi,
    Lokasi? aktif,
    String? error,
    LokasiStateStatus? status,
  }) {
    return LokasiState(
      daftarLokasi: daftarLokasi ?? this.daftarLokasi,
      error: error ?? this.error,
      aktif: aktif ?? this.aktif,
      status: status ?? this.status,
    );
  }
}

@Riverpod(keepAlive: true)
class LokasiController extends _$LokasiController {
  static const _key = 'lokasi_aktif';

  @override
  LokasiState build() {
    Future.microtask(_init);
    return const LokasiState();
  }

  Future<void> _init() async {
    loadLokasi();
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data != null) {
      try {
        final lokasi = Lokasi.fromJson(jsonDecode(data));
        state = state.copyWith(aktif: lokasi);
        return;
      } catch (e) {
        // kalau corrupt, hapus aja
        prefs.remove(_key);
      }
    }
  }

  Future<void> loadLokasi() async {
    state = state.copyWith(status: LokasiStateStatus.loading);

    final result = await LokasiServices.fetchLokasi();

    if (result.success) {
      state = state.copyWith(
        status: LokasiStateStatus.success,
        daftarLokasi: result.data!,
        aktif: state.aktif != null
            ? result.data!.firstWhere(
                (l) => l.id == state.aktif!.id,
                orElse: () => result.data!.first,
              )
            : result.data!.first,
      );
    } else {
      state = state.copyWith(
        status: LokasiStateStatus.error,
        error: result.message,
      );
    }
  }

  Future<void> setLokasi(Lokasi lokasi) async {
    state = state.copyWith(aktif: lokasi);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(lokasi.toJson()));
  }

  Future<void> clearLokasi() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);

    state = state.copyWith(aktif: null);
  }
}
