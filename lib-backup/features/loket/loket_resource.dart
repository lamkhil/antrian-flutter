import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import '../../data/models/loket.dart';
import '../../data/services/firestore_data_source.dart';
import '../../data/services/reference_cache.dart';
import '../layanan/layanan_resource.dart';

final loketDataSource = FirestoreDataSource<Loket>(
  collectionPath: 'counters',
  fromJson: Loket.fromJson,
  toJson: (r) => r.toJson(),
  idOf: (r) => r.id,
  scopeField: 'lokasiId',
  beforeWrite: (data) async {
    final layananId = data['layananId'] as String?;
    if (layananId != null) {
      final layanan = layananCache.findById(layananId);
      if (layanan != null) {
        data['layanan'] = layanan.toJson();
        data['zonaId'] = layanan.zonaId;
        data['zona'] = layanan.zona.toJson();
        data['lokasiId'] = layanan.lokasiId;
        data['lokasi'] = layanan.lokasi.toJson();
      }
    }
    return data;
  },
);

final loketCache = ReferenceCache<Loket>(
  source: loketDataSource,
  labelOf: (l) => l.nama,
);

class LoketResource extends Resource<Loket> {
  @override String get slug => 'loket';
  @override String get label => 'Loket';
  @override String get pluralLabel => 'Loket';
  @override IconData get icon => Icons.point_of_sale_outlined;
  @override String? get navigationGroup => 'Master Data';
  @override int get navigationSort => 40;

  @override
  DataSource<Loket> get dataSource => loketDataSource;

  @override String recordId(Loket r) => r.id;
  @override String recordTitle(Loket r) => r.nama;
  @override Map<String, dynamic> toFormData(Loket r) => r.toJson();

  @override
  FormSchema form(ResourceContext<Loket> ctx) => FormSchema(
    columns: 2,
    components: [
      Section(
        title: 'Info Loket',
        columns: 2,
        children: [
          TextInput(name: 'kode', label: 'Kode', required: true),
          TextInput(name: 'nama', label: 'Nama', required: true),
          Select<String>(
            name: 'layananId',
            label: 'Layanan',
            required: true,
            options: layananCache.selectOptions(),
            columnSpan: 2,
          ),
          TextInput(name: 'petugas', label: 'Petugas'),
          Select<String>(
            name: 'status',
            label: 'Status',
            defaultValue: 'aktif',
            options: const [
              SelectOption('aktif', 'Aktif'),
              SelectOption('tutup', 'Tutup'),
              SelectOption('istirahat', 'Istirahat'),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  TableSchema<Loket> table() => TableSchema<Loket>(
    defaultSort: 'nama',
    columns: [
      TextColumn<Loket>(
        name: 'kode', label: 'Kode',
        accessor: (r) => r.kode,
        searchable: true, sortable: true,
      ),
      TextColumn<Loket>(
        name: 'nama', label: 'Nama',
        accessor: (r) => r.nama,
        searchable: true, sortable: true, bold: true,
      ),
      TextColumn<Loket>(
        name: 'layanan', label: 'Layanan',
        accessor: (r) => r.layanan.nama,
      ),
      TextColumn<Loket>(
        name: 'zona', label: 'Zona',
        accessor: (r) => r.zona.nama,
      ),
      TextColumn<Loket>(
        name: 'petugas', label: 'Petugas',
        accessor: (r) => r.petugas ?? '-',
      ),
      BadgeColumn<Loket>(
        name: 'status', label: 'Status',
        accessor: (r) {
          switch (r.status) {
            case StatusLoket.aktif: return 'Aktif';
            case StatusLoket.tutup: return 'Tutup';
            case StatusLoket.istirahat: return 'Istirahat';
          }
        },
        color: (r) {
          switch (r.status) {
            case StatusLoket.aktif: return const Color(0xFF10B981);
            case StatusLoket.tutup: return const Color(0xFFEF4444);
            case StatusLoket.istirahat: return const Color(0xFFF59E0B);
          }
        },
      ),
    ],
    rowActions: [
      RowAction.view<Loket>((ctx, row) async {}),
      RowAction.edit<Loket>((ctx, row) async {}),
      RowAction.delete<Loket>((ctx, row) async {
        await loketDataSource.delete(row.id);
      }),
    ],
  );
}
