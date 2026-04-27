import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/app_auth_state.dart';
import '../../data/lookup_cache.dart';
import '../../data/ticket_service.dart';
import '../../models/app_user.dart';
import '../../models/counter.dart' as models;
import '../../models/ticket.dart';

class CounterPage extends ConsumerStatefulWidget {
  const CounterPage({super.key});

  @override
  ConsumerState<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends ConsumerState<CounterPage> {
  final _ticketService = TicketService();
  bool _busy = false;

  Future<void> _wrap(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _callNext(AppUser user, models.Counter counter) {
    return _wrap(() async {
      final ticket = await _ticketService.callNext(
        counterId: counter.id,
        serviceIds: counter.serviceIds,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ticket == null
              ? 'Tidak ada antrian menunggu.'
              : 'Memanggil ${ticket.number}'),
        ),
      );
    });
  }

  Future<void> _skip(Ticket t) =>
      _wrap(() => _ticketService.skip(t.id));

  Future<void> _recall(Ticket t) => _wrap(() async {
        await _ticketService.recall(t.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Memanggil ulang ${t.number}')));
      });

  Future<void> _serve(Ticket t) async {
    final result = await showDialog<_ServeFormData>(
      context: context,
      builder: (_) => _ServeDialog(ticket: t),
    );
    if (result == null) return;
    await _wrap(() => _ticketService.serve(
          ticketId: t.id,
          customerName: result.name,
          customerPhone: result.phone,
          notes: result.notes,
        ));
  }

  Future<void> _transfer(Ticket t, models.Counter currentCounter) async {
    final candidates = LookupCache.instance.counters
        .where((c) =>
            c.id != currentCounter.id && c.serviceIds.contains(t.serviceId))
        .toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tidak ada loket lain yang melayani layanan ini.')),
      );
      return;
    }
    final target = await showDialog<models.Counter>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Transfer ke loket'),
        children: candidates
            .map(
              (c) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, c),
                child: Text(c.name),
              ),
            )
            .toList(),
      ),
    );
    if (target == null) return;
    await _wrap(() => _ticketService.transfer(
          ticketId: t.id,
          targetCounterId: target.id,
        ));
  }

  Future<void> _togglePause(AppUser user) => _wrap(() async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .set({'paused': !user.paused}, SetOptions(merge: true));
      });

  Future<void> _generateTestTicket(models.Counter counter) async {
    if (counter.serviceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loket belum punya layanan.')),
      );
      return;
    }
    final services = LookupCache.instance.services
        .where((s) => counter.serviceIds.contains(s.id))
        .toList();
    final svc = services.length == 1
        ? services.first
        : await showDialog(
            context: context,
            builder: (_) => SimpleDialog(
              title: const Text('Pilih layanan tiket tes'),
              children: services
                  .map(
                    (s) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, s),
                      child: Text(s.name),
                    ),
                  )
                  .toList(),
            ),
          );
    if (svc == null) return;
    await _wrap(() async {
      final t = await _ticketService.createTicket(svc.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tiket dibuat: ${t.number}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(appAuthStateProvider);
    return ListenableBuilder(
      listenable: auth,
      builder: (ctx, _) {
        final user = auth.user;
        if (user == null || user.counterId == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final counter = LookupCache.instance.counters
            .where((c) => c.id == user.counterId)
            .firstOrNull;
        if (counter == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.help_outline, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Loket Anda tidak ditemukan. Pilih ulang.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.go('/counter/select'),
                      child: const Text('Pilih Loket'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return _OperatorScaffold(
          user: user,
          counter: counter,
          busy: _busy,
          ticketStream: _ticketService.streamTodayTickets(
            counterId: counter.id,
            serviceIds: counter.serviceIds,
          ),
          onCallNext: () => _callNext(user, counter),
          onSkip: _skip,
          onServe: _serve,
          onRecall: _recall,
          onTransfer: (t) => _transfer(t, counter),
          onTogglePause: () => _togglePause(user),
          onGenerateTest: () => _generateTestTicket(counter),
        );
      },
    );
  }
}

class _OperatorScaffold extends StatelessWidget {
  final AppUser user;
  final models.Counter counter;
  final bool busy;
  final Stream<List<Ticket>> ticketStream;
  final Future<void> Function() onCallNext;
  final Future<void> Function(Ticket) onSkip;
  final Future<void> Function(Ticket) onServe;
  final Future<void> Function(Ticket) onRecall;
  final Future<void> Function(Ticket) onTransfer;
  final Future<void> Function() onTogglePause;
  final Future<void> Function() onGenerateTest;

  const _OperatorScaffold({
    required this.user,
    required this.counter,
    required this.busy,
    required this.ticketStream,
    required this.onCallNext,
    required this.onSkip,
    required this.onServe,
    required this.onRecall,
    required this.onTransfer,
    required this.onTogglePause,
    required this.onGenerateTest,
  });

  @override
  Widget build(BuildContext context) {
    final services = counter.serviceIds
        .map(LookupCache.instance.serviceName)
        .join(', ');
    return Scaffold(
      appBar: AppBar(
        title: Text(counter.name),
        actions: [
          IconButton(
            tooltip: 'Tiket Tes',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: busy ? null : onGenerateTest,
          ),
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/counter/profile'),
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: ticketStream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: ${snap.error}'),
              ),
            );
          }
          final tickets = snap.data ?? const [];
          final current = tickets
              .where((t) => t.status == TicketStatus.called)
              .firstOrNull;
          final waiting = tickets
              .where((t) => t.status == TicketStatus.waiting)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderInfo(user: user, services: services),
                  const SizedBox(height: 16),
                  _CurrentTicketCard(
                    ticket: current,
                    busy: busy,
                    onSkip: current == null ? null : () => onSkip(current),
                    onServe: current == null ? null : () => onServe(current),
                    onRecall: current == null ? null : () => onRecall(current),
                    onTransfer:
                        current == null ? null : () => onTransfer(current),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.campaign_outlined),
                          label: Text(
                            current != null
                                ? 'Selesaikan / Skip dulu'
                                : user.paused
                                    ? 'Anda sedang istirahat'
                                    : 'Panggil Antrian Berikutnya',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          onPressed: (busy || current != null || user.paused)
                              ? null
                              : onCallNext,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: Icon(user.paused
                            ? Icons.play_arrow
                            : Icons.pause_circle_outline),
                        label: Text(user.paused ? 'Lanjutkan' : 'Istirahat'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 16),
                        ),
                        onPressed: busy ? null : onTogglePause,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Antrian Menunggu (${waiting.length})',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  if (waiting.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Belum ada antrian menunggu.',
                            style: TextStyle(color: Colors.black54)),
                      ),
                    )
                  else
                    ...waiting.map((t) => _WaitingTile(ticket: t)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final AppUser user;
  final String services;
  const _HeaderInfo({required this.user, required this.services});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name.isEmpty ? user.email : user.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    services.isEmpty ? 'Tanpa layanan' : 'Layanan: $services',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (user.paused)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pause_circle_outline,
                        size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Text('Istirahat',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CurrentTicketCard extends StatelessWidget {
  final Ticket? ticket;
  final bool busy;
  final VoidCallback? onSkip;
  final VoidCallback? onServe;
  final VoidCallback? onRecall;
  final VoidCallback? onTransfer;

  const _CurrentTicketCard({
    required this.ticket,
    required this.busy,
    this.onSkip,
    this.onServe,
    this.onRecall,
    this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    if (ticket == null) {
      return Card(
        color: Colors.grey.shade100,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.hourglass_empty,
                    size: 36, color: Colors.black38),
                SizedBox(height: 6),
                Text('Belum ada antrian dipanggil',
                    style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      );
    }
    final t = ticket!;
    final svcName = LookupCache.instance.serviceName(t.serviceId);
    final calledAt = t.calledAt != null
        ? DateFormat('HH:mm', 'id_ID').format(t.calledAt!)
        : '-';
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.number,
                        style: const TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(svcName,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Dipanggil pukul $calledAt',
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (t.skipCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('Skip ${t.skipCount}×',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600)),
                      ),
                    if (t.recallCount > 0)
                      Text('Recall ${t.recallCount}×',
                          style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Selesai (Serve)'),
                  onPressed: busy ? null : onServe,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Panggil Ulang'),
                  onPressed: busy ? null : onRecall,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip'),
                  onPressed: busy ? null : onSkip,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Transfer'),
                  onPressed: busy ? null : onTransfer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingTile extends StatelessWidget {
  final Ticket ticket;
  const _WaitingTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final svc = LookupCache.instance.serviceName(ticket.serviceId);
    final time = ticket.queuedAt != null
        ? DateFormat('HH:mm', 'id_ID').format(ticket.queuedAt!)
        : '-';
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            ticket.number.split('-').first,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(ticket.number,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$svc · $time'),
        trailing: ticket.skipCount > 0
            ? Text('Skip ${ticket.skipCount}×',
                style: const TextStyle(color: Colors.orange))
            : null,
      ),
    );
  }
}

class _ServeFormData {
  final String? name;
  final String? phone;
  final String? notes;
  const _ServeFormData({this.name, this.phone, this.notes});
}

class _ServeDialog extends StatefulWidget {
  final Ticket ticket;
  const _ServeDialog({required this.ticket});

  @override
  State<_ServeDialog> createState() => _ServeDialogState();
}

class _ServeDialogState extends State<_ServeDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Selesaikan ${widget.ticket.number}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. HP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _ServeFormData(
              name: _name.text.trim().isEmpty ? null : _name.text.trim(),
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            ),
          ),
          child: const Text('Selesaikan'),
        ),
      ],
    );
  }
}
