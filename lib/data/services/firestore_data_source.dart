import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_filament/flutter_filament.dart';

/// Generic [DataSource] yang dibacking oleh satu Firestore collection.
///
/// Strategi:
/// - `list()` fetch semua doc yang cocok dengan filter (where clauses), lalu
///   search/sort/paginate di memory. Cocok untuk koleksi kecil–menengah (<5k
///   doc). Untuk koleksi besar, subclass dan override `list()`.
/// - `watch()` pakai `.snapshots()` → real-time update di UI.
/// - `create/update/delete` langsung hit Firestore.
/// Optional hook: dipanggil sebelum create/update untuk enrich payload.
/// Berguna saat model denormalisasi (misal Zona menyimpan `lokasi` object
/// padahal form cuma collect `lokasiId`).
typedef BeforeWrite = Future<Map<String, dynamic>> Function(
  Map<String, dynamic> formData,
);

class FirestoreDataSource<T> extends DataSource<T> {
  final String collectionPath;
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T record) toJson;
  final String Function(T record) idOf;
  final bool Function(T record, String query)? searchMatcher;
  final BeforeWrite? beforeWrite;

  /// Nama field di dokumen yang merujuk tenant (mis. `'lokasiId'`).
  /// Kalau diisi dan [TenantScope] aktif (currentId != null & bukan admin
  /// bypass), semua query otomatis di-scope `where(scopeField, = currentId)`
  /// dan write otomatis diisi `scopeField: currentId`.
  final String? scopeField;

  final FirebaseFirestore? _firestoreOverride;

  FirestoreDataSource({
    required this.collectionPath,
    required this.fromJson,
    required this.toJson,
    required this.idOf,
    this.searchMatcher,
    this.beforeWrite,
    this.scopeField,
    FirebaseFirestore? firestore,
  }) : _firestoreOverride = firestore;

  FirebaseFirestore get _fs => _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _fs.collection(collectionPath);

  /// Hook override kalau subclass perlu tambah `where` clause default.
  /// Built-in: kalau [scopeField] diisi dan tenant aktif, auto `where`.
  Query<Map<String, dynamic>> baseQuery() {
    Query<Map<String, dynamic>> q = _col;
    final tenantId = TenantScope.currentIdStatic;
    if (scopeField != null &&
        tenantId != null &&
        !TenantScope.adminBypassStatic) {
      q = q.where(scopeField!, isEqualTo: tenantId);
    }
    return q;
  }

  @override
  Future<PaginatedResult<T>> list(ListQuery query) async {
    Query<Map<String, dynamic>> q = baseQuery();

    // Apply filters dari UI (SelectFilter, dll).
    for (final entry in query.filters.entries) {
      if (entry.value == null) continue;
      q = q.where(entry.key, isEqualTo: entry.value);
    }

    final snap = await q.get();
    var rows = snap.docs
        .map((d) => fromJson({...d.data(), 'id': d.id}))
        .toList();

    // Search di memory.
    if (query.search != null && query.search!.isNotEmpty) {
      final s = query.search!.toLowerCase();
      rows = rows.where((r) =>
          searchMatcher?.call(r, s) ??
          toJson(r).values.any((v) =>
              v != null && v.toString().toLowerCase().contains(s))).toList();
    }

    // Sort di memory supaya konsisten dgn filter/search.
    if (query.sortBy != null) {
      rows.sort((a, b) {
        final av = toJson(a)[query.sortBy];
        final bv = toJson(b)[query.sortBy];
        if (av == null && bv == null) return 0;
        if (av == null) return 1;
        if (bv == null) return -1;
        final cmp = Comparable.compare(av as Comparable, bv as Comparable);
        return query.sortDesc ? -cmp : cmp;
      });
    }

    final total = rows.length;
    final start = (query.page - 1) * query.perPage;
    final end = (start + query.perPage).clamp(0, total);
    final page = start >= total ? <T>[] : rows.sublist(start, end);

    return PaginatedResult(
      data: page,
      total: total,
      page: query.page,
      perPage: query.perPage,
    );
  }

  @override
  Future<T?> get(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return fromJson({...doc.data()!, 'id': doc.id});
  }

  /// Auto-isi `scopeField` kalau multi-tenant aktif & payload belum punya.
  Map<String, dynamic> _applyTenantScope(Map<String, dynamic> data) {
    final tenantId = TenantScope.currentIdStatic;
    if (scopeField != null &&
        tenantId != null &&
        !TenantScope.adminBypassStatic &&
        !data.containsKey(scopeField)) {
      return {...data, scopeField!: tenantId};
    }
    return data;
  }

  @override
  Future<T> create(Map<String, dynamic> data) async {
    var payload = Map<String, dynamic>.from(data)..remove('id');
    payload = _applyTenantScope(payload);
    if (beforeWrite != null) payload = await beforeWrite!(payload);
    final ref = await _col.add(payload);
    return fromJson({...payload, 'id': ref.id});
  }

  @override
  Future<T> update(String id, Map<String, dynamic> data) async {
    var payload = Map<String, dynamic>.from(data)..remove('id');
    payload = _applyTenantScope(payload);
    if (beforeWrite != null) payload = await beforeWrite!(payload);
    await _col.doc(id).update(payload);
    final doc = await _col.doc(id).get();
    return fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> delete(String id) => _col.doc(id).delete();

  @override
  Stream<List<T>>? watch(ListQuery query) {
    Query<Map<String, dynamic>> q = baseQuery();
    for (final entry in query.filters.entries) {
      if (entry.value == null) continue;
      q = q.where(entry.key, isEqualTo: entry.value);
    }
    return q.snapshots().map((snap) =>
        snap.docs.map((d) => fromJson({...d.data(), 'id': d.id})).toList());
  }
}
