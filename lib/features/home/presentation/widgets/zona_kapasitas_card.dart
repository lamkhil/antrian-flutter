import 'package:antrian/data/models/zona.dart';
import 'package:antrian/features/home/presentation/widgets/_dash_card.dart';
import 'package:flutter/material.dart';

class ZonaKapasitasCard extends StatelessWidget {
  final List<Zona> zones;

  const ZonaKapasitasCard({super.key, required this.zones});

  @override
  Widget build(BuildContext context) {
    final aktif = zones.where((z) => z.antrianAktif > 0).length;

    return DashCard(
      title: 'Kapasitas zona',
      trailing: BadgeCard(
        '$aktif zona aktif',
        const Color(0xFFFAEEDA),
        const Color(0xFF633806),
      ),
      child: Column(children: zones.map((z) => _ZonaRow(zona: z)).toList()),
    );
  }
}

class _ZonaRow extends StatelessWidget {
  final Zona zona;

  const _ZonaRow({required this.zona});

  double get _persen {
    if (zona.kapasitas == 0) return 0;
    return zona.antrianAktif / zona.kapasitas;
  }

  Color get _warna {
    if (_persen >= 0.95) return const Color(0xFFE24B4A);
    if (_persen >= 0.85) return const Color(0xFFEF9F27);
    return const Color(0xFF6366F1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                zona.nama,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              Text(
                '${zona.antrianAktif}/${zona.kapasitas}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _persen.clamp(0, 1),
              minHeight: 4,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(_warna),
            ),
          ),
        ],
      ),
    );
  }
}
