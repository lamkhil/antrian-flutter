import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Stat overview: total antrian hari ini, sedang dilayani, selesai.
class RingkasanStatWidget extends DashboardWidget {
  const RingkasanStatWidget({super.key});

  @override int get columnSpan => 12;

  @override
  Widget build(BuildContext context) =>
      const _Async(); // fetch in StatefulWidget wrapper
}

class _Async extends StatefulWidget {
  const _Async();

  @override
  State<_Async> createState() => _AsyncState();
}

class _AsyncState extends State<_Async> {
  int _total = 0, _dilayani = 0, _selesai = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final snap = await FirebaseFirestore.instance
        .collection('antrians')
        .where('waktuDaftar',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .get();
    var total = 0, dilayani = 0, selesai = 0;
    for (final d in snap.docs) {
      total++;
      final status = d.data()['status'];
      if (status == 'dilayani') dilayani++;
      if (status == 'selesai') selesai++;
    }
    if (!mounted) return;
    setState(() {
      _total = total;
      _dilayani = dilayani;
      _selesai = selesai;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    if (!_loaded) {
      return Container(
        height: 110,
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.borderRadius),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return StatWidget(
      stats: [
        Stat(
          label: 'Antrian hari ini',
          value: '$_total',
          icon: Icons.confirmation_number_outlined,
        ),
        Stat(
          label: 'Sedang dilayani',
          value: '$_dilayani',
          icon: Icons.support_agent,
          color: theme.colors.info,
        ),
        Stat(
          label: 'Selesai',
          value: '$_selesai',
          icon: Icons.check_circle_outline,
          color: theme.colors.success,
        ),
      ],
    );
  }
}
