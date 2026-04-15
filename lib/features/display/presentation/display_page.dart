import 'package:antrian/data/models/antrian.dart';
import 'package:antrian/data/models/loket.dart';
import 'package:antrian/features/display/application/display_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DisplayPage extends ConsumerWidget {
  final String zonaId;
  const DisplayPage({super.key, required this.zonaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(displayDataProvider(zonaId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: stream.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (e, _) => Center(
            child: Text(
              'Gagal memuat data:\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (data) => _Body(data: data),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final DisplayData data;
  const _Body({required this.data});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Column(
      children: [
        _Header(title: d.zona?.nama ?? 'Zona', subtitle: d.zona?.kode ?? ''),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _LoketGrid(data: d)),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: _AntreanMenungguList(items: d.antrianMenunggu),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────

class _Header extends StatefulWidget {
  final String title;
  final String subtitle;
  const _Header({required this.title, required this.subtitle});

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  DateTime _now = DateTime.now();
  late final Stream<DateTime> _clock;

  @override
  void initState() {
    super.initState();
    _clock = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
    _clock.listen((t) {
      if (mounted) setState(() => _now = t);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_now);
    final jam = DateFormat('HH:mm:ss').format(_now);
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (widget.subtitle.isNotEmpty)
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFC7D2FE),
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                jam,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                tanggal,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFC7D2FE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Grid loket ────────────────────────────────────────────

class _LoketGrid extends StatelessWidget {
  final DisplayData data;
  const _LoketGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.loketList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada loket di zona ini',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    return GridView.count(
      crossAxisCount: data.loketList.length <= 3 ? data.loketList.length : 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: data.loketList
          .map(
            (l) => _LoketCard(
              loket: l,
              current: data.currentAt(l.id),
            ),
          )
          .toList(),
    );
  }
}

class _LoketCard extends StatelessWidget {
  final Loket loket;
  final Antrian? current;
  const _LoketCard({required this.loket, required this.current});

  @override
  Widget build(BuildContext context) {
    final aktif = current != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: aktif ? const Color(0xFF1E293B) : const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: aktif ? const Color(0xFF6366F1) : const Color(0xFF1F2937),
          width: aktif ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: aktif
                      ? const Color(0xFF22D3EE)
                      : const Color(0xFF4B5563),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loket.nama,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                loket.kode,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const Spacer(),
          if (aktif)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sedang dilayani',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: Color(0xFF22D3EE),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  current!.nomorAntrian,
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'monospace',
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  current!.layanan.nama,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFCBD5E1),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loket.status.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '—',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                    fontFamily: 'monospace',
                    height: 1,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Daftar menunggu ───────────────────────────────────────

class _AntreanMenungguList extends StatelessWidget {
  final List<Antrian> items;
  const _AntreanMenungguList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Antrean menunggu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF22D3EE),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 0.5, color: Color(0xFF1F2937)),
          const SizedBox(height: 4),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada antrean',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 0.5,
                      color: Color(0xFF1F2937),
                    ),
                    itemBuilder: (ctx, i) {
                      final a = items[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                a.nomorAntrian,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF22D3EE),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                a.layanan.nama,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFCBD5E1),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
