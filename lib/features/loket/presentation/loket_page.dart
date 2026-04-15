import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/loket.dart';
import 'package:antrian/extension/size.dart';
import 'package:antrian/features/layanan/application/layanan_controller.dart';
import 'package:antrian/features/loket/application/loket_controller.dart';
import 'package:antrian/globals/providers/lokasi/lokasi_provider.dart';
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

class LoketPage extends ConsumerStatefulWidget {
  const LoketPage({super.key});

  @override
  ConsumerState<LoketPage> createState() => _LoketPageState();
}

class _LoketPageState extends ConsumerState<LoketPage> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    ref.listenManual(lokasiControllerProvider, (p, n) {
      if (n.aktif != null && p?.aktif != n.aktif) {
        ref.read(loketControllerProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loketList = ref.watch(loketControllerProvider).loket;
    final filtered = loketList.where((l) {
      final q = _query.toLowerCase();
      return l.nama.toLowerCase().contains(q) ||
          l.kode.toLowerCase().contains(q) ||
          l.layanan.nama.toLowerCase().contains(q) ||
          (l.petugas ?? '').toLowerCase().contains(q);
    }).toList();

    return AppLayout(
      title: 'Loket',
      breadcrumbs: const ['Loket', 'List'],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppListToolbar(
                searchHint: 'Cari loket...',
                addLabel: 'Tambah Loket',
                onSearch: (v) => setState(() => _query = v),
                onAdd: () => _showFormDialog(context, null),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  if (constraints.maxWidth >= 640) {
                    return _LoketTable(
                      items: filtered,
                      onEdit: (l) => _showFormDialog(context, l),
                      onDelete: (l) => _showDeleteDialog(context, l),
                    );
                  }
                  return _LoketMobileList(
                    items: filtered,
                    onEdit: (l) => _showFormDialog(context, l),
                    onDelete: (l) => _showDeleteDialog(context, l),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, Loket? loket) {
    showDialog(
      context: context,
      builder: (_) => _LoketFormDialog(loket: loket),
    );
  }

  void _showDeleteDialog(BuildContext context, Loket loket) {
    showDialog(
      context: context,
      builder: (_) => _LoketDeleteDialog(loket: loket),
    );
  }
}

// ── Tabel (desktop) ───────────────────────────────────────

class _LoketTable extends StatelessWidget {
  final List<Loket> items;
  final ValueChanged<Loket> onEdit;
  final ValueChanged<Loket> onDelete;

  const _LoketTable({
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
            ? const AppEmptyState(message: 'Tidak ada loket ditemukan')
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
                  DataColumn(label: Text('KODE')),
                  DataColumn(label: Text('NAMA LOKET')),
                  DataColumn(label: Text('LAYANAN')),
                  DataColumn(label: Text('ZONA')),
                  DataColumn(label: Text('PETUGAS')),
                  DataColumn(label: Text('STATUS')),
                ],
                rows: items
                    .map(
                      (l) => DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                AppActionButton(
                                  icon: Icons.edit_outlined,
                                  onTap: () => onEdit(l),
                                ),
                                const SizedBox(width: 6),
                                AppActionButton(
                                  icon: Icons.delete_outline_rounded,
                                  isDestructive: true,
                                  onTap: () => onDelete(l),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              l.kode,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              l.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              l.layanan.nama,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                          DataCell(
                            Text(
                              l.zona.nama,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                          DataCell(
                            Text(
                              (l.petugas == null || l.petugas!.isEmpty)
                                  ? '—'
                                  : l.petugas!,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                          DataCell(
                            StatusBadge(
                              label: l.status.label,
                              bg: l.status.badgeBg,
                              fg: l.status.badgeColor,
                              dot: l.status.dotColor,
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

class _LoketMobileList extends StatelessWidget {
  final List<Loket> items;
  final ValueChanged<Loket> onEdit;
  final ValueChanged<Loket> onDelete;

  const _LoketMobileList({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppEmptyState(message: 'Tidak ada loket ditemukan');
    }
    return Column(
      children: items
          .map(
            (l) => _LoketMobileCard(
              loket: l,
              onEdit: () => onEdit(l),
              onDelete: () => onDelete(l),
            ),
          )
          .toList(),
    );
  }
}

class _LoketMobileCard extends StatelessWidget {
  final Loket loket;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LoketMobileCard({
    required this.loket,
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
                      loket.nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loket.kode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: loket.status.label,
                bg: loket.status.badgeBg,
                fg: loket.status.badgeColor,
                dot: loket.status.dotColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AppMobileField(label: 'Layanan', value: loket.layanan.nama),
              const SizedBox(width: 16),
              AppMobileField(
                label: 'Petugas',
                value: (loket.petugas == null || loket.petugas!.isEmpty)
                    ? '—'
                    : loket.petugas!,
              ),
            ],
          ),
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

class _LoketFormDialog extends ConsumerStatefulWidget {
  final Loket? loket;

  const _LoketFormDialog({this.loket});

  @override
  ConsumerState<_LoketFormDialog> createState() => _LoketFormDialogState();
}

class _LoketFormDialogState extends ConsumerState<_LoketFormDialog> {
  late final TextEditingController _kode;
  late final TextEditingController _nama;
  late final TextEditingController _petugas;
  Layanan? _layanan;
  StatusLoket _status = StatusLoket.aktif;

  @override
  void initState() {
    super.initState();
    final l = widget.loket;
    _kode = TextEditingController(text: l?.kode ?? '');
    _nama = TextEditingController(text: l?.nama ?? '');
    _petugas = TextEditingController(text: l?.petugas ?? '');
    _status = l?.status ?? StatusLoket.aktif;
    _layanan = l?.layanan;
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _petugas.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_kode.text.trim().isEmpty ||
        _nama.text.trim().isEmpty ||
        _layanan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode, nama, dan layanan wajib diisi.')),
      );
      return;
    }
    final isEdit = widget.loket != null;
    final notifier = ref.read(loketControllerProvider.notifier);
    if (isEdit) {
      await notifier.edit(
        widget.loket!.copyWith(
          kode: _kode.text.trim(),
          nama: _nama.text.trim(),
          petugas: _petugas.text.trim().isEmpty ? null : _petugas.text.trim(),
          status: _status,
          layanan: _layanan,
          layananId: _layanan!.id,
          zona: _layanan!.zona,
          zonaId: _layanan!.zonaId,
          lokasi: _layanan!.lokasi,
          lokasiId: _layanan!.lokasiId,
        ),
      );
    } else {
      await notifier.tambah(
        layanan: _layanan!,
        kode: _kode.text.trim(),
        nama: _nama.text.trim(),
        petugas: _petugas.text.trim().isEmpty ? null : _petugas.text.trim(),
        status: _status,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.loket != null;
    final layananList = ref.watch(layananControllerProvider).layanan;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Text(
                    isEdit ? 'Edit Loket' : 'Tambah Loket',
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
                  Row(
                    children: [
                      Expanded(
                        child: AppFormField(
                          label: 'Kode Loket',
                          controller: _kode,
                          hint: 'cth. LKT-01',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppDropdownField<StatusLoket>(
                          label: 'Status',
                          value: _status,
                          items: StatusLoket.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.label),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _status = v ?? StatusLoket.aktif),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppFormField(
                    label: 'Nama Loket',
                    controller: _nama,
                    hint: 'cth. Loket A',
                  ),
                  const SizedBox(height: 12),
                  AppDropdownField<Layanan>(
                    label: 'Layanan',
                    value: _layanan,
                    hint: 'Pilih layanan...',
                    items: layananList
                        .map(
                          (l) => DropdownMenuItem(
                            value: l,
                            child: Text(
                              '${l.nama} — ${l.zona.nama}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _layanan = v),
                  ),
                  const SizedBox(height: 12),
                  AppFormField(
                    label: 'Nama Petugas (opsional)',
                    controller: _petugas,
                    hint: 'cth. Budi Santoso',
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

class _LoketDeleteDialog extends ConsumerWidget {
  final Loket loket;

  const _LoketDeleteDialog({required this.loket});

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
                    'Hapus loket ini?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${loket.nama}" akan dihapus secara permanen.',
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
                          .read(loketControllerProvider.notifier)
                          .hapus(loket.id);
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
