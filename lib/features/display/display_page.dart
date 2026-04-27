import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

import '../../data/lookup_cache.dart';
import '../../models/counter.dart' as models;
import '../../models/ticket.dart';

/// Public lobby display: live now-serving grid + waiting counts +
/// chime + Indonesian TTS for new calls.
///
/// Pass [zoneId] to scope the board to one zone (`/display/zone/:id`); leave
/// null to show every counter (`/display`).
class DisplayPage extends StatefulWidget {
  final String? zoneId;
  const DisplayPage({super.key, this.zoneId});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  late final Stream<List<Ticket>> _ticketStream;
  late final Stream<DateTime> _clock;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audio = AudioPlayer();
  final Set<String> _announcedKeys = {};
  final Map<String, _CounterCell> _highlight = {};
  Timer? _highlightTimer;

  /// Service IDs in the active zone, or null if no zone filter applied.
  Set<String>? get _zoneServiceIds {
    if (widget.zoneId == null) return null;
    return LookupCache.instance.services
        .where((s) => s.zoneId == widget.zoneId)
        .map((s) => s.id)
        .toSet();
  }

  /// Counters that serve at least one service in the active zone, or all
  /// counters when no zone filter is applied.
  List<models.Counter> get _counters {
    final all = LookupCache.instance.counters;
    final zoneSvc = _zoneServiceIds;
    if (zoneSvc == null) return all;
    return all
        .where((c) => c.serviceIds.any(zoneSvc.contains))
        .toList();
  }

  String? get _zoneName =>
      widget.zoneId == null ? null : LookupCache.instance.zoneName(widget.zoneId);

