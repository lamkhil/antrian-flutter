import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../../data/firestore_data_source.dart';
import '../../../../../models/app_user.dart';
import '../../../../../models/counter.dart';

/// Users currently assigned to this counter (via `users.counterId`).
class CounterUsersRelationManager
    extends RelationManager<Counter, AppUser> {
  @override
  String get title => 'Pengguna';

  @override
  IconData? get icon => Icons.people_outline;

  @override
  String get description =>
      'Daftar pengguna yang ditugaskan ke loket ini.';

  @override
  String childId(AppUser record) => record.id;

  @override
  DataSource<AppUser> dataSource(Counter parent) => FirestoreDataSource<AppUser>(
        collection: FirebaseFirestore.instance.collection('users'),
        fromMap: AppUser.fromMap,
        toMap: (u) => u.toMap(),
        idOf: (u) => u.id,
        whereEquals: {'counterId': parent.id},
      );

  @override
  TableSchema<AppUser> table(Counter parent) => TableSchema<AppUser>(
        defaultSort: 'name',
        searchable: false,
        paginated: false,
        emptyTitle: 'Belum ada pengguna',
        emptyDescription:
            'Tidak ada pengguna yang memilih loket ini saat login.',
        columns: [
          TextColumn<AppUser>(
            name: 'name',
            label: 'Nama',
            accessor: (u) => u.name,
            bold: true,
          ),
          TextColumn<AppUser>(
            name: 'email',
            label: 'Email',
            accessor: (u) => u.email,
          ),
          BadgeColumn<AppUser>(
            name: 'role',
            label: 'Peran',
            accessor: (u) => u.role.label,
            color: (u) =>
                u.role == UserRole.admin ? Colors.indigo : Colors.teal,
          ),
          BooleanColumn<AppUser>(
            name: 'paused',
            label: 'Istirahat',
            accessor: (u) => u.paused,
          ),
        ],
      );
}
