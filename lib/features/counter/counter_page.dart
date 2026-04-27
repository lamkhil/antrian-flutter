import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/app_auth_state.dart';
import '../../data/lookup_cache.dart';
import '../../data/ticket_service.dart';
import '../../models/app_user.dart';
import '../../models/counter.dart' as models;
import '../../models/ticket.dart';
import '_widgets.dart';

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
      if (mounted) ErrorView.showAsSnackBar(context, e);
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
          content: Text(
            ticket == null
                ? 'Tidak ada antrian menunggu.'
                : 'Memanggil ${ticket.number}',
          ),
        ),
      );
    });
  }

  /// Skip-flow: dialog 2 pilihan — Kembalikan / Buang.
  Future<void> _skip(Ticket t) async {
    final choice = await showDialog<_SkipChoice>(
      context: context,
      builder: (_) => _SkipChoiceDialog(ticket: t),
    );
    if (choice == null) return;
    switch (choice) {
      case _SkipChoice.requeue:
        await _wrap(() async {
          await _ticketService.skip(t.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${t.number} dikembalikan ke urutan terakhir'),
            ),
          );
        });
        break;
      case _SkipChoice.cancel:
        await _wrap(() async {
          await _ticketService.cancel(t.id);
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${t.number} dibuang')));
        });
        break;
    }
  }

  Future<void> _recall(Ticket t) => _wrap(() async {
    await _ticketService.recall(t.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Memanggil ulang ${t.number}')));
  });

  Future<void> _serve(Ticket t) async {
    final result = await showDialog<_ServeFormData>(
      context: context,
      builder: (_) => _ServeDialog(ticket: t),
    );
    if (result == null) return;
    await _wrap(
      () => _ticketService.serve(
        ticketId: t.id,
        customerName: result.name,
        customerPhone: result.phone,
        notes: result.notes,
      ),
    );
  }

  Future<void> _transfer(Ticket t, models.Counter currentCounter) async {
    final candidates = LookupCache.instance.counters
        .where(
          (c) =>
              c.id != currentCounter.id && c.serviceIds.contains(t.serviceId),
        )
        .toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada loket lain yang melayani layanan ini.'),
        ),
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
    await _wrap(
      () => _ticketService.transfer(ticketId: t.id, targetCounterId: target.id),
    );
  }

  Future<void> _togglePause(AppUser user) => _wrap(() async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).set({
      'paused': !user.paused,
    }, SetOptions(merge: true));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tiket dibuat: ${t.number}')));
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
          return const CounterShell(
            child: Center(
              child: CircularProgressIndicator(color: kAccentLight),
            ),
          );
        }
        final counter = LookupCache.instance.counters
            .where((c) => c.id == user.counterId)
            .firstOrNull;
        if (counter == null) {
          return CounterShell(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 48,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Loket Anda tidak ditemukan. Pilih ulang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Pilih Loket',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => context.go('/counter/select'),
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
          onRetry: () => setState(() {}),
        );
      },
    );
  }
}

// ── Operator scaffold ────────────────────────────────────────────────────

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
  final VoidCallback onRetry;

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
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final services = counter.serviceIds
        .map(LookupCache.instance.serviceName)
        .join(', ');

    return CounterShell(
      child: Column(
        children: [
          _Topbar(
            counterName: counter.name,
            busy: busy,
            onGenerateTest: onGenerateTest,
            onProfile: () => context.go('/counter/profile'),
            onLogout: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          Expanded(
            child: StreamBuilder<List<Ticket>>(
              stream: ticketStream,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kAccentLight),
                  );
                }
                if (snap.hasError) {
                  return ErrorView(error: snap.error!, onRetry: onRetry);
                }
                final tickets = snap.data ?? const [];
                final current = tickets
                    .where((t) => t.status == TicketStatus.called)
                    .firstOrNull;
                final waiting = tickets
                    .where((t) => t.status == TicketStatus.waiting)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeaderInfo(user: user, services: services),
                          const SizedBox(height: 16),
                          _CurrentTicketCard(
                            ticket: current,
                            busy: busy,
                            onSkip: current == null
                                ? null
                                : () => onSkip(current),
                            onServe: current == null
                                ? null
                                : () => onServe(current),
                            onRecall: current == null
                                ? null
                                : () => onRecall(current),
                            onTransfer: current == null
                                ? null
                                : () => onTransfer(current),
                          ),
                          const SizedBox(height: 16),
                          _CallNextRow(
                            user: user,
                            busy: busy,
                            current: current,
                            onCallNext: onCallNext,
                            onTogglePause: onTogglePause,
                          ),
                          const SizedBox(height: 28),
                          _QueueSection(
                            waiting: waiting,
                            serviceIds: counter.serviceIds,
                          ),
                        ],
                      ),
                    ),
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

