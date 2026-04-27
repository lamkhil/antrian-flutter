import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Bar chart: jumlah antrian 7 hari terakhir.
class GrafikMingguanWidget extends DashboardWidget {
  const GrafikMingguanWidget({super.key});

  @override int get columnSpan => 6;

  @override
  Widget build(BuildContext context) => const _Body();
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  List<ChartPoint>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final snap = await FirebaseFirestore.instance
        .collection('antrians')
        .where('waktuDaftar',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .get();

    final buckets = <String, int>{};
    for (var i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      buckets[DateFormat('EEE', 'id_ID').format(d)] = 0;
    }
    for (final doc in snap.docs) {
      final dt = (doc.data()['waktuDaftar'] as Timestamp).toDate();
      final key = DateFormat('EEE', 'id_ID').format(dt);
      if (buckets.containsKey(key)) {
        buckets[key] = buckets[key]! + 1;
      }
    }
    if (!mounted) return;
    setState(() => _data = buckets.entries
        .map((e) => ChartPoint(e.key, e.value.toDouble()))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      final theme = FilamentThemeScope.of(context);
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.borderRadius),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return ChartWidget(
      title: 'Antrian 7 hari terakhir',
      subtitle: 'Total tiket per hari',
      data: _data!,
    );
  }
}
