import 'package:antrian/features/home/presentation/widgets/_dash_card.dart';
import 'package:flutter/material.dart';

class WaktuTungguCard extends StatelessWidget {
  final int menitRata;

  const WaktuTungguCard({super.key, required this.menitRata});

  // Data bar chart 7 hari (dummy — ganti dengan data real)
  static const _bars = [0.40, 0.65, 0.80, 0.55, 0.70, 0.50, 0.45];
  static const _labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    return DashCard(
      title: 'Rata-rata waktu tunggu',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$menitRata',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const TextSpan(
                  text: ' menit',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '↓ 3 menit lebih cepat dari kemarin',
            style: TextStyle(fontSize: 11, color: Color(0xFF3B6D11)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 72,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_bars.length, (i) {
                final isToday = i == _bars.length - 2; // Sabtu = hari ini
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: _bars[i],
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday
                                    ? const Color(0xFF6366F1)
                                    : const Color(0xFFCECBF6),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: isToday
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF9CA3AF),
                            fontWeight: isToday
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
