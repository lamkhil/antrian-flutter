import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_filament/flutter_filament.dart';

/// Generic Firestore-backed [DataSource] for flutter_filament resources.
///
/// Sorting/filtering is done client-side after a one-shot fetch — fine for
/// the small admin collections in this app. Switch to server-side queries
/// when collections grow.
class FirestoreDataSource<T> extends DataSource<T> {
  final CollectionReference<Map<String, dynamic>> collection;
  final T Function(Map<String, dynamic> map) fromMap;
  final Map<String, dynamic> Function(T record) toMap;
  final String Function(T record) idOf;
  final bool Function(T record, String query)? searchMatcher;

  /// Hook for derived create logic (e.g. AppUser needs Firebase Auth signup
  /// before the Firestore doc). Receives the form data; returns the persisted
  /// record. If null, falls back to writing `data` straight to Firestore.
  final Future<T> Function(Map<String, dynamic> data)? createOverride;

  /// Hook called after a successful [delete] (e.g. clean up Firebase Auth user).
  final Future<void> Function(String id)? deleteHook;

  /// Always-on equality filters applied at the Firestore query level.
  /// Used by relation managers to scope results (e.g. `{'counterId': 'abc'}`).
  final Map<String, dynamic>? whereEquals;

  FirestoreDataSource({
    required this.collection,
    required this.fromMap,
    required this.toMap,
    required this.idOf,
    this.searchMatcher,
    this.createOverride,
    this.deleteHook,
    this.whereEquals,
  });

  Query<Map<String, dynamic>> get _baseQuery {
    Query<Map<String, dynamic>> q = collection;
    if (whereEquals != null) {
      whereEquals!.forEach((field, value) {
        q = q.where(field, isEqualTo: value);
      });
    }
    return q;
  }

  Map<String, dynamic> _readDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
      {...d.data(), 'id': d.id};

  Map<String, dynamic> _readSnap(DocumentSnapshot<Map<String, dynamic>> d) =>
      {...?d.data(), 'id': d.id};

  @override
  Future<PaginatedResult<T>> list(ListQuery query) async {
    final snap = await _baseQuery.get();
    Iterable<T> rows = snap.docs.map((d) => fromMap(_readDoc(d)));

    if (query.search != null && query.search!.isNotEmpty) {
      final q = query.search!.toLowerCase();
      rows = rows.where((r) =>
          searchMatcher?.call(r, q) ??
          toMap(r).values.any((v) =>
              v != null && v.toString().toLowerCase().contains(q)));
    }
    for (final entry in query.filters.entries) {
      if (entry.value == null) continue;
      rows = rows.where((r) => toMap(r)[entry.key] == entry.value);
    }

    final list = rows.toList();
    if (query.sortBy != null) {
      list.sort((a, b) {
        final av = toMap(a)[query.sortBy];
        final bv = toMap(b)[query.sortBy];
        if (av == null && bv == null) return 0;
        if (av == null) return 1;
        if (bv == null) return -1;
        final cmp = Comparable.compare(av as Comparable, bv as Comparable);
        return query.sortDesc ? -cmp : cmp;
      });
    }

    final total = list.length;
    final start = (query.page - 1) * query.perPage;
    final end = (start + query.perPage).clamp(0, total);
    final page = start >= total ? <T>[] : list.sublist(start, end);
    return PaginatedResult(
      data: page,
      total: total,
      page: query.page,
      perPage: query.perPage,
    );
  }

  @override
  Future<T?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return fromMap(_readSnap(doc));
  }

  @override
  Future<T> create(Map<String, dynamic> data) async {
    if (createOverride != null) return createOverride!(data);
    final clean = Map<String, dynamic>.from(data)
      ..remove('id')
      ..['createdAt'] = FieldValue.serverTimestamp();
    final ref = await collection.add(clean);
    final snap = await ref.get();
    return fromMap(_readSnap(snap));
  }

  @override
  Future<T> update(String id, Map<String, dynamic> data) async {
    final clean = Map<String, dynamic>.from(data)..remove('id');
    await collection.doc(id).set(clean, SetOptions(merge: true));
    final snap = await collection.doc(id).get();
    return fromMap(_readSnap(snap));
  }

  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
    if (deleteHook != null) await deleteHook!(id);
  }

  @override
  Stream<List<T>>? watch(ListQuery query) {
    return _baseQuery.snapshots().map(
          (snap) => snap.docs.map((d) => fromMap(_readDoc(d))).toList(),
        );
  }
}
