import 'package:antrian/data/models/pengguna.dart';
import 'package:antrian/extension/size.dart';
import 'package:antrian/features/pengguna/application/pengguna_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../globals/widgets/app_action_button.dart';
import '../../../globals/widgets/app_dropdown_field.dart';
import '../../../globals/widgets/app_empty_state.dart';
import '../../../globals/widgets/app_form_field.dart';
import '../../../globals/widgets/app_layout.dart';
import '../../../globals/widgets/app_list_toolbar.dart';
import '../../../globals/widgets/app_mobile_field.dart';
import '../../../globals/widgets/status_badge.dart';

class PenggunaPage extends ConsumerStatefulWidget {
  const PenggunaPage({super.key});

  @override
  ConsumerState<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends ConsumerState<PenggunaPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(penggunaControllerProvider).pengguna;
    final filtered = list.where((p) {
      final q = _query.toLowerCase();
      return p.nama.toLowerCase().contains(q) ||
          p.email.toLowerCase().contains(q);
    }).toList();

    return AppLayout(
      title: 'Pengguna',
      breadcrumbs: const ['Pengguna', 'List'],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppListToolbar(
                searchHint: 'Cari pengguna...',
                addLabel: 'Tambah Pengguna',
                onSearch: (v) => setState(() => _query = v),
                onAdd: () => _showFormDialog(context, null),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  if (constraints.maxWidth >= 640) {
                    return _PenggunaTable(
                      items: filtered,
                      onEdit: (p) => _showFormDialog(context, p),
                      onDelete: (p) => _showDeleteDialog(context, p),
                    );
                  }
                  return _PenggunaMobileList(
                    items: filtered,
                    onEdit: (p) => _showFormDialog(context, p),
                    onDelete: (p) => _showDeleteDialog(context, p),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, Pengguna? pengguna) {
    showDialog(
      context: context,
      builder: (_) => _PenggunaFormDialog(pengguna: pengguna),
    );
  }

  void _showDeleteDialog(BuildContext context, Pengguna pengguna) {
    showDialog(
      context: context,
      builder: (_) => _PenggunaDeleteDialog(pengguna: pengguna),
    );
  }
}

// ── Tabel (desktop) ───────────────────────────────────────

class _PenggunaTable extends StatelessWidget {
  final List<Pengguna> items;
  final ValueChanged<Pengguna> onEdit;
  final ValueChanged<Pengguna> onDelete;

  const _PenggunaTable({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: items.isEmpty
            ? const AppEmptyState(message: 'Tidak ada pengguna ditemukan')
            : DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF9FAFB),
                ),
                headingTextStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.4,
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF111827),
                ),
                columnSpacing: 20,
                horizontalMargin: 16,
                dividerThickness: 0.5,
                columns: const [
                  DataColumn(label: Text('AKSI')),
                  DataColumn(label: Text('NAMA')),
                  DataColumn(label: Text('EMAIL')),
                  DataColumn(label: Text('ROLE')),
                  DataColumn(label: Text('STATUS')),
                ],
                rows: items
                    .map(
                      (p) => DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                AppActionButton(
                                  icon: Icons.edit_outlined,
                                  onTap: () => onEdit(p),
                                ),
                                const SizedBox(width: 6),
                                AppActionButton(
                                  icon: Icons.delete_outline_rounded,
                                  isDestructive: true,
                                  onTap: () => onDelete(p),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              p.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              p.email,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                          DataCell(
                            Text(
                              p.role.label,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                          DataCell(
                            StatusBadge(
                              label: p.status.label,
                              bg: p.status.badgeBg,
                              fg: p.status.badgeColor,
                              dot: p.status.dotColor,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

// ── Card list (mobile) ────────────────────────────────────

class _PenggunaMobileList extends StatelessWidget {
  final List<Pengguna> items;
  final ValueChanged<Pengguna> onEdit;
  final ValueChanged<Pengguna> onDelete;

  const _PenggunaMobileList({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppEmptyState(message: 'Tidak ada pengguna ditemukan');
    }
    return Column(
      children: items
          .map(
            (p) => _PenggunaMobileCard(
              pengguna: p,
              onEdit: () => onEdit(p),
              onDelete: () => onDelete(p),
            ),
          )
          .toList(),
    );
  }
}

class _PenggunaMobileCard extends StatelessWidget {
  final Pengguna pengguna;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PenggunaMobileCard({
    required this.pengguna,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pengguna.nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pengguna.email,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: pengguna.status.label,
                bg: pengguna.status.badgeBg,
                fg: pengguna.status.badgeColor,
                dot: pengguna.status.dotColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppMobileField(label: 'Role', value: pengguna.role.label),
          const SizedBox(height: 12),
          const Divider(height: 0.5, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 12),
                label: const Text('Edit', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF374151),
                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 12),
                label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  backgroundColor: const Color(0xFFFEE2E2),
                  side: const BorderSide(color: Color(0xFFFCA5A5), width: 0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Form dialog ───────────────────────────────────────────

class _PenggunaFormDialog extends ConsumerStatefulWidget {
  final Pengguna? pengguna;

  const _PenggunaFormDialog({this.pengguna});

  @override
  ConsumerState<_PenggunaFormDialog> createState() =>
      _PenggunaFormDialogState();
}

class _PenggunaFormDialogState extends ConsumerState<_PenggunaFormDialog> {
  late final TextEditingController _nama;
  late final TextEditingController _email;
  RolePengguna _role = RolePengguna.operator;
  StatusPengguna _status = StatusPengguna.aktif;

  @override
  void initState() {
    super.initState();
    final p = widget.pengguna;
    _nama = TextEditingController(text: p?.nama ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _role = p?.role ?? RolePengguna.operator;
    _status = p?.status ?? StatusPengguna.aktif;
  }

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_nama.text.trim().isEmpty || _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan email wajib diisi.')),
      );
      return;
    }
    final notifier = ref.read(penggunaControllerProvider.notifier);
    if (widget.pengguna == null) {
      await notifier.tambah(
        nama: _nama.text.trim(),
        email: _email.text.trim(),
        role: _role,
        status: _status,
      );
    } else {
      await notifier.edit(
        widget.pengguna!.copyWith(
          nama: _nama.text.trim(),
          email: _email.text.trim(),
          role: _role,
          status: _status,
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.pengguna != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Text(
                    isEdit ? 'Edit Pengguna' : 'Tambah Pengguna',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  AppFormField(
                    label: 'Nama',
                    controller: _nama,
                    hint: 'cth. Budi Santoso',
                  ),
                  const SizedBox(height: 12),
                  AppFormField(
                    label: 'Email',
                    controller: _email,
                    hint: 'cth. budi@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdownField<RolePengguna>(
                          label: 'Role',
                          value: _role,
                          items: RolePengguna.values
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r.label),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(
                            () => _role = v ?? RolePengguna.operator,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppDropdownField<StatusPengguna>(
                          label: 'Status',
                          value: _status,
                          items: StatusPengguna.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.label),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(
                            () => _status = v ?? StatusPengguna.aktif,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 0.5,
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Delete dialog ─────────────────────────────────────────

class _PenggunaDeleteDialog extends ConsumerWidget {
  final Pengguna pengguna;

  const _PenggunaDeleteDialog({required this.pengguna});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hapus pengguna ini?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${pengguna.nama}" akan dihapus secara permanen.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 0.5,
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(penggunaControllerProvider.notifier)
                          .hapus(pengguna.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Ya, hapus'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
