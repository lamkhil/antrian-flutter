import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../data/firestore_data_source.dart';
import '../../../../models/kiosk.dart';
import 'pages/create_kiosk.dart';
import 'pages/edit_kiosk.dart';
import 'pages/list_kiosks.dart';
import 'pages/view_kiosk.dart';

final kioskDataSource = FirestoreDataSource<Kiosk>(
  collection: FirebaseFirestore.instance.collection('kiosks'),
  fromMap: Kiosk.fromMap,
  toMap: (k) => k.toMap(),
  idOf: (k) => k.id,
);

class KioskResource extends Resource<Kiosk> {
  @override
  String get slug => 'kiosks';
  @override
  String get label => 'Kios';
  @override
  String get pluralLabel => 'Kios';
  @override
  IconData get icon => Icons.print_outlined;
  @override
  String? get navigationGroup => 'Perangkat';
  @override
  int get navigationSort => 10;

  @override
  DataSource<Kiosk> get dataSource => kioskDataSource;

  @override
  String recordId(Kiosk r) => r.id;
  @override
  String recordTitle(Kiosk r) => r.name;
  @override
  Map<String, dynamic> toFormData(Kiosk r) => r.toMap();

  @override
  FormSchema form(ResourceContext<Kiosk> ctx) => FormSchema(
        columns: 2,
        components: [
          TextInput(
            name: 'name',
            label: 'Nama Kios',
            required: true,
            columnSpan: 2,
          ),
          TextInput(
            name: 'deviceId',
            label: 'Device ID',
            required: true,
            helperText: 'Diisi otomatis oleh perangkat kios saat pertama kali dibuka.',
          ),
          Toggle(name: 'active', label: 'Aktif', defaultValue: true),
        ],
      );

  @override
  Map<String, ResourcePage<Kiosk>> pages() => {
        'index': ListKiosks.route(),
        'create': CreateKiosk.route(),
        'view': ViewKiosk.route(),
        'edit': EditKiosk.route(),
      };

  @override
  TableSchema<Kiosk> table() => TableSchema<Kiosk>(
        defaultSort: 'name',
        columns: [
          TextColumn<Kiosk>(
            name: 'name',
            label: 'Nama',
            accessor: (r) => r.name,
            searchable: true,
            sortable: true,
            bold: true,
          ),
          TextColumn<Kiosk>(
            name: 'deviceId',
            label: 'Device ID',
            accessor: (r) => r.deviceId,
            searchable: true,
          ),
          BooleanColumn<Kiosk>(
            name: 'active',
            label: 'Aktif',
            accessor: (r) => r.active,
          ),
        ],
        rowActions: [
          RowAction.delete<Kiosk>((ctx, row) async {
            await kioskDataSource.delete(row.id);
          }),
        ],
      );
}
