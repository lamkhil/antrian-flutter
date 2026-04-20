import 'package:antrian/features/home/presentation/widgets/_dash_card.dart';
import 'package:flutter/material.dart';
import '../../application/home_state.dart';

class RingkasanLayananCard extends StatelessWidget {
  final List<RingkasanLayanan> items;

  const RingkasanLayananCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return DashCard(
      title: 'Ringkasan layanan',
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(),
          1: FixedColumnWidth(44),
          2: FixedColumnWidth(52),
          3: FixedColumnWidth(52),
        },
        children: [
          _headerRow(['Layanan', 'Total', 'Selesai', 'Tunggu']),
          ...items.map(
            (e) => TableRow(
              children: [
                _cell(e.nama, bold: true),
                _cell('${e.total}'),
                _cell('${e.selesai}', color: const Color(0xFF3B6D11)),
                _cell('${e.menunggu}', color: const Color(0xFF854F0B)),
              ],
            ),
          ),
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

  Widget _cell(String val, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        val,
        style: TextStyle(
          fontSize: 12,
          color:
              color ??
              (bold ? const Color(0xFF111827) : const Color(0xFF6B7280)),
          fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
}