// ── Topbar (replace AppBar) ──────────────────────────────────────────────

class _Topbar extends StatelessWidget {
  final String counterName;
  final bool busy;
  final Future<void> Function() onGenerateTest;
  final VoidCallback onProfile;
  final Future<void> Function() onLogout;
  const _Topbar({
    required this.counterName,
    required this.busy,
    required this.onGenerateTest,
    required this.onProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
      child: Row(
        children: [
          // Brand badge ala login
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: kAccentStart.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kAccentStart.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 3,
                  backgroundColor: Color(0xFF818CF8),
                ),
                const SizedBox(width: 6),
                Text(
                  counterName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kAccentLight,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Tiket Tes',
            color: Colors.white70,
            hoverColor: Colors.white.withValues(alpha: 0.06),
            icon: const Icon(Icons.add_circle_outline),
            onPressed: busy ? null : onGenerateTest,
          ),
          IconButton(
            tooltip: 'Profil',
            color: Colors.white70,
            hoverColor: Colors.white.withValues(alpha: 0.06),
            icon: const Icon(Icons.person_outline),
            onPressed: onProfile,
          ),
          IconButton(
            tooltip: 'Keluar',
            color: Colors.white70,
            hoverColor: Colors.white.withValues(alpha: 0.06),
            icon: const Icon(Icons.logout),
            onPressed: () => onLogout(),
          ),
        ],
      ),
    );
  }
}

// ── Header info (user + services + paused badge) ─────────────────────────