  @override
  void initState() {
    super.initState();
    _ticketStream = _streamTodayTickets();
    _clock = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
    _initTts();
    _audio.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1);
      await _tts.setPitch(1);
    } catch (_) {/* TTS unavailable on this platform — silent fallback */}
  }

  Stream<List<Ticket>> _streamTodayTickets() {
    final now = DateTime.now();
    final start =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    return FirebaseFirestore.instance
        .collection('tickets')
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Ticket.fromMap({...d.data(), 'id': d.id}))
            .toList());
  }

  /// Apply zone filter to a list of tickets.
  List<Ticket> _scoped(List<Ticket> tickets) {
    final zoneSvc = _zoneServiceIds;
    if (zoneSvc == null) return tickets;
    return tickets.where((t) => zoneSvc.contains(t.serviceId)).toList();
  }

  Map<String, Ticket> _activeByCounter(List<Ticket> tickets) {
    final out = <String, Ticket>{};
    for (final t in tickets) {
      if (t.status != TicketStatus.called) continue;
      if (t.counterId == null) continue;
      final existing = out[t.counterId!];
      if (existing == null) {
        out[t.counterId!] = t;
      } else {
        final a = t.calledAt ?? DateTime(2000);
        final b = existing.calledAt ?? DateTime(2000);
        if (a.isAfter(b)) out[t.counterId!] = t;
      }
    }
    return out;
  }

  Map<String, int> _waitingByService(List<Ticket> tickets) {
    final out = <String, int>{};
    for (final t in tickets) {
      if (t.status != TicketStatus.waiting) continue;
      out[t.serviceId] = (out[t.serviceId] ?? 0) + 1;
    }
    return out;
  }

  void _maybeAnnounce(Map<String, Ticket> active) {
    for (final entry in active.entries) {
      final ticket = entry.value;
      // Re-announce on each recall by including recallCount in the key.
      final key = '${ticket.id}:${ticket.recallCount}';
      if (_announcedKeys.contains(key)) continue;
      _announcedKeys.add(key);
      final counter = LookupCache.instance.counters
          .where((c) => c.id == entry.key)
          .firstOrNull;
      if (counter == null) continue;
      _announce(ticket, counter.name);
      _flashHighlight(entry.key, ticket);
    }
  }

  Future<void> _announce(Ticket ticket, String counterName) async {
    final spoken = ticket.number.replaceAll('-', ' ');
    final phrase = 'Nomor antrian $spoken, silakan menuju $counterName.';
    try {
      await _tts.stop();
      await _audio.stop();
      await _audio.play(AssetSource('sounds/chime.wav'));
      // Wait for the chime to finish (~1s) before speaking.
      await _audio.onPlayerComplete.first
          .timeout(const Duration(seconds: 2), onTimeout: () {});
    } catch (_) {/* asset missing or audio backend offline — skip */}
    try {
      await _tts.speak(phrase);
    } catch (_) {/* TTS failure — UI still works */}
  }

  void _flashHighlight(String counterId, Ticket ticket) {
    setState(() {
      _highlight[counterId] = _CounterCell(ticket: ticket, highlight: true);
    });
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() {
        for (final k in _highlight.keys.toList()) {
          _highlight[k] =
              _CounterCell(ticket: _highlight[k]!.ticket, highlight: false);
        }
      });
    });
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _tts.stop();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final counters = _counters;
    final zoneName = _zoneName;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: StreamBuilder<List<Ticket>>(
          stream: _ticketStream,
          builder: (ctx, snap) {
            final tickets = _scoped(snap.data ?? const <Ticket>[]);
            final active = _activeByCounter(tickets);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _maybeAnnounce(active));
            final waiting = _waitingByService(tickets);
            return Column(
              children: [
                _DisplayHeader(clock: _clock, zoneName: zoneName),
                Expanded(
                  child: counters.isEmpty
                      ? Center(
                          child: Text(
                            zoneName != null
                                ? 'Tidak ada loket di zona $zoneName'
                                : 'Belum ada loket terdaftar',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 22),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 420,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.6,
                            ),
                            itemCount: counters.length,
                            itemBuilder: (ctx, i) {
                              final c = counters[i];
                              final t = active[c.id];
                              final highlight =
                                  _highlight[c.id]?.highlight ?? false;
                              return _CounterTile(
                                counter: c,
                                ticket: t,
                                highlight: highlight,
                              );
                            },
                          ),
                        ),
                ),
                _WaitingBar(waiting: waiting),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CounterCell {
  final Ticket ticket;
  final bool highlight;
  const _CounterCell({required this.ticket, required this.highlight});
}

class _DisplayHeader extends StatelessWidget {
  final Stream<DateTime> clock;
  final String? zoneName;
  const _DisplayHeader({required this.clock, this.zoneName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111B30),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.tv_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Papan Antrian',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              if (zoneName != null)
                Text(
                  'Zona $zoneName',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const Spacer(),
          StreamBuilder<DateTime>(
            stream: clock,
            initialData: DateTime.now(),
            builder: (ctx, snap) {
              final t = snap.data ?? DateTime.now();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('HH:mm:ss', 'id_ID').format(t),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM y', 'id_ID').format(t),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  final models.Counter counter;
  final Ticket? ticket;
  final bool highlight;

  const _CounterTile({
    required this.counter,
    required this.ticket,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final empty = ticket == null;
    final highlightColor = Colors.amber.shade300;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: empty ? const Color(0xFF182338) : const Color(0xFF1E2A47),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? highlightColor
              : Colors.white.withValues(alpha: 0.05),
          width: highlight ? 3 : 1,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: highlightColor.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                counter.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              if (!empty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                      SizedBox(width: 4),
                      Text(
                        'MELAYANI',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              empty ? '—' : ticket!.number,
              style: TextStyle(
                color: empty
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white,
                fontSize: empty ? 56 : 88,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                height: 1,
              ),
            ),
          ),
          const Spacer(),
          if (!empty)
            Text(
              LookupCache.instance.serviceName(ticket!.serviceId),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Text(
              counter.serviceIds.isEmpty
                  ? 'Tidak ada layanan'
                  : counter.serviceIds
                      .map(LookupCache.instance.serviceName)
                      .join(' · '),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _WaitingBar extends StatelessWidget {
  final Map<String, int> waiting;
  const _WaitingBar({required this.waiting});

  @override
  Widget build(BuildContext context) {
    if (waiting.isEmpty) {
      return Container(
        height: 56,
        color: const Color(0xFF111B30),
        alignment: Alignment.center,
        child: Text(
          'Tidak ada antrian menunggu saat ini',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 14,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111B30),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top, color: Colors.white60, size: 18),
          const SizedBox(width: 8),
          const Text(
            'Antrian menunggu',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: waiting.entries.map((e) {
                  final svc = LookupCache.instance.serviceName(e.key);
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          svc,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${e.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
