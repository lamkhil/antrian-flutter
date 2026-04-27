import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import '../../data/models/lokasi.dart';
import '../../data/services/firestore_data_source.dart';
import '../../data/services/reference_cache.dart';

final lokasiDataSource = FirestoreDataSource<Lokasi>(
  collectionPath: 'locations',
  fromJson: Lokasi.fromJson,
  toJson: (r) => r.toJson(),
  idOf: (r) => r.id,
);

/// Cache untuk Select lokasi di resource anak (Zona, Layanan, Loket).
final lokasiCache = ReferenceCache<Lokasi>(
  source: lokasiDataSource,
  labelOf: (l) => l.nama,
);

class LokasiResource extends Resource<Lokasi> {
  @override String get slug => 'lokasi';
  @override String get label => 'Lokasi';
  @override String get pluralLabel => 'Lokasi';
  @override IconData get icon => Icons.location_on_outlined;
  @override String? get navigationGroup => 'Master Data';
  @override int get navigationSort => 10;

  @override
  DataSource<Lokasi> get dataSource => lokasiDataSource;

  @override String recordId(Lokasi r) => r.id;
  @override String recordTitle(Lokasi r) => r.nama;
  @override Map<String, dynamic> toFormData(Lokasi r) => r.toJson();

  @override
  FormSchema form(ResourceContext<Lokasi> ctx) => FormSchema(
    columns: 2,
    components: [
      TextInput(
        name: 'nama',
        label: 'Nama Lokasi',
        required: true,
        columnSpan: 2,
      ),
      Textarea(
        name: 'alamat',
        label: 'Alamat',
        rows: 3,
        required: true,
        columnSpan: 2,
      ),
    ],
  );

  @override
  TableSchema<Lokasi> table() => TableSchema<Lokasi>(
    defaultSort: 'nama',
    columns: [
      TextColumn<Lokasi>(
        name: 'nama', label: 'Nama',
        accessor: (r) => r.nama,
        searchable: true, sortable: true, bold: true,
      ),
      TextColumn<Lokasi>(
        name: 'alamat', label: 'Alamat',
        accessor: (r) => r.alamat,
        searchable: true,
      ),
    ],
    rowActions: [
      RowAction.view<Lokasi>((ctx, row) async {}),
      RowAction.edit<Lokasi>((ctx, row) async {}),
      RowAction.delete<Lokasi>((ctx, row) async {
        await lokasiDataSource.delete(row.id);
      }),
    ],
  );
}
