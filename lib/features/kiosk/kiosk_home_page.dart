import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/kiosk_session.dart';
import '../../data/lookup_cache.dart';
import '../../data/ticket_service.dart';
import '../../models/kiosk.dart';
import '../../models/service.dart' as models;
import '../../models/ticket.dart';

class KioskHomePage extends StatefulWidget {
  const KioskHomePage({super.key});

  @override
  State<KioskHomePage> createState() => _KioskHomePageState();
}

class _KioskHomePageState extends State<KioskHomePage> {
  final _ticketService = TicketService();
  Kiosk? _kiosk;
  bool _checking = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final id = await KioskSession.instance.loadDeviceId();
    if (id == null) {
      if (mounted) context.go('/kiosk/setup');
      return;
    }
    final kiosk = await KioskSession.instance.resolve(id);
    if (kiosk == null) {
      if (mounted) context.go('/kiosk/setup');
      return;
    }
    if (!mounted) return;
    setState(() {
      _kiosk = kiosk;
      _checking = false;
    });
  }

  Future<void> _issue(models.Service service) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ticket = await _ticketService.createTicket(service.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _TicketSuccessScreen(ticket: ticket, service: service),
          fullscreenDialog: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil tiket: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final services = LookupCache.instance.services;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _Header(kiosk: _kiosk!),
            Expanded(
              child: services.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada layanan tersedia',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Pilih Layanan',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sentuh kartu layanan untuk mengambil nomor antrian.',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 280,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1,
                              ),
                              itemCount: services.length,
                              itemBuilder: (ctx, i) {
                                final svc = services[i];
                                return _ServiceCard(
                                  service: svc,
                                  busy: _busy,
                                  onTap: () => _issue(svc),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  final Kiosk kiosk;
  const _Header({required this.kiosk});

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  late final Stream<DateTime> _clock = Stream.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade300.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.print_outlined,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.kiosk.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Device ID: ${widget.kiosk.deviceId}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<DateTime>(
            stream: _clock,
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
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    DateFormat('EEEE, d MMM y', 'id_ID').format(t),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Reset perangkat',
            icon: Icon(Icons.settings_outlined,
                color: Colors.white.withValues(alpha: 0.5)),
            onPressed: () async {
              await KioskSession.instance.clear();
              if (context.mounted) context.go('/kiosk/setup');
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final models.Service service;
  final bool busy;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.busy,
    required this.onTap,
  });

  String get _badge {
    final code = (service.code ?? '').trim();
    if (code.isNotEmpty) return code.toUpperCase();
    return service.name.isEmpty ? '#' : service.name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _badge,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3730A3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.confirmation_number_outlined,
                      size: 16, color: Colors.black45),
                  SizedBox(width: 4),
                  Text('Ambil tiket',
                      style: TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketSuccessScreen extends StatefulWidget {
  final Ticket ticket;
  final models.Service service;

  const _TicketSuccessScreen({required this.ticket, required this.service});

  @override
  State<_TicketSuccessScreen> createState() => _TicketSuccessScreenState();
}

class _TicketSuccessScreenState extends State<_TicketSuccessScreen> {
  static const _autoClose = Duration(seconds: 12);
  late int _remaining;
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _remaining = _autoClose.inSeconds;
    _ticker = Stream.periodic(const Duration(seconds: 1), (i) {
      return _autoClose.inSeconds - i - 1;
    }).take(_autoClose.inSeconds);
    _ticker.listen((n) {
      if (!mounted) return;
      setState(() => _remaining = n);
      if (n <= 0 && mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle,
                    color: Colors.greenAccent.shade400, size: 64),
                const SizedBox(height: 12),
                const Text(
                  'Antrian Anda',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    widget.ticket.number,
                    style: const TextStyle(
                      fontSize: 88,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.service.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Silakan menunggu giliran Anda di layar antrian.',
                  style: TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.check),
                  label: const Text('Selesai'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Otomatis kembali dalam ${_remaining}s',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
