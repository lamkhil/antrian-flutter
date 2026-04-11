import 'package:antrian/features/home/presentation/widgets/_dash_card.dart';
import 'package:flutter/material.dart';
import '../../application/home_state.dart';

class ZonaKapasitasCard extends StatelessWidget {
  final List<ZonaItem> zones;

  const ZonaKapasitasCard({super.key, required this.zones});

  @override
  Widget build(BuildContext context) {
    final aktif = zones.where((z) => z.terisi > 0).length;

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
  final ZonaItem zona;

  const _ZonaRow({required this.zona});

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
                '${zona.terisi}/${zona.kapasitas}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: zona.persen,
              minHeight: 4,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(zona.warna),
            ),
          ),
        ],
      ),
    );
  }
}
