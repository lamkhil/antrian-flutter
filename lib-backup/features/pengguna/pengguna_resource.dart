import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../data/models/pengguna.dart';
import '../../data/services/admin/admin_sdk.dart';
import '../../data/services/admin/admin_user_service.dart';
import '../../data/services/admin/service_account_storage.dart';
import '../../globals/widgets/app_dialog.dart';
import '../lokasi/lokasi_resource.dart';
import 'pengguna_admin_data_source.dart';
import 'widgets/reset_password_dialog.dart';
import 'widgets/service_account_setup_dialog.dart';

final penggunaDataSource = PenggunaAdminDataSource();

class PenggunaResource extends Resource<Pengguna> {
  @override String get slug => 'pengguna';
  @override String get label => 'Pengguna';
  @override String get pluralLabel => 'Pengguna';
  @override IconData get icon => Icons.people_outline;
  @override String? get navigationGroup => 'Akun';
  @override int get navigationSort => 10;

  @override
  DataSource<Pengguna> get dataSource => penggunaDataSource;

  @override String recordId(Pengguna r) => r.id;
  @override String recordTitle(Pengguna r) => r.nama;
  @override Map<String, dynamic> toFormData(Pengguna r) => r.toJson();

  @override
  FormSchema form(ResourceContext<Pengguna> ctx) => FormSchema(
    columns: 2,
    components: [
      Section(
        title: 'Data Pengguna',
        columns: 2,
        children: [
          TextInput(name: 'nama', label: 'Nama Lengkap', required: true),
          TextInput(
            name: 'email',
            label: 'Email',
            required: true,
            keyboardType: TextInputType.emailAddress,
          ),
          if (ctx.isCreate)
            TextInput(
              name: 'password',
              label: 'Password',
              required: true,
              obscure: true,
              helperText: 'Minimal 6 karakter. Admin bisa reset nanti '
                  'dari tombol "Reset Password" di list.',
            ),
          Select<String>(
            name: 'role',
            label: 'Role',
            required: true,
            defaultValue: 'operator',
            options: const [
              SelectOption('admin', 'Admin'),
              SelectOption('supervisor', 'Supervisor'),
              SelectOption('operator', 'Operator'),
            ],
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
          CheckboxList<String>(
            name: 'lokasiIds',
            label: 'Lokasi yang boleh diakses',
            helperText: 'Pilih satu atau lebih lokasi untuk user ini.',
            visibleWhen: (s) => s.get<String>('role') != 'admin',
            options: [
              for (final l in lokasiCache.items)
                CheckboxListOption(l.id, l.nama),
            ],
            columns: 2,
            columnSpan: 2,
          ),
        ],
      ),
    ],
  );

  @override
  TableSchema<Pengguna> table() => TableSchema<Pengguna>(
    defaultSort: 'nama',
    columns: [
      TextColumn<Pengguna>(
        name: 'nama', label: 'Nama',
        accessor: (r) => r.nama,
        searchable: true, sortable: true, bold: true,
      ),
      TextColumn<Pengguna>(
        name: 'email', label: 'Email',
        accessor: (r) => r.email,
        searchable: true,
      ),
      BadgeColumn<Pengguna>(
        name: 'role', label: 'Role',
        accessor: (r) {
          switch (r.role) {
            case RolePengguna.admin: return 'Admin';
            case RolePengguna.supervisor: return 'Supervisor';
            case RolePengguna.operator: return 'Operator';
          }
        },
        color: (r) {
          switch (r.role) {
            case RolePengguna.admin: return const Color(0xFFEF4444);
            case RolePengguna.supervisor: return const Color(0xFF3B82F6);
            case RolePengguna.operator: return const Color(0xFF6B7280);
          }
        },
      ),
      BadgeColumn<Pengguna>(
        name: 'status', label: 'Status',
        accessor: (r) =>
            r.status == StatusPengguna.aktif ? 'Aktif' : 'Non-aktif',
        color: (r) => r.status == StatusPengguna.aktif
            ? const Color(0xFF10B981)
            : const Color(0xFF6B7280),
      ),
    ],
    filters: [
      TableFilter(
        name: 'role', label: 'Role',
        options: const [
          TableFilterOption('admin', 'Admin'),
          TableFilterOption('supervisor', 'Supervisor'),
          TableFilterOption('operator', 'Operator'),
        ],
      ),
    ],
    rowActions: [
      RowAction.view<Pengguna>((ctx, row) async {}),
      RowAction.edit<Pengguna>((ctx, row) async {}),
      RowAction<Pengguna>(
        name: 'reset_password',
        label: 'Reset Password',
        icon: Icons.lock_reset_outlined,
        color: ActionColor.info,
        onPressed: (ctx, row) => _resetPasswordFlow(row),
      ),
      RowAction.delete<Pengguna>((ctx, row) => _deleteFlow(row)),
    ],
  );
}

Future<void> _resetPasswordFlow(Pengguna row) async {
  if (!await _ensureAdminSdkConfigured()) return;
  final newPassword = await ResetPasswordDialog.show(row);
  if (newPassword == null) return;
  await AppDialog.loading(message: 'Mereset password...');
  try {
    await AdminUserService.resetPassword(
      uid: row.id,
      newPassword: newPassword,
    );
    AppDialog.close();
    await AppDialog.basic(
      title: 'Berhasil',
      message: 'Password ${row.nama} sudah direset.',
      positiveText: 'Tutup',
    );
  } catch (e) {
    AppDialog.close();
    await AppDialog.error(message: e.toString());
  }
}

Future<void> _deleteFlow(Pengguna row) async {
  if (!await _ensureAdminSdkConfigured()) return;
  await AppDialog.loading(message: 'Menghapus user...');
  try {
    await penggunaDataSource.delete(row.id);
    AppDialog.close();
  } catch (e) {
    AppDialog.close();
    await AppDialog.error(message: e.toString());
  }
}

/// Pastikan service account sudah di-upload. Kalau belum, tawarkan
/// buka dialog setup. Return `true` kalau siap lanjut.
Future<bool> _ensureAdminSdkConfigured() async {
  if (await ServiceAccountStorage.isConfigured()) return true;
  final confirm = await AppDialog.warning(
    message: 'Service account Firebase Admin belum di-upload. '
        'Upload sekarang?',
    confirmText: 'Upload',
    cancelText: 'Batal',
  );
  if (confirm != true) return false;
  final saved = await ServiceAccountSetupDialog.show();
  if (saved == true) {
    AdminSdk.reset();
    return true;
  }
  return false;
}
