import 'dart:async';

import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/extension/size.dart';
import 'package:antrian/features/zona/application/zona_controller.dart';
import 'package:antrian/globals/providers/lokasi/lokasi_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/zona.dart';
import '../../../globals/widgets/app_layout.dart';

class ZonaPage extends ConsumerStatefulWidget {
  const ZonaPage({super.key});

  @override
  ConsumerState<ZonaPage> createState() => _ZonaPageState();
}

class _ZonaPageState extends ConsumerState<ZonaPage> {
  String _query = '';

  StreamSubscription? _lokasiSub;

  @override
  void initState() {
    ref.listenManual(lokasiControllerProvider, (l, n) {
      if (n.daftarLokasi.isNotEmpty && n.aktif != null) {
        ref.read(zonaControllerProvider.notifier).loadZona(lokasi: n.aktif);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _lokasiSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zonaList = ref.watch(zonaControllerProvider).zona;
    final filtered = zonaList.where((z) {
      final q = _query.toLowerCase();
      return z.nama.toLowerCase().contains(q) ||
          z.kode.toLowerCase().contains(q) ||
          z.lokasi.nama.toLowerCase().contains(q);
    }).toList();

    return AppLayout(
      title: 'Zona',
      breadcrumbs: const ['Zona', 'List'],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Toolbar(
                onSearch: (v) => setState(() => _query = v),
                onTambah: () => _showFormDialog(context, null),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  if (constraints.maxWidth >= 640) {
                    return _ZonaTable(
                      items: filtered,
                      onEdit: (z) => _showFormDialog(context, z),
                      onDelete: (z) => _showDeleteDialog(context, z),
                    );
                  }
                  return _ZonaMobileList(
                    items: filtered,
                    onEdit: (z) => _showFormDialog(context, z),
                    onDelete: (z) => _showDeleteDialog(context, z),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, Zona? zona) {
    showDialog(
      context: context,
      builder: (_) => _ZonaFormDialog(zona: zona),
    );
  }

  void _showDeleteDialog(BuildContext context, Zona zona) {
    showDialog(
      context: context,
      builder: (_) => _ZonaDeleteDialog(zona: zona),
    );
  }
}

// ── Toolbar ───────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onTambah;

  const _Toolbar({required this.onSearch, required this.onTambah});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              onChanged: onSearch,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari zona...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 1,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 36,
          child: ElevatedButton.icon(
            onPressed: onTambah,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Tambah Zona', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tabel (desktop) ───────────────────────────────────────

class _ZonaTable extends StatelessWidget {
  final List<Zona> items;
  final ValueChanged<Zona> onEdit;
  final ValueChanged<Zona> onDelete;

  const _ZonaTable({
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
            ? const _EmptyState()
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
                  DataColumn(label: Text('NAMA ZONA')),
                  DataColumn(label: Text('LOKASI')),
                  DataColumn(label: Text('STATUS')),
                ],
                rows: items
                    .map(
                      (z) => DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                _ActionBtn(
                                  icon: Icons.edit_outlined,
                                  onTap: () => onEdit(z),
                                ),
                                const SizedBox(width: 6),
                                _ActionBtn(
                                  icon: Icons.delete_outline_rounded,
                                  isDestructive: true,
                                  onTap: () => onDelete(z),
                                ),
                                const SizedBox(width: 6),
                                _ActionBtn(
                                  icon: Icons.visibility,
                                  onTap: () => context.go('/zona/${z.id}'),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              z.kode,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              z.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              z.lokasi.nama,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                          DataCell(StatusBadge(status: z.status)),
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

class _ZonaMobileList extends StatelessWidget {
  final List<Zona> items;
  final ValueChanged<Zona> onEdit;
  final ValueChanged<Zona> onDelete;

  const _ZonaMobileList({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return Column(
      children: items
          .map(
            (z) => _ZonaMobileCard(
              zona: z,
              onEdit: () => onEdit(z),
              onDelete: () => onDelete(z),
            ),
          )
          .toList(),
    );
  }
}

class _ZonaMobileCard extends StatelessWidget {
  final Zona zona;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ZonaMobileCard({
    required this.zona,
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
                      zona.nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      zona.kode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: zona.status),
            ],
          ),
          const SizedBox(height: 10),
          _MobileField(label: 'Lokasi', value: zona.lokasi.nama),
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
                  side: const BorderSide(color: Color(0xFFFCA5A5), width: 0.5),
                  backgroundColor: const Color(0xFFFEE2E2),
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

class _MobileField extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MobileField({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor ?? const Color(0xFF111827),
            fontWeight: valueColor != null
                ? FontWeight.w500
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ── Form dialog (create / edit) ───────────────────────────

class _ZonaFormDialog extends ConsumerStatefulWidget {
  final Zona? zona;

  const _ZonaFormDialog({this.zona});

  @override
  ConsumerState<_ZonaFormDialog> createState() => _ZonaFormDialogState();
}

class _ZonaFormDialogState extends ConsumerState<_ZonaFormDialog> {
  late final TextEditingController _kode;
  late final TextEditingController _nama;
  late final TextEditingController _kapasitas;
  List<Lokasi> _lokasiOptions = [];
  Lokasi? _lokasi;
  StatusZona _status = StatusZona.aktif;

  @override
  void initState() {
    super.initState();
    final z = widget.zona;
    _kode = TextEditingController(text: z?.kode ?? '');
    _nama = TextEditingController(text: z?.nama ?? '');
    _kapasitas = TextEditingController(text: z != null ? '${z.kapasitas}' : '');
    _lokasiOptions = ref.read(lokasiControllerProvider).daftarLokasi;
    _status = z?.status ?? StatusZona.aktif;
    _lokasi = ref.read(lokasiControllerProvider).aktif;
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _kapasitas.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_kode.text.trim().isEmpty ||
        _nama.text.trim().isEmpty ||
        _lokasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode, nama, dan lokasi wajib diisi.')),
      );
      return;
    }
    final kap = int.tryParse(_kapasitas.text) ?? 0;
    if (widget.zona == null) {
      ref
          .read(zonaControllerProvider.notifier)
          .tambah(
            kode: _kode.text.trim(),
            nama: _nama.text.trim(),
            lokasi: _lokasi!,
            kapasitas: kap,
            status: _status,
          );
    } else {
      ref
          .read(zonaControllerProvider.notifier)
          .edit(
            widget.zona!.id,
            kode: _kode.text.trim(),
            nama: _nama.text.trim(),
            lokasi: _lokasi!,
            lokasiId: _lokasi!.id,
            kapasitas: kap,
            status: _status,
          );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.zona != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Text(
                    isEdit ? 'Edit Zona' : 'Tambah Zona',
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
            // Body
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _FormField(
                    label: 'Kode Zona',
                    controller: _kode,
                    hint: 'cth. Z-01',
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'Nama Zona',
                    controller: _nama,
                    hint: 'cth. Zona Administrasi',
                  ),
                  const SizedBox(height: 12),
                  if (_lokasi == null)
                    _DropdownField<Lokasi>(
                      label: 'Lokasi',
                      value: _lokasi,
                      hint: 'Pilih lokasi...',
                      items: _lokasiOptions
                          .map(
                            (l) =>
                                DropdownMenuItem(value: l, child: Text(l.nama)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _lokasi = v),
                    ),
                  if (_lokasi == null) const SizedBox(height: 12),
                  _DropdownField<StatusZona>(
                    label: 'Status',
                    value: _status,
                    items: StatusZona.values
                        .map(
                          (s) =>
                              DropdownMenuItem(value: s, child: Text(s.label)),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _status = v ?? StatusZona.aktif),
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5),
            // Footer
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
                    child: const Text('Simpan'),
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

class _ZonaDeleteDialog extends ConsumerWidget {
  final Zona zona;

  const _ZonaDeleteDialog({required this.zona});

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
                    'Hapus zona ini?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${zona.nama}" akan dihapus secara permanen.',
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
                    onPressed: () {
                      ref.read(zonaControllerProvider.notifier).hapus(zona.id);
                      Navigator.pop(context);
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

// ── Shared widgets ────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final StatusZona status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.badgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: status.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: status.badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionBtn({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFFCA5A5)
                : const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 13,
          color: isDestructive
              ? const Color(0xFFEF4444)
              : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'Tidak ada zona ditemukan',
          style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFD1D5DB),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 36,
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            hint: hint != null
                ? Text(
                    hint!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFD1D5DB),
                    ),
                  )
                : null,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
