import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../data/firestore_data_source.dart';
import '../../../../../models/service.dart';
import '../../../../../models/zone.dart';

/// Services that belong to this zone (via `services.zoneId`).
class ZoneServicesRelationManager extends RelationManager<Zone, Service> {
  @override
  String get title => 'Layanan';

  @override
  IconData? get icon => Icons.support_agent_outlined;

  @override
  String get description => 'Daftar layanan yang berada di zona ini.';

  @override
  String childId(Service record) => record.id;

  @override
  DataSource<Service> dataSource(Zone parent) => FirestoreDataSource<Service>(
        collection: FirebaseFirestore.instance.collection('services'),
        fromMap: Service.fromMap,
        toMap: (s) => s.toMap(),
        idOf: (s) => s.id,
        whereEquals: {'zoneId': parent.id},
      );

  @override
  TableSchema<Service> table(Zone parent) => TableSchema<Service>(
        defaultSort: 'name',
        searchable: false,
        paginated: false,
        emptyTitle: 'Belum ada layanan',
        emptyDescription:
            'Tambahkan layanan baru lewat menu Layanan dan pilih zona ini.',
        columns: [
          TextColumn<Service>(
            name: 'name',
            label: 'Nama',
            accessor: (s) => s.name,
            bold: true,
          ),
          TextColumn<Service>(
            name: 'code',
            label: 'Kode',
            accessor: (s) => s.code ?? '-',
          ),
        ],
      );
}
