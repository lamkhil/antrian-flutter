import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import '../../data/models/zona.dart';
import '../../data/services/firestore_data_source.dart';
import '../../data/services/reference_cache.dart';
import '../lokasi/lokasi_resource.dart';

final zonaDataSource = FirestoreDataSource<Zona>(
  collectionPath: 'zones',
  fromJson: Zona.fromJson,
  toJson: (r) => r.toJson(),
  idOf: (r) => r.id,
  scopeField: 'lokasiId',
  // Denormalisasi: enrich payload dengan objek `lokasi` lengkap.
  beforeWrite: (data) async {
    final lokasiId = data['lokasiId'] as String?;
    if (lokasiId != null) {
      final lokasi = lokasiCache.findById(lokasiId);
      if (lokasi != null) data['lokasi'] = lokasi.toJson();
    }
    return data;
  },
);

final zonaCache = ReferenceCache<Zona>(
  source: zonaDataSource,
  labelOf: (z) => z.nama,
);

class ZonaResource extends Resource<Zona> {
  @override String get slug => 'zona';
  @override String get label => 'Zona';
  @override String get pluralLabel => 'Zona';
  @override IconData get icon => Icons.dashboard_outlined;
  @override String? get navigationGroup => 'Master Data';
  @override int get navigationSort => 20;

  @override
  DataSource<Zona> get dataSource => zonaDataSource;

  @override String recordId(Zona r) => r.id;
  @override String recordTitle(Zona r) => r.nama;
  @override Map<String, dynamic> toFormData(Zona r) => r.toJson();

  @override
  FormSchema form(ResourceContext<Zona> ctx) => FormSchema(
    columns: 2,
    components: [
      Section(
        title: 'Informasi Zona',
        icon: Icons.info_outline,
        columns: 2,
        children: [
          TextInput(name: 'kode', label: 'Kode', required: true),
          TextInput(name: 'nama', label: 'Nama', required: true),
          Select<String>(
            name: 'lokasiId',
            label: 'Lokasi',
            required: true,
            options: lokasiCache.selectOptions(),
            columnSpan: 2,
          ),
          NumberInput(
            name: 'kapasitas',
            label: 'Kapasitas',
            defaultValue: 10,
            min: 0,
          ),
          Select<String>(
            name: 'status',
            label: 'Status',
            defaultValue: 'aktif',
            options: const [
              SelectOption('aktif', 'Aktif'),
              SelectOption('nonAktif', 'Non-aktif'),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  TableSchema<Zona> table() => TableSchema<Zona>(
    defaultSort: 'nama',
    columns: [
      TextColumn<Zona>(
        name: 'kode', label: 'Kode',
        accessor: (r) => r.kode,
        searchable: true, sortable: true,
      ),
      TextColumn<Zona>(
        name: 'nama', label: 'Nama',
        accessor: (r) => r.nama,
        searchable: true, sortable: true, bold: true,
      ),
      TextColumn<Zona>(
        name: 'lokasi', label: 'Lokasi',
        accessor: (r) => r.lokasi.nama,
      ),
      TextColumn<Zona>(
        name: 'kapasitas', label: 'Kapasitas',
        accessor: (r) => r.kapasitas,
        align: ColumnAlign.end,
      ),
      BadgeColumn<Zona>(
        name: 'status', label: 'Status',
        accessor: (r) => r.status == StatusZona.aktif ? 'Aktif' : 'Non-aktif',
        color: (r) => r.status == StatusZona.aktif
            ? const Color(0xFF10B981)
            : const Color(0xFF6B7280),
      ),
    ],
    filters: [
      TableFilter(
        name: 'status',
        label: 'Status',
        options: const [
          TableFilterOption('aktif', 'Aktif'),
          TableFilterOption('nonAktif', 'Non-aktif'),
        ],
      ),
    ],
    rowActions: [
      RowAction.view<Zona>((ctx, row) async {}),
      RowAction.edit<Zona>((ctx, row) async {}),
      RowAction.delete<Zona>((ctx, row) async {
        await zonaDataSource.delete(row.id);
      }),
    ],
  );
}
