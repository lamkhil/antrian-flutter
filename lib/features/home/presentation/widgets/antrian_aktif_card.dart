import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/features/home/presentation/widgets/_dash_card.dart';
import 'package:flutter/material.dart';

class AntrianAktifCard extends StatelessWidget {
  final List<Antrian> items;

  const AntrianAktifCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return DashCard(
      title: 'Antrian aktif',
      trailing: BadgeCard(
        '● Live',
        const Color(0xFFEAF3DE),
        const Color(0xFF27500A),
      ),
      child: Column(
        children: items.map((item) => _AntrianRow(item: item)).toList(),
      ),
    );
  }
}

class _AntrianRow extends StatelessWidget {
  final Antrian item;

  const _AntrianRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final loketLabel = item.loket?.nama ??
        (item.status == StatusAntrian.menunggu ? 'Menunggu' : '-');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              item.nomorAntrian,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  '${item.layanan.nama} · $loketLabel',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(item.status),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final StatusAntrian status;

  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      StatusAntrian.dipanggil => (
        'Dipanggil',
        const Color(0xFFEEF2FF),
        const Color(0xFF3C3489),
      ),
      StatusAntrian.menunggu => (
        'Menunggu',
        const Color(0xFFFAEEDA),
        const Color(0xFF633806),
      ),
      StatusAntrian.dilayani => (
        'Dilayani',
        const Color(0xFFE1F5EE),
        const Color(0xFF065F46),
      ),
      StatusAntrian.selesai => (
        'Selesai',
        const Color(0xFFEAF3DE),
        const Color(0xFF27500A),
      ),
      StatusAntrian.dilewati => (
        'Batal',
        const Color(0xFFFCEBEB),
        const Color(0xFF791F1F),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}
