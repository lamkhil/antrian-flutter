import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../data/firestore_data_source.dart';
import '../../../../models/zone.dart';
import 'pages/create_zone.dart';
import 'pages/edit_zone.dart';
import 'pages/list_zones.dart';
import 'pages/view_zone.dart';
import 'relations/services_relation_manager.dart';

final zoneDataSource = FirestoreDataSource<Zone>(
  collection: FirebaseFirestore.instance.collection('zones'),
  fromMap: Zone.fromMap,
  toMap: (z) => z.toMap(),
  idOf: (z) => z.id,
);

class ZoneResource extends Resource<Zone> {
  @override
  String get slug => 'zones';
  @override
  String get label => 'Zona';
  @override
  String get pluralLabel => 'Zona';
  @override
  IconData get icon => Icons.map_outlined;
  @override
  String? get navigationGroup => 'Master Data';
  @override
  int get navigationSort => 30;

  @override
  DataSource<Zone> get dataSource => zoneDataSource;

  @override
  String recordId(Zone r) => r.id;
  @override
  String recordTitle(Zone r) => r.name;
  @override
  Map<String, dynamic> toFormData(Zone r) => r.toMap();

  @override
  FormSchema form(ResourceContext<Zone> ctx) => FormSchema(
        columns: 1,
        components: [
          TextInput(name: 'name', label: 'Nama Zona', required: true),
          Textarea(name: 'description', label: 'Deskripsi', rows: 3),
        ],
      );

  @override
  Map<String, ResourcePage<Zone>> pages() => {
        'index': ListZones.route(),
        'create': CreateZone.route(),
        'view': ViewZone.route(),
        'edit': EditZone.route(),
      };

  @override
  List<RelationManager> relations() => [
        ZoneServicesRelationManager(),
      ];

  @override
  TableSchema<Zone> table() => TableSchema<Zone>(
        defaultSort: 'name',
        columns: [
          TextColumn<Zone>(
            name: 'name',
            label: 'Nama',
            accessor: (r) => r.name,
            searchable: true,
            sortable: true,
            bold: true,
          ),
          TextColumn<Zone>(
            name: 'description',
            label: 'Deskripsi',
            accessor: (r) => r.description ?? '-',
          ),
        ],
        rowActions: [
          RowAction.delete<Zone>((ctx, row) async {
            await zoneDataSource.delete(row.id);
          }),
        ],
      );
}
