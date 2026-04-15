import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:antrian/extension/size.dart';
import 'package:antrian/features/layanan/application/layanan_controller.dart';
import 'package:antrian/features/zona/application/zona_controller.dart';
import 'package:antrian/globals/providers/lokasi/lokasi_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/layanan.dart';
import '../../../globals/widgets/app_action_button.dart';
import '../../../globals/widgets/app_dropdown_field.dart';
import '../../../globals/widgets/app_empty_state.dart';
import '../../../globals/widgets/app_form_field.dart';
import '../../../globals/widgets/app_layout.dart';
import '../../../globals/widgets/app_list_toolbar.dart';
import '../../../globals/widgets/app_mobile_field.dart';
import '../../../globals/widgets/status_badge.dart';

class LayananPage extends ConsumerStatefulWidget {
  const LayananPage({super.key});

  @override
  ConsumerState<LayananPage> createState() => _LayananPageState();
}

class _LayananPageState extends ConsumerState<LayananPage> {
  String _query = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(layananControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final layananList = ref.watch(layananControllerProvider).layanan;
    final filtered = layananList.where((z) {
      final q = _query.toLowerCase();
      return z.nama.toLowerCase().contains(q) ||
          z.kode.toLowerCase().contains(q) ||
          z.zona.nama.toLowerCase().contains(q);
    }).toList();

    return AppLayout(
      title: 'Layanan',
      breadcrumbs: const ['Layanan', 'List'],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppListToolbar(
                searchHint: 'Cari layanan...',
                addLabel: 'Tambah Layanan',
                onSearch: (v) => setState(() => _query = v),
                onAdd: () => _showFormDialog(context, null),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  if (constraints.maxWidth >= 640) {
                    return _LayananTable(
                      items: filtered,
                      onEdit: (z) => _showFormDialog(context, z),
                      onDelete: (z) => _showDeleteDialog(context, z),
                    );
                  }
                  return _LayananMobileList(
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

  void _showFormDialog(BuildContext context, Layanan? layanan) {
    showDialog(
      context: context,
      builder: (_) => _LayananFormDialog(layanan: layanan),
    );
  }

  void _showDeleteDialog(BuildContext context, Layanan layanan) {
    showDialog(
      context: context,
      builder: (_) => _LayananDeleteDialog(layanan: layanan),
    );
  }
}


// ── Tabel (desktop) ───────────────────────────────────────

class _LayananTable extends StatelessWidget {
  final List<Layanan> items;
  final ValueChanged<Layanan> onEdit;
  final ValueChanged<Layanan> onDelete;

  const _LayananTable({
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
            ? const AppEmptyState(message: 'Tidak ada layanan ditemukan')
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
                  DataColumn(label: Text('NAMA LAYANAN')),
                  DataColumn(label: Text('DESKRIPSI')),
                  DataColumn(label: Text('ZONA')),
                  DataColumn(label: Text('LOKASI')),
                  DataColumn(label: Text('DURASI'), numeric: true),
                  DataColumn(label: Text('STATUS')),
                ],
                rows: items
                    .map(
                      (z) => DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                AppActionButton(
                                  icon: Icons.edit_outlined,
                                  onTap: () => onEdit(z),
                                ),
                                const SizedBox(width: 6),
                                AppActionButton(
                                  icon: Icons.delete_outline_rounded,
                                  isDestructive: true,
                                  onTap: () => onDelete(z),
                                ),
                                const SizedBox(width: 6),
                                AppActionButton(
                                  icon: Icons.visibility,
                                  onTap: () =>
                                      context.go('/layanan/${z.id}'),
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
                              z.deskripsi.isEmpty ? '-' : z.deskripsi,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),

                          DataCell(
                            Text(
                              z.zona.nama,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),

                          DataCell(
                            Text(
                              z.lokasi.nama,
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${z.durasiMenit} menit',
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),

                          DataCell(
                            StatusBadge(
                              label: z.status.label,
                              bg: z.status.badgeBg,
                              fg: z.status.badgeColor,
                              dot: z.status.dotColor,
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

class _LayananMobileList extends StatelessWidget {
  final List<Layanan> items;
  final ValueChanged<Layanan> onEdit;
  final ValueChanged<Layanan> onDelete;

  const _LayananMobileList({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppEmptyState(message: 'Tidak ada layanan ditemukan');
    }
    return Column(
      children: items
          .map(
            (z) => _LayananMobileCard(
              layanan: z,
              onEdit: () => onEdit(z),
              onDelete: () => onDelete(z),
            ),
          )
          .toList(),
    );
  }
}

class _LayananMobileCard extends StatelessWidget {
  final Layanan layanan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LayananMobileCard({
    required this.layanan,
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
                      layanan.nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      layanan.kode,
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
                label: layanan.status.label,
                bg: layanan.status.badgeBg,
                fg: layanan.status.badgeColor,
                dot: layanan.status.dotColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AppMobileField(label: 'Zona', value: layanan.zona.nama),
              const SizedBox(width: 16),
              AppMobileField(
                label: 'Durasi',
                value: '${layanan.durasiMenit} menit',
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


// Untuk lokasi — read only, terisi otomatis dari zona
class _ReadonlyField extends StatelessWidget {
  final String label;
  final String value;
  final String hint;

  const _ReadonlyField({
    required this.label,
    required this.value,
    this.hint = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'otomatis',
                style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: value == '—'
                  ? const Color(0xFFD1D5DB)
                  : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}

class _LayananDeleteDialog extends ConsumerStatefulWidget {
  final Layanan layanan;

  const _LayananDeleteDialog({required this.layanan});

  @override
  ConsumerState<_LayananDeleteDialog> createState() =>
      _LayananDeleteDialogState();
}

class _LayananDeleteDialogState extends ConsumerState<_LayananDeleteDialog> {
  bool _loading = false;

  Future<void> _hapus() async {
    setState(() => _loading = true);
    try {
      ref.read(layananControllerProvider.notifier).hapus(widget.layanan.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Body ─────────────────────────────────────
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
                    'Hapus layanan ini?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                      children: [
                        const TextSpan(text: 'Layanan '),
                        TextSpan(
                          text: widget.layanan.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const TextSpan(
                          text:
                              ' akan dihapus secara permanen'
                              ' dan tidak dapat dikembalikan.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Info chip zona & lokasi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.business_rounded,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${widget.layanan.zona.nama} · '
                            '${widget.layanan.lokasi.nama}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Footer ───────────────────────────────────
            const Divider(height: 0.5),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
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
                    onPressed: _loading ? null : _hapus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Ya, hapus'),
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

class _LayananFormDialog extends ConsumerStatefulWidget {
  final Layanan? layanan;

  const _LayananFormDialog({this.layanan});

  @override
  ConsumerState<_LayananFormDialog> createState() => _LayananFormDialogState();
}

class _LayananFormDialogState extends ConsumerState<_LayananFormDialog> {
  late final TextEditingController _kode;
  late final TextEditingController _nama;
  late final TextEditingController _desk;
  late final TextEditingController _durasi;
  late final TextEditingController _biaya;

  Zona? _zonaSelected;
  Lokasi? _lokasiDerived; // otomatis dari zona
  StatusLayanan _status = StatusLayanan.aktif;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final l = widget.layanan;
    _kode = TextEditingController(text: l?.kode ?? '');
    _nama = TextEditingController(text: l?.nama ?? '');
    _desk = TextEditingController(text: l?.deskripsi ?? '');
    _durasi = TextEditingController(text: l != null ? '${l.durasiMenit}' : '');
    _biaya = TextEditingController(text: l != null ? '${l.biaya}' : '');
    _status = l?.status ?? StatusLayanan.aktif;

    // Saat edit, pre-fill zona & lokasi
    if (l != null) {
      _zonaSelected = l.zona;
      _lokasiDerived = l.lokasi;
    } else {
      _lokasiDerived = ref.read(lokasiControllerProvider).aktif;
    }
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _desk.dispose();
    _durasi.dispose();
    _biaya.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_kode.text.trim().isEmpty ||
        _nama.text.trim().isEmpty ||
        _zonaSelected == null ||
        _lokasiDerived == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode, nama, dan zona wajib diisi.')),
      );
      return;
    }

    setState(() => _loading = true);

    final isEdit = widget.layanan != null;

    try {
      if (isEdit) {
        ref
            .read(layananControllerProvider.notifier)
            .edit(
              widget.layanan!.copyWith(
                kode: _kode.text.trim(),
                nama: _nama.text.trim(),
                deskripsi: _desk.text.trim(),
                durasiMenit: int.tryParse(_durasi.text) ?? 15,
                biaya: int.tryParse(_biaya.text) ?? 0,
                status: _status,
                zona: _zonaSelected,
                zonaId: _zonaSelected!.id,
                lokasi: _lokasiDerived,
                lokasiId: _lokasiDerived!.id,
              ),
            );
      } else {
        ref
            .read(layananControllerProvider.notifier)
            .tambah(
              kode: _kode.text.trim(),
              nama: _nama.text.trim(),
              deskripsi: _desk.text.trim(),
              durasiMenit: int.tryParse(_durasi.text) ?? 15,
              biaya: int.tryParse(_biaya.text) ?? 0,
              status: _status,
              zona: _zonaSelected!,
            );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onZonaChanged(Zona? newZona) {
    setState(() {
      _zonaSelected = newZona;
      _lokasiDerived = newZona?.lokasi;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.layanan != null;
    final zonaList = ref.watch(zonaControllerProvider).zona;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: [
                  Text(
                    isEdit ? 'Edit Layanan' : 'Tambah Layanan',
                    style: const TextStyle(
                      fontSize: 14,
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

            // ── Body ─────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris 1 — Kode & Status
                    Row(
                      children: [
                        Expanded(
                          child: AppFormField(
                            label: 'Kode Layanan',
                            controller: _kode,
                            hint: 'cth. LY-01',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppDropdownField<StatusLayanan>(
                            label: 'Status',
                            value: _status,
                            items: StatusLayanan.values
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(
                              () => _status = v ?? StatusLayanan.aktif,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Baris 2 — Nama
                    AppFormField(
                      label: 'Nama Layanan',
                      controller: _nama,
                      hint: 'cth. Pembuatan KTP',
                    ),
                    const SizedBox(height: 12),

                    // Baris 3 — Deskripsi
                    AppFormField(
                      label: 'Deskripsi',
                      controller: _desk,
                      hint: 'Deskripsi singkat layanan...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // Baris 4 — Zona (+ Lokasi otomatis)
                    if (zonaList.isNotEmpty)
                      AppDropdownField<Zona>(
                        label: 'Zona',
                        value: _zonaSelected,
                        hint: 'Pilih zona...',
                        items: zonaList
                            .map(
                              (z) => DropdownMenuItem(
                                value: z,
                                child: Text(
                                  '${z.nama} — ${z.lokasi.nama}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _onZonaChanged,
                      ),
                    const SizedBox(height: 12),

                    // Lokasi — read only, otomatis dari zona
                    _ReadonlyField(
                      label: 'Lokasi',
                      value: _lokasiDerived?.nama ?? '—',
                      hint: 'Otomatis dari zona',
                    ),
                    const SizedBox(height: 12),

                    // Baris 5 — Durasi & Biaya
                    Row(
                      children: [
                        Expanded(
                          child: AppFormField(
                            label: 'Durasi (menit)',
                            controller: _durasi,
                            hint: '15',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppFormField(
                            label: 'Biaya (Rp)',
                            controller: _biaya,
                            hint: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────
            const Divider(height: 0.5),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
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
                    onPressed: _loading ? null : _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
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