class _HeaderInfo extends StatelessWidget {
  final AppUser user;
  final String services;
  const _HeaderInfo({required this.user, required this.services});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kAccentStart.withValues(alpha: 0.2),
            child: const Icon(
              Icons.person_outline,
              color: kAccentLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? user.email : user.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  services.isEmpty ? 'Tanpa layanan' : 'Layanan: $services',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (user.paused)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pause_circle_outline,
                    size: 14,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Istirahat',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Current ticket card (called) ─────────────────────────────────────────

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
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: Colors.white24,
              ),
              SizedBox(height: 8),
              Text(
                'Belum ada antrian dipanggil',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    final t = ticket!;
    final svcName = LookupCache.instance.serviceName(t.serviceId);
    final calledAt = t.calledAt != null
        ? DateFormat('HH:mm', 'id_ID').format(t.calledAt!)
        : '-';
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kAccentStart.withValues(alpha: 0.18),
                kAccentEnd.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: kAccentStart.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: kAccentStart.withValues(alpha: 0.20),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
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
                        const Text(
                          'SEDANG DIPANGGIL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kAccentLight,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.number,
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          svcName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dipanggil pukul $calledAt',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (t.skipCount > 0)
                        CountChip(
                          label: 'Skip ${t.skipCount}×',
                          color: Colors.orange,
                        ),
                      if (t.skipCount > 0 && t.recallCount > 0)
                        const SizedBox(height: 6),
                      if (t.recallCount > 0)
                        CountChip(
                          label: 'Recall ${t.recallCount}×',
                          color: kAccentLight,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GradientButton(
                    label: 'Selesai',
                    icon: Icons.check_rounded,
                    onPressed: busy ? null : onServe,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    fontSize: 14,
                  ),
                  GhostButton(
                    label: 'Panggil Ulang',
                    icon: Icons.replay_rounded,
                    onPressed: busy ? null : onRecall,
                  ),
                  GhostButton(
                    label: 'Skip',
                    icon: Icons.skip_next_rounded,
                    color: Colors.orange,
                    onPressed: busy ? null : onSkip,
                  ),
                  GhostButton(
                    label: 'Transfer',
                    icon: Icons.swap_horiz_rounded,
                    onPressed: busy ? null : onTransfer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Call-next + pause toggle row ─────────────────────────────────────────

class _CallNextRow extends StatelessWidget {
  final AppUser user;
  final bool busy;
  final Ticket? current;
  final Future<void> Function() onCallNext;
  final Future<void> Function() onTogglePause;
  const _CallNextRow({
    required this.user,
    required this.busy,
    required this.current,
    required this.onCallNext,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    final paused = user.paused;
    final blocked = busy || current != null || paused;
    final label = current != null
        ? 'Selesaikan / Skip dulu'
        : paused
        ? 'Anda sedang istirahat'
        : 'Panggil Antrian Berikutnya';

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: GradientButton(
              label: label,
              icon: Icons.campaign_rounded,
              onPressed: blocked ? null : onCallNext,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 60,
          child: GhostButton(
            label: paused ? 'Lanjutkan' : 'Istirahat',
            icon: paused
                ? Icons.play_arrow_rounded
                : Icons.pause_circle_outline_rounded,
            color: paused ? kAccentLight : Colors.orange,
            onPressed: busy ? null : onTogglePause,
          ),
        ),
      ],
    );
  }
}

// ── Queue section (tabbed: Menunggu / Riwayat) ───────────────────────────

enum _QueueTab { menunggu, riwayat }

class _QueueSection extends StatefulWidget {
  final List<Ticket> waiting;
  final List<String> serviceIds;

  const _QueueSection({
    required this.waiting,
    required this.serviceIds,
  });

  @override
  State<_QueueSection> createState() => _QueueSectionState();
}

class _QueueSectionState extends State<_QueueSection> {
  _QueueTab _tab = _QueueTab.menunggu;
  DateTime _historyDate = DateTime.now();
  final _ticketService = TicketService();

  bool get _isToday {
    final now = DateTime.now();
    return _historyDate.year == now.year &&
        _historyDate.month == now.month &&
        _historyDate.day == now.day;
  }

  String get _historyDateLabel => _isToday
      ? 'Hari ini'
      : DateFormat('d MMM yyyy', 'id_ID').format(_historyDate);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _historyDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kAccentStart,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1438),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1A1438),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _historyDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TabSwitcher(
          tab: _tab,
          waitingCount: widget.waiting.length,
          onChange: (t) => setState(() => _tab = t),
        ),
        const SizedBox(height: 14),
        if (_tab == _QueueTab.menunggu)
          _buildWaiting()
        else
          _buildHistory(),
      ],
    );
  }

  Widget _buildWaiting() {
    if (widget.waiting.isEmpty) {
      return GlassCard(
        padding:
            const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_bottom_rounded,
                  color: Colors.white24, size: 32),
              SizedBox(height: 6),
              Text(
                'Belum ada antrian menunggu',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final t in widget.waiting) ...[
          _WaitingTile(ticket: t),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Material(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 14, color: kAccentLight),
                      const SizedBox(width: 8),
                      Text(
                        _historyDateLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.expand_more_rounded,
                          size: 16, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            ),
            if (!_isToday) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Reset ke hari ini',
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Colors.white54),
                onPressed: () =>
                    setState(() => _historyDate = DateTime.now()),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Ticket>>(
          stream: _ticketService.streamHistory(
            serviceIds: widget.serviceIds,
            date: _historyDate,
          ),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: CircularProgressIndicator(color: kAccentLight),
                ),
              );
            }
            if (snap.hasError) {
              return ErrorView(
                error: snap.error!,
                onRetry: () => setState(() {}),
              );
            }
            final tickets = snap.data ?? const <Ticket>[];
            if (tickets.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.symmetric(
                    vertical: 28, horizontal: 16),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded,
                          color: Colors.white24, size: 32),
                      SizedBox(height: 6),
                      Text(
                        'Belum ada riwayat untuk tanggal ini',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }
            final served = tickets
                .where((t) => t.status == TicketStatus.done)
                .length;
            final cancelled = tickets
                .where((t) => t.status == TicketStatus.cancelled)
                .length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _StatPill(
                      label: 'Selesai',
                      value: '$served',
                      color: const Color(0xFF34D399),
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      label: 'Dibuang',
                      value: '$cancelled',
                      color: const Color(0xFFFC8181),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final t in tickets) ...[
                  _HistoryTile(ticket: t),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final _QueueTab tab;
  final int waitingCount;
  final ValueChanged<_QueueTab> onChange;
  const _TabSwitcher({
    required this.tab,
    required this.waitingCount,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Menunggu',
              badge: '$waitingCount',
              active: tab == _QueueTab.menunggu,
              onTap: () => onChange(_QueueTab.menunggu),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TabButton(
              label: 'Riwayat',
              icon: Icons.history_rounded,
              active: tab == _QueueTab.riwayat,
              onTap: () => onChange(_QueueTab.riwayat),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final String? badge;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.badge,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active
                ? const LinearGradient(
                    colors: [kAccentStart, kAccentEnd],
                  )
                : null,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: kAccentStart.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 14,
                    color: active ? Colors.white : Colors.white54),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Ticket ticket;
  const _HistoryTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final svc = LookupCache.instance.serviceName(ticket.serviceId);
    final at = ticket.doneAt ?? ticket.createdAt;
    final time = at != null
        ? DateFormat('HH:mm', 'id_ID').format(at)
        : '-';
    final prefix = ticket.number.split('-').first;
    final cancelled = ticket.status == TicketStatus.cancelled;
    final statusColor =
        cancelled ? const Color(0xFFFC8181) : const Color(0xFF34D399);
    final statusLabel = cancelled ? 'Dibuang' : 'Selesai';
    final customer = (ticket.customerName ?? '').trim();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      radius: 14,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: statusColor.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: Text(
                prefix,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ticket.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CountChip(label: statusLabel, color: statusColor),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  customer.isEmpty ? '$svc · $time' : '$svc · $time · $customer',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Waiting list tile ────────────────────────────────────────────────────

class _WaitingTile extends StatelessWidget {
  final Ticket ticket;
  const _WaitingTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final svc = LookupCache.instance.serviceName(ticket.serviceId);
    final time = ticket.queuedAt != null
        ? DateFormat('HH:mm', 'id_ID').format(ticket.queuedAt!)
        : '-';
    final prefix = ticket.number.split('-').first;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      radius: 14,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kAccentStart.withValues(alpha: 0.25),
                  kAccentEnd.withValues(alpha: 0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kAccentStart.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                prefix,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$svc · $time',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (ticket.skipCount > 0)
            CountChip(label: 'Skip ${ticket.skipCount}×', color: Colors.orange),
        ],
      ),
    );
  }
}

// ── Skip choice dialog ───────────────────────────────────────────────────

enum _SkipChoice { requeue, cancel }

class _SkipChoiceDialog extends StatelessWidget {
  final Ticket ticket;
  const _SkipChoiceDialog({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1438),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skip ${ticket.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pilih aksi untuk tiket ini',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SkipChoiceTile(
                icon: Icons.south_rounded,
                color: kAccentLight,
                title: 'Kembalikan ke urutan terakhir',
                subtitle:
                    'Tiket masuk lagi ke antrian, geser ke paling belakang.',
                onTap: () => Navigator.pop(context, _SkipChoice.requeue),
              ),
              const SizedBox(height: 8),
              _SkipChoiceTile(
                icon: Icons.block_rounded,
                color: const Color(0xFFFC8181),
                title: 'Cancel tiket',
                subtitle:
                    'Tiket tidak akan bisa dipanggil lagi. Datanya tetap tersimpan.',
                onTap: () => Navigator.pop(context, _SkipChoice.cancel),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkipChoiceTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SkipChoiceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Serve dialog (dark themed) ───────────────────────────────────────────

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

  void _submit() {
    Navigator.pop(
      context,
      _ServeFormData(
        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = LookupCache.instance.serviceName(widget.ticket.serviceId);
    return Dialog(
      backgroundColor: const Color(0xFF1A1438),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF34D399).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF34D399)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Color(0xFF34D399), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selesaikan ${widget.ticket.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Layanan: $svc',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Detail pelanggan (opsional)',
                style: TextStyle(
                  color: kAccentLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textInputAction: TextInputAction.next,
                decoration: darkInputDecoration(
                  labelText: 'Nama Pelanggan',
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textInputAction: TextInputAction.next,
                decoration: darkInputDecoration(
                  labelText: 'No. HP',
                  prefixIcon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: darkInputDecoration(
                  labelText: 'Catatan',
                  prefixIcon: Icons.notes_rounded,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                  const Spacer(),
                  GradientButton(
                    label: 'Selesaikan',
                    icon: Icons.check_rounded,
                    onPressed: _submit,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    fontSize: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
