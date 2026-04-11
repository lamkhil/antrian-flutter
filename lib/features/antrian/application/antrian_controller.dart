import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:antrian/data/models/antrian.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'antrian_controller.g.dart';

class AntrianState {
  final List<Antrian> antrian;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final DateTime tanggalDari;
  final DateTime tanggalSampai;
  final StatusAntrian? filterStatus;
  final DocumentSnapshot? lastDoc; // cursor

  AntrianState({
    this.antrian = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    required this.tanggalDari,
    required this.tanggalSampai,
    this.filterStatus,
    this.lastDoc,
  });

  AntrianState copyWith({
    List<Antrian>? antrian,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    DateTime? tanggalDari,
    DateTime? tanggalSampai,
    StatusAntrian? filterStatus,
    bool clearFilterStatus = false,
    DocumentSnapshot? lastDoc,
    bool clearLastDoc = false,
  }) => AntrianState(
    antrian: antrian ?? this.antrian,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    error: error,
    tanggalDari: tanggalDari ?? this.tanggalDari,
    tanggalSampai: tanggalSampai ?? this.tanggalSampai,
    filterStatus: clearFilterStatus ? null : filterStatus ?? this.filterStatus,
    lastDoc: clearLastDoc ? null : lastDoc ?? this.lastDoc,
  );

  // Validasi: range max 30 hari
  static const int maxRangeHari = 30;

  static DateTime defaultDari() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime defaultSampai() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
}

@riverpod
class AntrianController extends _$AntrianController {
  int kPageSize = 20;
  @override
  AntrianState build() {
    return AntrianState(
      tanggalDari: AntrianState.defaultDari(),
      tanggalSampai: AntrianState.defaultSampai(),
    );
  }

  final _db = FirebaseFirestore.instance;

  // ── Load pertama / reset ──────────────────────────────

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      clearLastDoc: true,
      antrian: [],
      hasMore: true,
    );

    try {
      final (data, lastDoc) = await _fetch(startAfter: null);
      state = state.copyWith(
        antrian: data,
        isLoading: false,
        hasMore: data.length == kPageSize,
        lastDoc: lastDoc,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Load more (next page) ─────────────────────────────

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.lastDoc == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final (data, lastDoc) = await _fetch(startAfter: state.lastDoc);
      state = state.copyWith(
        antrian: [...state.antrian, ...data],
        isLoadingMore: false,
        hasMore: data.length == kPageSize,
        lastDoc: lastDoc,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  // ── Set filter tanggal (max 30 hari) ─────────────────

  Future<void> setTanggal({
    required DateTime dari,
    required DateTime sampai,
  }) async {
    // Paksa max 30 hari
    final diff = sampai.difference(dari).inDays;
    final effectiveDari = diff > AntrianState.maxRangeHari
        ? sampai.subtract(const Duration(days: AntrianState.maxRangeHari))
        : dari;

    final normalDari = DateTime(
      effectiveDari.year,
      effectiveDari.month,
      effectiveDari.day,
    );
    final normalSampai = DateTime(
      sampai.year,
      sampai.month,
      sampai.day,
      23,
      59,
      59,
    );

    state = state.copyWith(
      tanggalDari: normalDari,
      tanggalSampai: normalSampai,
    );

    await load();
  }

  // ── Set filter status ─────────────────────────────────

  Future<void> setFilterStatus(StatusAntrian? status) async {
    state = status == null
        ? state.copyWith(clearFilterStatus: true)
        : state.copyWith(filterStatus: status);
    await load();
  }

  // ── Firestore query ───────────────────────────────────

  Future<(List<Antrian>, DocumentSnapshot?)> _fetch({
    required DocumentSnapshot? startAfter,
  }) async {
    var query = _db
        .collection('tickets')
        .where(
          'waktuDaftar',
          isGreaterThanOrEqualTo: Timestamp.fromDate(state.tanggalDari),
        )
        .where(
          'waktuDaftar',
          isLessThanOrEqualTo: Timestamp.fromDate(state.tanggalSampai),
        )
        .orderBy('waktuDaftar', descending: true)
        .limit(kPageSize);

    if (state.filterStatus != null) {
      query = query.where('status', isEqualTo: state.filterStatus!.name);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();

    if (snap.docs.isEmpty) return (<Antrian>[], null);

    final data = snap.docs.map((doc) {
      final json = doc.data();
      json['id'] = doc.id;
      return Antrian.fromJson(json);
    }).toList();

    return (data, snap.docs.last);
  }
}
