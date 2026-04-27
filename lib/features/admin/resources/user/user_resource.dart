import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../../../data/admin_user_service.dart';
import '../../../../data/firestore_data_source.dart';
import '../../../../data/lookup_cache.dart';
import '../../../../models/app_user.dart';
import 'pages/create_user.dart';
import 'pages/edit_user.dart';
import 'pages/list_users.dart';
import 'pages/view_user.dart';

final _adminUserService = AdminUserService();

final userDataSource = FirestoreDataSource<AppUser>(
  collection: FirebaseFirestore.instance.collection('users'),
  fromMap: AppUser.fromMap,
  toMap: (u) => u.toMap(),
  idOf: (u) => u.id,
  searchMatcher: (u, q) =>
      u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q),
  createOverride: (data) async {
    final email = (data['email'] as String?)?.trim() ?? '';
    final password = (data['password'] as String?) ?? '';
    final name = (data['name'] as String?)?.trim() ?? '';
    final role = UserRole.fromName(data['role']?.toString());
    if (email.isEmpty || password.isEmpty) {
      throw StateError('Email dan password wajib diisi');
    }
    return _adminUserService.createUser(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  },
  deleteHook: (id) => _adminUserService.deleteUserProfile(id),
);

class UserResource extends Resource<AppUser> {
  @override
  String get slug => 'users';
  @override
  String get label => 'Pengguna';
  @override
  String get pluralLabel => 'Pengguna';
  @override
  IconData get icon => Icons.people_outline;
  @override
  String? get navigationGroup => 'Manajemen Akses';
  @override
  int get navigationSort => 10;

  @override
  DataSource<AppUser> get dataSource => userDataSource;

  @override
  String recordId(AppUser r) => r.id;
  @override
  String recordTitle(AppUser r) => r.name.isEmpty ? r.email : r.name;
  @override
  Map<String, dynamic> toFormData(AppUser r) => {
        'email': r.email,
        'name': r.name,
        'role': r.role.name,
      };

  @override
  FormSchema form(ResourceContext<AppUser> ctx) {
    final isCreate = ctx.operation == ResourceOperation.create;
    return FormSchema(
      columns: 2,
      components: [
        TextInput(
          name: 'name',
          label: 'Nama',
          required: true,
          columnSpan: 2,
        ),
        TextInput(
          name: 'email',
          label: 'Email',
          required: true,
          disabled: !isCreate,
          helperText: isCreate ? null : 'Email tidak bisa diubah.',
        ),
        Select<String>(
          name: 'role',
          label: 'Peran',
          required: true,
          defaultValue: UserRole.counter.name,
          options: UserRole.values
              .map((r) => SelectOption<String>(r.name, r.label))
              .toList(),
        ),
        if (isCreate)
          TextInput(
            name: 'password',
            label: 'Password',
            required: true,
            obscure: true,
            columnSpan: 2,
            helperText: 'Minimal 6 karakter.',
          ),
      ],
    );
  }

  @override
  Map<String, ResourcePage<AppUser>> pages() => {
        'index': ListUsers.route(),
        'create': CreateUser.route(),
        'view': ViewUser.route(),
        'edit': EditUser.route(),
      };

  @override
  TableSchema<AppUser> table() => TableSchema<AppUser>(
        defaultSort: 'name',
        columns: [
          TextColumn<AppUser>(
            name: 'name',
            label: 'Nama',
            accessor: (r) => r.name,
            searchable: true,
            sortable: true,
            bold: true,
          ),
          TextColumn<AppUser>(
            name: 'email',
            label: 'Email',
            accessor: (r) => r.email,
            searchable: true,
          ),
          BadgeColumn<AppUser>(
            name: 'role',
            label: 'Peran',
            accessor: (r) => r.role.label,
            color: (r) => r.role == UserRole.admin
                ? Colors.indigo
                : Colors.teal,
          ),
          TextColumn<AppUser>(
            name: 'counterId',
            label: 'Loket',
            accessor: (r) => r.role == UserRole.counter
                ? LookupCache.instance.counterName(r.counterId)
                : '-',
          ),
        ],
        rowActions: [
          RowAction.delete<AppUser>((ctx, row) async {
            await userDataSource.delete(row.id);
          }),
        ],
      );
}
