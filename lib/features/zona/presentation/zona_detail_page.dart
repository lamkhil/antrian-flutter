import 'package:antrian/extension/size.dart';
import 'package:antrian/features/zona/application/detail_zona_controller.dart';
import 'package:antrian/features/zona/application/layanan_zona_controller.dart';
import 'package:antrian/features/zona/presentation/zona_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/layanan.dart';
import '../../../data/models/zona.dart';
import '../../../globals/widgets/app_layout.dart';

class ZonaDetailPage extends ConsumerStatefulWidget {
  final String id;

  const ZonaDetailPage({super.key, required this.id});

  @override
  ConsumerState<ZonaDetailPage> createState() => _ZonaDetailPageState();
}

class _ZonaDetailPageState extends ConsumerState<ZonaDetailPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(detailZonaControllerProvider.notifier).loadZona(widget.id);
      ref.read(layananZonaControllerProvider.notifier).loadLayanan(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detailZonaControllerProvider);
    final stateLayanan = ref.watch(layananZonaControllerProvider);
    return AppLayout(
      title: state.zona?.nama ?? '',
      breadcrumbs: const ['Zona', 'List', 'Detail'],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              if (state.status == DetailZonaStatus.success)
                _ZonaInfoCard(zona: state.zona!),
              if (state.status == DetailZonaStatus.loading ||
                  state.status == DetailZonaStatus.initial)
                const _ZonaInfoCardShimmer(),
              if (state.status == DetailZonaStatus.error)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFCA5A5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Gagal memuat data zona.\n${state.error}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFB91C1C),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Header section layanan
              Row(
                children: [
                  const Text(
                    'Daftar Layanan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showFormDialog(context, ref, widget.id, null),
                      icon: const Icon(Icons.add_rounded, size: 14),
                      label: const Text(
                        'Tambah Layanan',
                        style: TextStyle(fontSize: 12),
                      ),
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
              ),
              const SizedBox(height: 12),

              // Tabel layanan
              if (stateLayanan.status == LayananZonaStatus.loading ||
                  stateLayanan.status == LayananZonaStatus.initial)
                const _LayananTableShimmer(),
              if (stateLayanan.status == LayananZonaStatus.error)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFCA5A5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Gagal memuat data layanan.\n${state.error}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: const Color(0xFFB91C1C),
                    ),
                  ),
                ),
              if (stateLayanan.status == LayananZonaStatus.success)
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    if (constraints.maxWidth >= 580) {
                      return _LayananTable(
                        items: stateLayanan.layanan,
                        onEdit: (l) =>
                            _showFormDialog(context, ref, state.zona!.id, l),
                        onDelete: (l) => _showDeleteDialog(context, ref, l),
                      );
                    }
                    return _LayananMobileList(
                      items: stateLayanan.layanan,
                      onEdit: (l) =>
                          _showFormDialog(context, ref, state.zona!.id, l),
                      onDelete: (l) => _showDeleteDialog(context, ref, l),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFormDialog(
    BuildContext context,
    WidgetRef ref,
    String zonaId,
    Layanan? layanan,
  ) {
    showDialog(
      context: context,
      builder: (_) => _LayananFormDialog(zonaId: zonaId, layanan: layanan),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Layanan layanan) {
    showDialog(
      context: context,
      builder: (_) => _LayananDeleteDialog(layanan: layanan),
    );
  }
}

// ── Info card zona ────────────────────────────────────────

class _ZonaInfoCard extends StatelessWidget {
  final Zona zona;

  const _ZonaInfoCard({required this.zona});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  size: 18,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zona.nama,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${zona.kode} · ${zona.lokasi.nama}',
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
          const SizedBox(height: 14),
          Row(
            children: [
              _StatCard(label: 'Kapasitas', value: '${zona.kapasitas}'),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Antrian aktif',
                value: '${zona.antrianAktif}',
                accent: true,
              ),
              const SizedBox(width: 10),
              _StatCard(label: 'Total layanan', value: '${zona.jumlahLayanan}'),
              const SizedBox(width: 10),
              _StatCard(label: 'Layanan aktif', value: '${zona.jumlahLayanan}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _StatCard({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: accent
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tabel layanan (desktop) ───────────────────────────────

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
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
                headingRowHeight: 40,
                dataRowMinHeight: 44,
                dividerThickness: 0.5,
                columns: const [
                  DataColumn(label: Text('AKSI')),
                  DataColumn(label: Text('KODE')),
                  DataColumn(label: Text('NAMA LAYANAN')),
                  DataColumn(label: Text('DESKRIPSI')),
                  DataColumn(label: Text('DURASI'), numeric: true),
                  DataColumn(label: Text('BIAYA'), numeric: true),
                  DataColumn(label: Text('STATUS')),
                ],
                rows: items
                    .map(
                      (l) => DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                _ActionBtn(
                                  icon: Icons.edit_outlined,
                                  onTap: () => onEdit(l),
                                ),
                                const SizedBox(width: 6),
                                _ActionBtn(
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
                              l.deskripsi.isEmpty ? '-' : l.deskripsi,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Text(
                              '${l.durasiMenit} mnt',
                              style: const TextStyle(color: Color(0xFF6B7280)),
                            ),
                          ),
                          DataCell(
                            Text(
                              l.biaya == 0 ? 'Gratis' : fmt.format(l.biaya),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          DataCell(_LayananStatusBadge(status: l.status)),
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
    if (items.isEmpty) return const _EmptyState();
    return Column(
      children: items
          .map(
            (l) => _LayananMobileCard(
              layanan: l,
              onEdit: () => onEdit(l),
              onDelete: () => onDelete(l),
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
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
              _LayananStatusBadge(status: layanan.status),
            ],
          ),
          if (layanan.deskripsi.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              layanan.deskripsi,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _MobileField(
                label: 'Durasi',
                value: '${layanan.durasiMenit} mnt',
              ),
              const SizedBox(width: 16),
              _MobileField(
                label: 'Biaya',
                value: layanan.biaya == 0
                    ? 'Gratis'
                    : fmt.format(layanan.biaya),
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

class _MobileField extends StatelessWidget {
  final String label;
  final String value;

  const _MobileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
      ),
    ],
  );
}

// ── Form dialog ───────────────────────────────────────────

class _LayananFormDialog extends ConsumerStatefulWidget {
  final String zonaId;
  final Layanan? layanan;

  const _LayananFormDialog({required this.zonaId, this.layanan});

  @override
  ConsumerState<_LayananFormDialog> createState() => _LayananFormDialogState();
}

class _LayananFormDialogState extends ConsumerState<_LayananFormDialog> {
  late final TextEditingController _kode;
  late final TextEditingController _nama;
  late final TextEditingController _desk;
  late final TextEditingController _durasi;
  late final TextEditingController _biaya;
  StatusLayanan _status = StatusLayanan.aktif;

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

  void _simpan() {
    if (_kode.text.trim().isEmpty || _nama.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode dan nama wajib diisi.')),
      );
      return;
    }
    if (widget.layanan == null) {
      ref
          .read(layananZonaControllerProvider.notifier)
          .tambahLayanan(
            zona: ref.read(detailZonaControllerProvider).zona!,
            kode: _kode.text.trim(),
            nama: _nama.text.trim(),
            deskripsi: _desk.text.trim(),
            durasiMenit: int.tryParse(_durasi.text) ?? 15,
            biaya: int.tryParse(_biaya.text) ?? 0,
            status: _status,
          );
    } else {
      ref
          .read(layananZonaControllerProvider.notifier)
          .editLayanan(
            widget.layanan!.id,
            kode: _kode.text.trim(),
            nama: _nama.text.trim(),
            deskripsi: _desk.text.trim(),
            durasiMenit: int.tryParse(_durasi.text) ?? 15,
            biaya: int.tryParse(_biaya.text) ?? 0,
            status: _status,
          );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.layanan != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'Kode Layanan',
                          controller: _kode,
                          hint: 'cth. LY-01',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 36,
                              child: DropdownButtonFormField<StatusLayanan>(
                                value: _status,
                                onChanged: (v) => setState(
                                  () => _status = v ?? StatusLayanan.aktif,
                                ),
                                items: StatusLayanan.values
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.label),
                                      ),
                                    )
                                    .toList(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF111827),
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'Nama Layanan',
                    controller: _nama,
                    hint: 'cth. Pembuatan KTP',
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'Deskripsi',
                    controller: _desk,
                    hint: 'Deskripsi singkat layanan...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FormField(
                          label: 'Durasi (menit)',
                          controller: _durasi,
                          hint: '30',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FormField(
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

class _LayananDeleteDialog extends ConsumerWidget {
  final Layanan layanan;

  const _LayananDeleteDialog({required this.layanan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Hapus layanan ini?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '"${layanan.nama}" akan dihapus secara permanen.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
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
                      ref
                          .read(layananZonaControllerProvider.notifier)
                          .hapusLayanan(layanan.id);
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

class _LayananStatusBadge extends StatelessWidget {
  final StatusLayanan status;

  const _LayananStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) => Container(
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      width: 26,
      height: 26,
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
        size: 12,
        color: isDestructive
            ? const Color(0xFFEF4444)
            : const Color(0xFF6B7280),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 36),
    child: Center(
      child: Text(
        'Belum ada layanan. Tambahkan layanan pertama.',
        style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      ),
    ),
  );
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Column(
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
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFD1D5DB)),
          contentPadding: maxLines > 1
              ? const EdgeInsets.all(10)
              : const EdgeInsets.symmetric(horizontal: 10),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1),
          ),
        ),
      ),
    ],
  );
}

class _ZonaInfoCardShimmer extends StatelessWidget {
  const _ZonaInfoCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF3F4F6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),

                // nama + kode
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 120, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 10, width: 180, color: Colors.white),
                    ],
                  ),
                ),

                // status badge
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: List.generate(
                4,
                (_) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(10),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayananTableShimmer extends StatelessWidget {
  const _LayananTableShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF3F4F6),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
        ),
        child: Column(
          children: [
            // header
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),

            // rows
            Column(
              children: List.generate(
                5,
                (_) => Container(
                  height: 44,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      _cell(60),
                      _cell(140),
                      _cell(180),
                      _cell(60),
                      _cell(80),
                      _cell(70),
                      _cell(60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(double width) {
    return Container(
      width: width,
      height: 12,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
