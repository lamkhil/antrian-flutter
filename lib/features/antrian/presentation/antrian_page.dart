import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/antrian.dart';
import '../../../globals/widgets/app_layout.dart';
import '../application/antrian_controller.dart';

class AntrianPage extends ConsumerStatefulWidget {
  const AntrianPage({super.key});

  @override
  ConsumerState<AntrianPage> createState() => _AntrianPageState();
}

class _AntrianPageState extends ConsumerState<AntrianPage> {
  String _query = '';
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(antrianControllerProvider.notifier).load());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(antrianControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(antrianControllerProvider);

    // Filter search hanya di client-side (sudah dipaginasi server)
    final filtered = _query.isEmpty
        ? state.antrian
        : state.antrian.where((a) {
            final q = _query.toLowerCase();
            return a.nama.toLowerCase().contains(q) ||
                a.nomorAntrian.toLowerCase().contains(q) ||
                a.layanan.nama.toLowerCase().contains(q);
          }).toList();

    return AppLayout(
      title: 'Antrian',
      breadcrumbs: const ['Antrian', 'List'],
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards

              // Filter tanggal + status
              _FilterBar(
                state: state,
                onTanggalChange: (dari, sampai) => ref
                    .read(antrianControllerProvider.notifier)
                    .setTanggal(dari: dari, sampai: sampai),
                onStatusChange: (s) => ref
                    .read(antrianControllerProvider.notifier)
                    .setFilterStatus(s),
                onSearch: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 14),

              _SummaryRow(antrian: state.antrian),
              const SizedBox(height: 20),

              // Error
              if (state.error != null) _ErrorBanner(message: state.error!),

              // Loading awal
              if (state.isLoading)
                const _LoadingState()
              else
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    if (constraints.maxWidth >= 640) {
                      return _AntrianTable(items: filtered);
                    }
                    return _AntrianMobileList(items: filtered);
                  },
                ),

              // Load more indicator
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ),

              // End of list
              if (!state.isLoading &&
                  !state.hasMore &&
                  state.antrian.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Menampilkan ${state.antrian.length} data',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final AntrianState state;
  final void Function(DateTime dari, DateTime sampai) onTanggalChange;
  final ValueChanged<StatusAntrian?> onStatusChange;
  final ValueChanged<String> onSearch;

  const _FilterBar({
    required this.state,
    required this.onTanggalChange,
    required this.onStatusChange,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Date range picker
            Expanded(
              child: _DateRangeButton(
                dari: state.tanggalDari,
                sampai: state.tanggalSampai,
                onChanged: onTanggalChange,
              ),
            ),
            const SizedBox(width: 10),
            // Search
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 36,
                child: TextField(
                  onChanged: onSearch,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, nomor, atau layanan...',
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
          ],
        ),
        const SizedBox(height: 10),
        // Status chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'Semua',
                isActive: state.filterStatus == null,
                onTap: () => onStatusChange(null),
              ),
              ...StatusAntrian.values.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _FilterChip(
                    label: s.label,
                    dotColor: s.dotColor,
                    isActive: state.filterStatus == s,
                    onTap: () => onStatusChange(s),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Date range button ─────────────────────────────────────

class _DateRangeButton extends StatelessWidget {
  final DateTime dari;
  final DateTime sampai;
  final void Function(DateTime, DateTime) onChanged;

  const _DateRangeButton({
    required this.dari,
    required this.sampai,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final minDate = now.subtract(
      const Duration(days: AntrianState.maxRangeHari),
    );

    final result = await showDateRangePicker(
      context: context,
      firstDate: minDate,
      lastDate: now,
      initialDateRange: DateTimeRange(start: dari, end: sampai),
      helpText: 'Pilih rentang tanggal (maks. 30 hari)',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6366F1),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (result != null) {
      // Paksa max 30 hari jika user memilih lebih
      final diff = result.end.difference(result.start).inDays;
      final effectiveDari = diff > AntrianState.maxRangeHari
          ? result.end.subtract(const Duration(days: AntrianState.maxRangeHari))
          : result.start;

      onChanged(effectiveDari, result.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM', 'id');
    final label =
        dari.year == sampai.year &&
            dari.month == sampai.month &&
            dari.day == sampai.day
        ? fmt.format(dari)
        : '${fmt.format(dari)} – ${fmt.format(sampai)}';

    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary cards ─────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final List<Antrian> antrian;

  const _SummaryRow({required this.antrian});

  @override
  Widget build(BuildContext context) {
    int count(StatusAntrian? s) =>
        s == null ? antrian.length : antrian.where((a) => a.status == s).length;

    final items = [
      (label: 'Total', value: count(null), color: const Color(0xFF6366F1)),
      (
        label: 'Menunggu',
        value: count(StatusAntrian.menunggu),
        color: StatusAntrian.menunggu.statColor,
      ),
      (
        label: 'Dipanggil',
        value: count(StatusAntrian.dipanggil),
        color: StatusAntrian.dipanggil.statColor,
      ),
      (
        label: 'Dilayani',
        value: count(StatusAntrian.dilayani),
        color: StatusAntrian.dilayani.statColor,
      ),
      (
        label: 'Dilewati',
        value: count(StatusAntrian.dilewati),
        color: StatusAntrian.dilewati.statColor,
      ),
    ];

    return Row(
      children: List.generate(items.length, (i) {
        final item = items[i];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < items.length - 1 ? 10 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.value}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: item.color,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6366F1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Tabel desktop ─────────────────────────────────────────

class _AntrianTable extends StatelessWidget {
  final List<Antrian> items;

  const _AntrianTable({required this.items});

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
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 48,
                  ),
                  child: DataTable(
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
                    columnSpacing: 16,
                    horizontalMargin: 16,
                    headingRowHeight: 40,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 48,
                    dividerThickness: 0.5,
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('NOMOR')),
                      DataColumn(label: Text('NAMA')),
                      DataColumn(label: Text('LAYANAN')),
                      DataColumn(label: Text('ZONA · LOKASI')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('DAFTAR')),
                      DataColumn(label: Text('DIPANGGIL')),
                      DataColumn(label: Text('SELESAI')),
                    ],
                    rows: List.generate(items.length, (i) {
                      final a = items[i];
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD1D5DB),
                              ),
                            ),
                          ),
                          DataCell(_NomorChip(nomor: a.nomorAntrian)),
                          DataCell(
                            Text(
                              a.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              a.layanan.nama,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  a.zona.nama,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                Text(
                                  a.lokasi.nama,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFD1D5DB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(_StatusBadge(status: a.status)),
                          DataCell(_WaktuCell(dt: a.waktuDaftar)),
                          DataCell(_WaktuCell(dt: a.waktuDipanggil)),
                          DataCell(_WaktuCell(dt: a.waktuSelesai)),
                        ],
                      );
                    }),
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Mobile list ───────────────────────────────────────────

class _AntrianMobileList extends StatelessWidget {
  final List<Antrian> items;

  const _AntrianMobileList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyState();
    return Column(
      children: items.map((a) => _AntrianMobileCard(antrian: a)).toList(),
    );
  }
}

class _AntrianMobileCard extends StatelessWidget {
  final Antrian antrian;

  const _AntrianMobileCard({required this.antrian});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    String fmtWaktu(DateTime? dt) => dt != null ? fmt.format(dt) : '—';

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
              _NomorChip(nomor: antrian.nomorAntrian),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  antrian.nama,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _StatusBadge(status: antrian.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            antrian.layanan.nama,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 2),
          Text(
            '${antrian.zona.nama} · ${antrian.lokasi.nama}',
            style: const TextStyle(fontSize: 11, color: Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 10),
          const Divider(height: 0.5, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 10),
          Row(
            children: [
              _TimeField(label: 'Daftar', value: fmtWaktu(antrian.waktuDaftar)),
              const SizedBox(width: 16),
              _TimeField(
                label: 'Dipanggil',
                value: fmtWaktu(antrian.waktuDipanggil),
              ),
              const SizedBox(width: 16),
              _TimeField(
                label: 'Selesai',
                value: fmtWaktu(antrian.waktuSelesai),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────

class _NomorChip extends StatelessWidget {
  final String nomor;
  const _NomorChip({required this.nomor});

  @override
  Widget build(BuildContext context) => Container(
    width: 52,
    height: 36,
    decoration: BoxDecoration(
      color: const Color(0xFFEEF2FF),
      borderRadius: BorderRadius.circular(8),
    ),
    alignment: Alignment.center,
    child: Text(
      nomor,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'monospace',
        color: Color(0xFF4338CA),
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final StatusAntrian status;
  const _StatusBadge({required this.status});

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

class _WaktuCell extends StatelessWidget {
  final DateTime? dt;
  const _WaktuCell({this.dt});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    return Text(
      dt != null ? fmt.format(dt!) : '—',
      style: TextStyle(
        fontSize: 12,
        fontFamily: dt != null ? 'monospace' : null,
        color: dt != null ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  const _TimeField({required this.label, required this.value});

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
        style: TextStyle(
          fontSize: 13,
          color: value == '—'
              ? const Color(0xFFD1D5DB)
              : const Color(0xFF111827),
          fontFamily: value != '—' ? 'monospace' : null,
        ),
      ),
    ],
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 60),
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Color(0xFF6366F1),
      ),
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFFCA5A5), width: 0.5),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 16,
          color: Color(0xFFEF4444),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText(
            message,
            style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: Text(
        'Tidak ada data antrian',
        style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      ),
    ),
  );
}
