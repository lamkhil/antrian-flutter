import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/extension/size.dart';
import 'package:antrian/features/laporan/application/laporan_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../globals/widgets/app_empty_state.dart';
import '../../../globals/widgets/app_layout.dart';

class LaporanPage extends ConsumerWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(laporanControllerProvider);
    final fmtDate = DateFormat('d MMM yyyy', 'id_ID');

    return AppLayout(
      title: 'Laporan',
      breadcrumbs: const ['Laporan'],
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(context.isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter tanggal
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${fmtDate.format(state.tanggalDari)} — ${fmtDate.format(state.tanggalSampai)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _pickRange(context, ref),
                      icon: const Icon(Icons.edit_calendar_outlined, size: 14),
                      label: const Text(
                        'Ubah rentang',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (state.status == LaporanStatus.loading)
                const _Loading()
              else if (state.status == LaporanStatus.error)
                _ErrorBox(message: 'Gagal memuat laporan.\n${state.error}')
              else ...[
                _SummaryRow(state: state),
                const SizedBox(height: 16),
                _RataTungguCard(state: state),
                const SizedBox(height: 16),
                _GroupSection(
                  title: 'Per Zona',
                  items: state.perZona,
                ),
                const SizedBox(height: 16),
                _GroupSection(
                  title: 'Per Layanan',
                  items: state.perLayanan,
                ),
                const SizedBox(height: 16),
                _GroupSection(
                  title: 'Per Loket',
                  items: state.perLoket,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final current = ref.read(laporanControllerProvider);
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: current.tanggalDari,
        end: current.tanggalSampai,
      ),
    );
    if (result != null) {
      final dari = DateTime(
        result.start.year,
        result.start.month,
        result.start.day,
      );
      final sampai = DateTime(
        result.end.year,
        result.end.month,
        result.end.day,
        23,
        59,
        59,
      );
      ref
          .read(laporanControllerProvider.notifier)
          .setTanggal(dari: dari, sampai: sampai);
    }
  }
}

// ── Summary row ───────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final LaporanState state;
  const _SummaryRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final cells = [
      _SummaryCell(label: 'Total', value: state.total, accent: true),
      _SummaryCell(
        label: StatusAntrian.menunggu.label,
        value: state.countByStatus(StatusAntrian.menunggu),
        color: StatusAntrian.menunggu.statColor,
      ),
      _SummaryCell(
        label: StatusAntrian.dipanggil.label,
        value: state.countByStatus(StatusAntrian.dipanggil),
        color: StatusAntrian.dipanggil.statColor,
      ),
      _SummaryCell(
        label: StatusAntrian.dilayani.label,
        value: state.countByStatus(StatusAntrian.dilayani),
        color: StatusAntrian.dilayani.statColor,
      ),
      _SummaryCell(
        label: StatusAntrian.selesai.label,
        value: state.countByStatus(StatusAntrian.selesai),
        color: StatusAntrian.selesai.statColor,
      ),
      _SummaryCell(
        label: StatusAntrian.dilewati.label,
        value: state.countByStatus(StatusAntrian.dilewati),
        color: StatusAntrian.dilewati.statColor,
      ),
    ];
    return LayoutBuilder(
      builder: (ctx, cons) {
        final isWide = cons.maxWidth >= 640;
        if (isWide) {
          return Row(
            children: [
              for (int i = 0; i < cells.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: cells[i]),
              ],
            ],
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cells
              .map(
                (c) => SizedBox(width: (cons.maxWidth - 10) / 2, child: c),
              )
              .toList(),
        );
      },
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final int value;
  final bool accent;
  final Color? color;
  const _SummaryCell({
    required this.label,
    required this.value,
    this.accent = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: accent
                  ? const Color(0xFF6366F1)
                  : color ?? const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rata tunggu ───────────────────────────────────────────

class _RataTungguCard extends StatelessWidget {
  final LaporanState state;
  const _RataTungguCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final menit = state.rataTungguMenit;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.timelapse_rounded,
              size: 18,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rata-rata waktu tunggu',
                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 4),
              Text(
                menit > 0 ? '${menit.toStringAsFixed(1)} menit' : '—',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Group section ─────────────────────────────────────────

class _GroupSection extends StatelessWidget {
  final String title;
  final List<GrupLaporan> items;
  const _GroupSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Divider(height: 0.5, color: Color(0xFFF3F4F6)),
          if (items.isEmpty)
            const AppEmptyState(message: 'Tidak ada data', verticalPadding: 24)
          else
            ...items.map(
              (g) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        g.label,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      '${g.total}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────

class _Loading extends StatelessWidget {
  const _Loading();

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

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5), width: 0.5),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
      ),
    );
  }
}
