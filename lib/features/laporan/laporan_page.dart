import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:intl/intl.dart';
import '../../data/models/antrian.dart';
import '../antrian/antrian_resource.dart';

class LaporanPage extends FilamentPage {
  const LaporanPage({super.key});

  @override String get slug => 'laporan';
  @override String get title => 'Laporan Antrian';
  @override String? get subtitle =>
      'Ringkasan & riwayat antrian per rentang tanggal';
  @override IconData get icon => Icons.bar_chart_outlined;
  @override String? get navigationGroup => 'Laporan';
  @override int get navigationSort => 10;

  @override
  Widget buildBody(BuildContext context) => const _LaporanBody();
}

class _LaporanBody extends StatefulWidget {
  const _LaporanBody();

  @override
  State<_LaporanBody> createState() => _LaporanBodyState();
}

class _LaporanBodyState extends State<_LaporanBody> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  List<Antrian>? _rows;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final result = await antrianDataSource.list(const ListQuery(perPage: 2000));
    final filtered = result.data.where((a) {
      final d = a.waktuDaftar;
      return !d.isBefore(_range.start) && !d.isAfter(_range.end);
    }).toList();
    if (!mounted) return;
    setState(() {
      _rows = filtered;
      _loading = false;
    });
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _range,
    );
    if (picked == null) return;
    setState(() => _range = picked);
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    final rows = _rows ?? const <Antrian>[];
    final selesai = rows.where((r) => r.status == StatusAntrian.selesai).length;
    final dilewati =
        rows.where((r) => r.status == StatusAntrian.dilewati).length;
    final avgWait = _avgWaitMinutes(rows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border.all(color: theme.border),
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month, color: theme.colors.primary),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('dd MMM yyyy').format(_range.start)} — '
                '${DateFormat('dd MMM yyyy').format(_range.end)}',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.date_range, size: 16),
                label: const Text('Ubah rentang'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        StatWidget(
          stats: [
            Stat(
              label: 'Total antrian',
              value: '${rows.length}',
              icon: Icons.confirmation_number_outlined,
            ),
            Stat(
              label: 'Selesai',
              value: '$selesai',
              icon: Icons.check_circle_outline,
              color: theme.colors.success,
            ),
            Stat(
              label: 'Dilewati',
              value: '$dilewati',
              icon: Icons.skip_next,
              color: theme.colors.danger,
            ),
            Stat(
              label: 'Rata-rata tunggu',
              value: avgWait == null ? '-' : '$avgWait mnt',
              icon: Icons.timer_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border.all(color: theme.border),
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan per layanan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (rows.isEmpty)
                Text(
                  'Tidak ada data pada rentang ini.',
                  style: TextStyle(color: theme.textSecondary),
                )
              else
                ..._groupByLayanan(rows).entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.key,
                                style: TextStyle(color: theme.textPrimary),
                              ),
                            ),
                            Text(
                              '${e.value}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  int? _avgWaitMinutes(List<Antrian> rows) {
    final served = rows.where((r) =>
        r.waktuDipanggil != null && r.status == StatusAntrian.selesai);
    if (served.isEmpty) return null;
    final totalMs = served.fold<int>(0, (sum, r) {
      final diff = r.waktuDipanggil!.difference(r.waktuDaftar).inMilliseconds;
      return sum + (diff < 0 ? 0 : diff);
    });
    return (totalMs / served.length / 60000).round();
  }

  Map<String, int> _groupByLayanan(List<Antrian> rows) {
    final out = <String, int>{};
    for (final r in rows) {
      out[r.layanan.nama] = (out[r.layanan.nama] ?? 0) + 1;
    }
    final entries = out.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }
}
