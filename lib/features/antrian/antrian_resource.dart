import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import '../../data/models/antrian.dart';
import '../../data/services/firestore_data_source.dart';

final antrianDataSource = FirestoreDataSource<Antrian>(
  collectionPath: 'antrians',
  fromJson: Antrian.fromJson,
  toJson: (r) => r.toJson(),
  idOf: (r) => r.id,
);

class AntrianResource extends Resource<Antrian> {
  @override String get slug => 'antrian';
  @override String get label => 'Antrian';
  @override String get pluralLabel => 'Antrian';
  @override IconData get icon => Icons.confirmation_number_outlined;
  @override String? get navigationGroup => 'Transaksi';
  @override int get navigationSort => 10;

  @override
  DataSource<Antrian> get dataSource => antrianDataSource;

  @override String recordId(Antrian r) => r.id;
  @override String recordTitle(Antrian r) =>
      'Tiket ${r.nomorAntrian} — ${r.nama}';

  @override
  Map<String, dynamic> toFormData(Antrian r) => r.toJson();

  // Antrian dibuat oleh kiosk, bukan panel admin. Default pages: list + view.
  @override
  List<ResourcePageDef> pages() => [
        ResourcePageDef.list(),
        ResourcePageDef.view(),
      ];

  @override
  FormSchema form(ResourceContext<Antrian> ctx) => FormSchema(
    components: [
      TextInput(name: 'nomorAntrian', label: 'Nomor', disabled: true),
      TextInput(name: 'nama', label: 'Nama', disabled: true),
    ],
  );

  @override
  TableSchema<Antrian> table() => TableSchema<Antrian>(
    defaultSort: 'waktuDaftar',
    defaultSortDesc: true,
    columns: [
      TextColumn<Antrian>(
        name: 'nomorAntrian', label: 'No.',
        accessor: (r) => r.nomorAntrian,
        searchable: true, bold: true,
      ),
      TextColumn<Antrian>(
        name: 'nama', label: 'Nama',
        accessor: (r) => r.nama,
        searchable: true,
      ),
      TextColumn<Antrian>(
        name: 'layanan', label: 'Layanan',
        accessor: (r) => r.layanan.nama,
      ),
      TextColumn<Antrian>(
        name: 'loket', label: 'Loket',
        accessor: (r) => r.loket?.nama ?? '-',
      ),
      DateColumn<Antrian>(
        name: 'waktuDaftar', label: 'Daftar',
        accessor: (r) => r.waktuDaftar,
        pattern: 'dd MMM HH:mm',
        sortable: true,
      ),
      BadgeColumn<Antrian>(
        name: 'status', label: 'Status',
        accessor: (r) => r.status.name,
        formatter: (r) {
          switch (r.status) {
            case StatusAntrian.menunggu: return 'Menunggu';
            case StatusAntrian.dipanggil: return 'Dipanggil';
            case StatusAntrian.dilayani: return 'Dilayani';
            case StatusAntrian.dilewati: return 'Dilewati';
            case StatusAntrian.selesai: return 'Selesai';
          }
        },
        color: (r) => r.status.dotColor,
      ),
    ],
    filters: [
      TableFilter(
        name: 'status',
        label: 'Status',
        options: const [
          TableFilterOption('menunggu', 'Menunggu'),
          TableFilterOption('dipanggil', 'Dipanggil'),
          TableFilterOption('dilayani', 'Dilayani'),
          TableFilterOption('dilewati', 'Dilewati'),
          TableFilterOption('selesai', 'Selesai'),
        ],
      ),
    ],
    rowActions: [
      RowAction.view<Antrian>((ctx, row) async {}),
      RowAction.delete<Antrian>((ctx, row) async {
        await antrianDataSource.delete(row.id);
      }),
    ],
  );
}
