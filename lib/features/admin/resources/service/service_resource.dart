import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../data/firestore_data_source.dart';
import '../../../../data/lookup_cache.dart';
import '../../../../models/service.dart';
import 'pages/create_service.dart';
import 'pages/edit_service.dart';
import 'pages/list_services.dart';
import 'pages/view_service.dart';
import 'relations/counters_relation_manager.dart';

final serviceDataSource = FirestoreDataSource<Service>(
  collection: FirebaseFirestore.instance.collection('services'),
  fromMap: Service.fromMap,
  toMap: (s) => s.toMap(),
  idOf: (s) => s.id,
);

class ServiceResource extends Resource<Service> {
  @override
  String get slug => 'services';
  @override
  String get label => 'Layanan';
  @override
  String get pluralLabel => 'Layanan';
  @override
  IconData get icon => Icons.support_agent_outlined;
  @override
  String? get navigationGroup => 'Master Data';
  @override
  int get navigationSort => 20;

  @override
  DataSource<Service> get dataSource => serviceDataSource;

  @override
  String recordId(Service r) => r.id;
  @override
  String recordTitle(Service r) => r.name;
  @override
  Map<String, dynamic> toFormData(Service r) => r.toMap();

  @override
  FormSchema form(ResourceContext<Service> ctx) {
    final zones = LookupCache.instance.zones;
    return FormSchema(
      columns: 2,
      components: [
        TextInput(
          name: 'name',
          label: 'Nama Layanan',
          required: true,
          columnSpan: 2,
        ),
        TextInput(name: 'code', label: 'Kode'),
        Select<String>(
          name: 'zoneId',
          label: 'Zona',
          required: true,
          options: zones
              .map((z) => SelectOption<String>(z.id, z.name))
              .toList(),
        ),
      ],
    );
  }

  @override
  Map<String, ResourcePage<Service>> pages() => {
        'index': ListServices.route(),
        'create': CreateService.route(),
        'view': ViewService.route(),
        'edit': EditService.route(),
      };

  @override
  List<RelationManager> relations() => [
        ServiceCountersRelationManager(),
      ];

  @override
  TableSchema<Service> table() => TableSchema<Service>(
        defaultSort: 'name',
        columns: [
          TextColumn<Service>(
            name: 'name',
            label: 'Nama',
            accessor: (r) => r.name,
            searchable: true,
            sortable: true,
            bold: true,
          ),
          TextColumn<Service>(
            name: 'code',
            label: 'Kode',
            accessor: (r) => r.code ?? '-',
          ),
          TextColumn<Service>(
            name: 'zoneId',
            label: 'Zona',
            accessor: (r) => LookupCache.instance.zoneName(r.zoneId),
          ),
        ],
        rowActions: [
          RowAction.delete<Service>((ctx, row) async {
            await serviceDataSource.delete(row.id);
          }),
        ],
      );
}
