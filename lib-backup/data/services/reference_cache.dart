import 'package:flutter_filament/flutter_filament.dart';
import 'firestore_data_source.dart';

/// Cache sinkron untuk opsi `Select` di form resource.
///
/// Firestore call itu async tapi `FormSchema.components` butuh list sinkron.
/// `ReferenceCache` menyimpan satu snapshot terbaru per-collection. Saat
/// pertama diakses, dia fire-and-forget fetch lalu trigger setState via
/// [onUpdate]. Subsequent render membaca dari cache.
class ReferenceCache<T> {
  final FirestoreDataSource<T> source;
  final String Function(T) labelOf;
  final void Function()? onUpdate;

  List<T> _items = const [];
  bool _loading = false;
  bool _loaded = false;

  ReferenceCache({
    required this.source,
    required this.labelOf,
    this.onUpdate,
  });

  List<T> get items => _items;
  bool get loaded => _loaded;

  /// Opsi untuk [Select<String>] — mengembalikan daftar saat ini.
  /// Saat belum loaded, kick off fetch async dan kembalikan list kosong
  /// (UI akan rebuild kalau [onUpdate] dipasang).
  List<SelectOption<String>> selectOptions({
    String Function(T)? idOf,
  }) {
    if (!_loaded && !_loading) _fire();
    final id = idOf ?? source.idOf;
    return _items.map((e) => SelectOption<String>(id(e), labelOf(e))).toList();
  }

  /// Paksa refresh cache.
  Future<void> refresh() async {
    _loading = true;
    try {
      final r = await source.list(const ListQuery(perPage: 500));
      _items = r.data;
      _loaded = true;
    } finally {
      _loading = false;
      onUpdate?.call();
    }
  }

  void _fire() {
    // ignore: discarded_futures
    refresh();
  }

  /// Cari item by id. Null kalau belum dimuat / tidak ada.
  T? findById(String id) {
    for (final e in _items) {
      if (source.idOf(e) == id) return e;
    }
    return null;
  }
}
