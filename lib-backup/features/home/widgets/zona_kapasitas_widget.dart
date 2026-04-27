import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import '../../../data/models/zona.dart';
import '../../zona/zona_resource.dart';

/// Progress bar kapasitas per zona — antrian aktif / kapasitas.
class ZonaKapasitasWidget extends DashboardWidget {
  const ZonaKapasitasWidget({super.key});

  @override int get columnSpan => 12;

  @override
  Widget build(BuildContext context) => const _Body();
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  List<Zona>? _zones;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await zonaDataSource.list(const ListQuery(perPage: 100));
    if (!mounted) return;
    setState(() => _zones = r.data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard, size: 18, color: theme.colors.primary),
              const SizedBox(width: 8),
              Text(
                'Kapasitas per zona',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_zones == null)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_zones!.isEmpty)
            Text(
              'Belum ada zona terdaftar.',
              style: TextStyle(color: theme.textSecondary),
            )
          else
            ..._zones!.map((z) {
              final pct = z.kapasitas == 0
                  ? 0.0
                  : (z.antrianAktif / z.kapasitas).clamp(0.0, 1.0);
              final Color barColor = pct < 0.6
                  ? theme.colors.success
                  : pct < 0.85
                      ? theme.colors.warning
                      : theme.colors.danger;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            z.nama,
                            style: TextStyle(color: theme.textPrimary),
                          ),
                        ),
                        Text(
                          '${z.antrianAktif} / ${z.kapasitas}',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: theme.border,
                        valueColor: AlwaysStoppedAnimation(barColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
