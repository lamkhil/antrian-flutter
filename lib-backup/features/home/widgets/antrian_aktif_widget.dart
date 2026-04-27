import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:intl/intl.dart';
import '../../../data/models/antrian.dart';
import '../../antrian/antrian_resource.dart';

class AntrianAktifWidget extends DashboardWidget {
  const AntrianAktifWidget({super.key});

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
  List<Antrian>? _rows;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await antrianDataSource.list(const ListQuery(
      perPage: 10,
      filters: {'status': 'menunggu'},
      sortBy: 'waktuDaftar',
    ));
    if (!mounted) return;
    setState(() => _rows = result.data);
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
              Icon(Icons.hourglass_empty, color: theme.colors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Antrian menunggu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_rows == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_rows!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tidak ada antrian menunggu.',
                style: TextStyle(color: theme.textSecondary),
              ),
            )
          else
            ..._rows!.take(6).map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a.nomorAntrian,
                          style: TextStyle(
                            color: theme.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${a.nama} · ${a.layanan.nama}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: theme.textPrimary),
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(a.waktuDaftar),
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
