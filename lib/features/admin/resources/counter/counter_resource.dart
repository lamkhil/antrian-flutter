import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../data/firestore_data_source.dart';
import '../../../../data/lookup_cache.dart';
import '../../../../models/counter.dart';
import 'pages/create_counter.dart';
import 'pages/edit_counter.dart';
import 'pages/list_counters.dart';
import 'pages/view_counter.dart';
import 'relations/users_relation_manager.dart';

final counterDataSource = FirestoreDataSource<Counter>(
  collection: FirebaseFirestore.instance.collection('counters'),
  fromMap: Counter.fromMap,
  toMap: (c) => c.toMap(),
  idOf: (c) => c.id,
);

class CounterResource extends Resource<Counter> {
  @override
  String get slug => 'counters';
  @override
  String get label => 'Loket';
  @override
  String get pluralLabel => 'Loket';
  @override
  IconData get icon => Icons.point_of_sale_outlined;
  @override
  String? get navigationGroup => 'Master Data';
  @override
  int get navigationSort => 10;

  @override
  DataSource<Counter> get dataSource => counterDataSource;

  @override
  String recordId(Counter r) => r.id;
  @override
  String recordTitle(Counter r) => r.name;
  @override
  Map<String, dynamic> toFormData(Counter r) => r.toMap();

  @override
  FormSchema form(ResourceContext<Counter> ctx) {
    final services = LookupCache.instance.services;
    return FormSchema(
      columns: 1,
      components: [
        TextInput(name: 'name', label: 'Nama Loket', required: true),
        CheckboxList<String>(
          name: 'serviceIds',
          label: 'Layanan',
          columns: 2,
          options: services
              .map((s) => CheckboxListOption<String>(s.id, s.name))
              .toList(),
          helperText: 'Loket dapat melayani lebih dari satu layanan.',
        ),
      ],
    );
  }

  @override
  Map<String, ResourcePage<Counter>> pages() => {
        'index': ListCounters.route(),
        'create': CreateCounter.route(),
        'view': ViewCounter.route(),
        'edit': EditCounter.route(),
      };

  @override
  List<RelationManager> relations() => [
        CounterUsersRelationManager(),
      ];

  @override
  TableSchema<Counter> table() => TableSchema<Counter>(
        defaultSort: 'name',
        columns: [
          TextColumn<Counter>(
            name: 'name',
            label: 'Nama',
            accessor: (r) => r.name,
            searchable: true,
            sortable: true,
            bold: true,
          ),
          TextColumn<Counter>(
            name: 'serviceIds',
            label: 'Layanan',
            accessor: (r) => r.serviceIds.isEmpty
                ? '-'
                : r.serviceIds
                    .map(LookupCache.instance.serviceName)
                    .join(', '),
          ),
        ],
        rowActions: [
          RowAction.delete<Counter>((ctx, row) async {
            await counterDataSource.delete(row.id);
          }),
        ],
      );
}
