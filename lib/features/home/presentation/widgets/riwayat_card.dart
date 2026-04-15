import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/features/home/presentation/widgets/_dash_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'antrian_aktif_card.dart' show StatusBadge;

class RiwayatCard extends StatelessWidget {
  final List<Antrian> items;

  const RiwayatCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm');
    return DashCard(
      title: 'Transaksi terbaru',
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(64),
          1: FlexColumnWidth(),
          2: FixedColumnWidth(48),
          3: FixedColumnWidth(72),
        },
        children: [
          _headerRow(['No.', 'Layanan', 'Waktu', 'Status']),
          ...items.map((e) {
            final t = e.waktuSelesai ?? e.waktuDipanggil ?? e.waktuDaftar;
            return TableRow(
              children: [
                _cell(e.nomorAntrian, bold: true),
                _cell(e.layanan.nama),
                _cell(fmt.format(t)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: StatusBadge(e.status),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  TableRow _headerRow(List<String> cols) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      children: cols
          .map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                c,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _cell(String val, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        val,
        style: TextStyle(
          fontSize: 12,
          color: bold ? const Color(0xFF111827) : const Color(0xFF6B7280),
          fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
}
