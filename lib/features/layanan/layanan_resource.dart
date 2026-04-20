import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import '../../data/models/layanan.dart';
import '../../data/services/firestore_data_source.dart';
import '../../data/services/reference_cache.dart';
import '../zona/zona_resource.dart';

final layananDataSource = FirestoreDataSource<Layanan>(
  collectionPath: 'services',
  fromJson: Layanan.fromJson,
  toJson: (r) => r.toJson(),
  idOf: (r) => r.id,
  beforeWrite: (data) async {
    final zonaId = data['zonaId'] as String?;
    if (zonaId != null) {
      final zona = zonaCache.findById(zonaId);
      if (zona != null) {
        data['zona'] = zona.toJson();
        data['lokasiId'] = zona.lokasiId;
        data['lokasi'] = zona.lokasi.toJson();
      }
    }
    return data;
  },
);

final layananCache = ReferenceCache<Layanan>(
  source: layananDataSource,
  labelOf: (l) => l.nama,
);

class LayananResource extends Resource<Layanan> {
  @override String get slug => 'layanan';
  @override String get label => 'Layanan';
  @override String get pluralLabel => 'Layanan';
  @override IconData get icon => Icons.design_services_outlined;
  @override String? get navigationGroup => 'Master Data';
  @override int get navigationSort => 30;

  @override
  DataSource<Layanan> get dataSource => layananDataSource;

  @override String recordId(Layanan r) => r.id;
  @override String recordTitle(Layanan r) => r.nama;
  @override Map<String, dynamic> toFormData(Layanan r) => r.toJson();

  @override
  FormSchema form(ResourceContext<Layanan> ctx) => FormSchema(
    columns: 2,
    components: [
      Section(
        title: 'Detail Layanan',
        columns: 2,
        children: [
          TextInput(name: 'kode', label: 'Kode', required: true),
          TextInput(name: 'nama', label: 'Nama', required: true),
          Select<String>(
            name: 'zonaId',
            label: 'Zona',
            required: true,
            options: zonaCache.selectOptions(),
            helperText: 'Lokasi otomatis mengikuti zona',
          ),
          NumberInput(
            name: 'durasiMenit',
            label: 'Durasi (menit)',
            defaultValue: 15, min: 1,
          ),
          NumberInput(
            name: 'biaya',
            label: 'Biaya',
            prefix: 'Rp ',
            defaultValue: 0, min: 0,
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
          Textarea(
            name: 'deskripsi', label: 'Deskripsi',
            rows: 3, columnSpan: 2,
          ),
        ],
      ),
    ],
  );

  @override
  TableSchema<Layanan> table() => TableSchema<Layanan>(
    defaultSort: 'nama',
    columns: [
      TextColumn<Layanan>(
        name: 'kode', label: 'Kode',
        accessor: (r) => r.kode,
        searchable: true, sortable: true,
      ),
      TextColumn<Layanan>(
        name: 'nama', label: 'Nama',
        accessor: (r) => r.nama,
        searchable: true, sortable: true, bold: true,
      ),
      TextColumn<Layanan>(
        name: 'zona', label: 'Zona',
        accessor: (r) => r.zona.nama,
      ),
      TextColumn<Layanan>(
        name: 'durasiMenit', label: 'Durasi',
        accessor: (r) => r.durasiMenit,
        formatter: (r) => '${r.durasiMenit} mnt',
        align: ColumnAlign.end,
      ),
      TextColumn<Layanan>(
        name: 'biaya', label: 'Biaya',
        accessor: (r) => r.biaya,
        formatter: (r) => 'Rp ${r.biaya}',
        align: ColumnAlign.end,
      ),
      BadgeColumn<Layanan>(
        name: 'status', label: 'Status',
        accessor: (r) => r.status == StatusLayanan.aktif ? 'Aktif' : 'Non-aktif',
        color: (r) => r.status == StatusLayanan.aktif
            ? const Color(0xFF10B981)
            : const Color(0xFF6B7280),
      ),
    ],
    rowActions: [
      RowAction.view<Layanan>((ctx, row) async {}),
      RowAction.edit<Layanan>((ctx, row) async {}),
      RowAction.delete<Layanan>((ctx, row) async {
        await layananDataSource.delete(row.id);
      }),
    ],
  );
}
