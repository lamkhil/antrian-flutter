import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/ai_voice_settings_service.dart';
import '../../data/kiosk_session.dart';
import '../../data/lookup_cache.dart';
import '../../data/ticket_service.dart';
import '../../models/ai_voice_settings.dart';
import '../../models/kiosk.dart';
import '../../models/service.dart' as models;
import '../../models/ticket.dart';
import 'kiosk_local_bg.dart';
import 'kiosk_printer.dart';
import 'voice/ai_conversation.dart';
import 'voice/kiosk_voice_page.dart';
import 'widgets/printer_settings_dialog.dart';

// ── Default theme tokens (match login_page) ──────────────────────────────
const _kBgGradient = [
  Color(0xFF0D0A2E),
  Color(0xFF130E3A),
  Color(0xFF0A0820),
];
const _kAccentDefault = Color(0xFF6366F1);
const _kAccentEnd = Color(0xFF8B5CF6);
const _kAccentLight = Color(0xFFA5B4FC);

class KioskHomePage extends StatefulWidget {
  const KioskHomePage({super.key});

  @override
  State<KioskHomePage> createState() => _KioskHomePageState();
}

class _KioskHomePageState extends State<KioskHomePage> {
  final _ticketService = TicketService();
  Kiosk? _kiosk;
  ImageProvider? _localBg;
  KioskPrinterConfig? _printerCfg;
  AiVoiceSettings _voiceSettings = AiVoiceSettingsService.instance.current;
  StreamSubscription<AiVoiceSettings>? _voiceSub;
  bool _checking = true;
  bool _busy = false;

  /// Apakah tombol voice ditampilkan: platform support + voice settings
  /// (master switch global + override per-kios) + ada layanan + ada API key.
  bool get _voiceVisible {
    if (!isVoiceSupportedOnPlatform) return false;
    if (_voiceSettings.apiKey.isEmpty) return false;
    final kiosk = _kiosk;
    if (kiosk == null) return false;
    return kiosk.isVoiceEnabled(globalEnabled: _voiceSettings.enabled);
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _voiceSub = AiVoiceSettingsService.instance.watch().listen((s) {
      if (!mounted) return;
      setState(() => _voiceSettings = s);
    });
  }

  @override
  void dispose() {
    _voiceSub?.cancel();
    super.dispose();
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
    final localBg = await KioskLocalBg.read(kiosk.deviceId);
    final printerCfg = await KioskPrinter.readConfig(kiosk.deviceId);
    if (!mounted) return;
    setState(() {
      _kiosk = kiosk;
      _localBg = localBg;
      _printerCfg = printerCfg;
      _checking = false;
    });
  }

  Future<void> _pickLocalBg() async {
    final kiosk = _kiosk;
    if (kiosk == null) return;
    try {
      final old = _localBg;
      final provider = await KioskLocalBg.pickAndSave(kiosk.deviceId);
      if (provider == null || !mounted) return;
      if (old != null) await old.evict();
      if (!mounted) return;
      setState(() => _localBg = provider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar latar lokal disimpan.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan gambar: $e')),
      );
    }
  }

  Future<void> _clearLocalBg() async {
    final kiosk = _kiosk;
    if (kiosk == null) return;
    final old = _localBg;
    await KioskLocalBg.clear(kiosk.deviceId);
    if (old != null) await old.evict();
    if (!mounted) return;
    setState(() => _localBg = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gambar latar lokal dihapus.')),
    );
  }

  Future<void> _resetDevice() async {
    await KioskSession.instance.clear();
    if (mounted) context.go('/kiosk/setup');
  }

  Future<void> _openPrinterSettings() async {
    final kiosk = _kiosk;
    if (kiosk == null) return;
    final result = await showDialog<KioskPrinterConfig?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PrinterSettingsDialog(
        deviceId: kiosk.deviceId,
        initial: _printerCfg,
      ),
    );
    if (!mounted) return;
    // Hasil dialog: cfg baru = simpan, null + ada initial = dihapus,
    // null + tidak ada initial = dibatalkan (tidak ubah state).
    if (result != null) {
      setState(() => _printerCfg = result);
    } else if (_printerCfg != null) {
      // Re-baca untuk memastikan penghapusan benar-benar tersimpan.
      final fresh = await KioskPrinter.readConfig(kiosk.deviceId);
      if (mounted) setState(() => _printerCfg = fresh);
    }
  }

  /// Cetak tiket di background — tidak boleh memblokir UI. Kegagalan
  /// di-toast supaya operator tahu, tapi tidak menghentikan flow tiket.
  void _autoPrintIfConfigured(Ticket ticket, models.Service service) {
    final kiosk = _kiosk;
    final cfg = _printerCfg;
    if (kiosk == null || cfg == null || !cfg.autoPrint) return;
    if (!KioskPrinter.isSupported) return;
    () async {
      final ok = await KioskPrinter.printTicket(
        ticket: ticket,
        service: service,
        kiosk: kiosk,
        cfg: cfg,
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiket tidak tercetak — periksa printer.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }();
  }

  Future<void> _openAdminSheet() async {
    final kiosk = _kiosk;
    if (kiosk == null) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF130E3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _KioskAdminSheet(
        hasLocalBg: _localBg != null,
        printerName: _printerCfg?.displayName,
        printerAutoPrint: _printerCfg?.autoPrint ?? false,
        onPickLocalBg: () {
          Navigator.of(ctx).pop();
          _pickLocalBg();
        },
        onClearLocalBg: () {
          Navigator.of(ctx).pop();
          _clearLocalBg();
        },
        onPrinterSettings: () {
          Navigator.of(ctx).pop();
          _openPrinterSettings();
        },
        onResetDevice: () {
          Navigator.of(ctx).pop();
          _resetDevice();
        },
      ),
    );
  }

  Future<void> _openVoiceMode(Color accent) async {
    final kiosk = _kiosk;
    if (kiosk == null) return;
    final services = LookupCache.instance.services;
    final zones = LookupCache.instance.zones;
    final serviceId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => KioskVoicePage(
          kiosk: kiosk,
          settings: _voiceSettings,
          services: services,
          zones: zones,
        ),
        fullscreenDialog: true,
      ),
    );
    if (!mounted || serviceId == null) return;
    final service = services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => services.first,
    );
    await _issue(service, accent);
  }

  Future<void> _issue(models.Service service, Color accent) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ticket = await _ticketService.createTicket(service.id);
      if (!mounted) return;
      _autoPrintIfConfigured(ticket, service);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _TicketSuccessScreen(
            ticket: ticket,
            service: service,
            kiosk: _kiosk!,
            localBg: _localBg,
            accent: accent,
          ),
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
        backgroundColor: Color(0xFF0A0820),
        body: Center(
          child: CircularProgressIndicator(color: _kAccentLight),
        ),
      );
    }
    final kiosk = _kiosk!;
    final accent = _parseHex(kiosk.buttonColor) ?? _kAccentDefault;
    final services = LookupCache.instance.services;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0820),
      body: _KioskBackground(
        kiosk: kiosk,
        localBg: _localBg,
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                kiosk: kiosk,
                accent: accent,
                onAdminLongPress: _openAdminSheet,
              ),
              Expanded(
                child: services.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada layanan tersedia',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 18),
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
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _voiceVisible
                                  ? 'Bicara dengan asisten, atau sentuh kartu '
                                      'layanan langsung.'
                                  : 'Sentuh kartu layanan untuk mengambil nomor antrian.',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            if (_voiceVisible) ...[
                              _VoiceCta(
                                accent: accent,
                                onTap: () => _openVoiceMode(accent),
                              ),
                              const SizedBox(height: 16),
                            ],
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
                                    accent: accent,
                                    onTap: () => _issue(svc, accent),
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
      ),
    );
  }
}

// ── Background renderer (gradient/color/image) ───────────────────────────

class _KioskBackground extends StatelessWidget {
  final Kiosk kiosk;
  final ImageProvider? localBg;
  final Widget child;
  const _KioskBackground({
    required this.kiosk,
    required this.child,
    this.localBg,
  });

  @override
  Widget build(BuildContext context) {
    // Local override always wins.
    if (localBg != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: localBg!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _gradientBg(const SizedBox.shrink()),
          ),
          Container(color: Colors.black.withValues(alpha: 0.45)),
          child,
        ],
      );
    }
    switch (kiosk.bgType) {
      case KioskBgType.color:
        final color = _parseHex(kiosk.bgColor) ?? _kBgGradient.last;
        return Container(color: color, child: child);
      case KioskBgType.image:
        final url = (kiosk.bgImageUrl ?? '').trim();
        if (url.isEmpty) {
          return _gradientBg(child);
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _gradientBg(const SizedBox.shrink()),
              loadingBuilder: (ctx, w, ev) {
                if (ev == null) return w;
                return Container(color: const Color(0xFF0A0820));
              },
            ),
            // Dark scrim untuk readability
            Container(color: Colors.black.withValues(alpha: 0.45)),
            child,
          ],
        );
      case KioskBgType.gradient:
        return _gradientBg(child);
    }
  }

  Widget _gradientBg(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: _kBgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -90,
            child: _glowBlob(_kAccentDefault, 320),
          ),
          Positioned(
            bottom: -70,
            left: -70,
            child: _glowBlob(_kAccentEnd, 260),
          ),
          child,
        ],
      ),
    );
  }
}

Widget _glowBlob(Color color, double size) {
  return IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.25), Colors.transparent],
        ),
      ),
    ),
  );
}

Color? _parseHex(String? hex) {
  if (hex == null) return null;
  var s = hex.trim();
  if (s.isEmpty) return null;
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  if (s.length != 8) return null;
  final n = int.tryParse(s, radix: 16);
  if (n == null) return null;
  return Color(n);
}

// ── Header ───────────────────────────────────────────────────────────────

class _Header extends StatefulWidget {
  final Kiosk kiosk;
  final Color accent;
  final VoidCallback onAdminLongPress;
  const _Header({
    required this.kiosk,
    required this.accent,
    required this.onAdminLongPress,
  });

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onLongPress: widget.onAdminLongPress,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(Icons.print_outlined,
                        color: widget.accent, size: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.kiosk.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Device ID: ${widget.kiosk.deviceId}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
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
                            fontWeight: FontWeight.w700,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, d MMM y', 'id_ID').format(t),
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Service card ─────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final models.Service service;
  final bool busy;
  final Color accent;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.busy,
    required this.accent,
    required this.onTap,
  });

  String get _badge {
    final code = (service.code ?? '').trim();
    if (code.isNotEmpty) return code.toUpperCase();
    return service.name.isEmpty ? '#' : service.name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withValues(alpha: 0.08),
          child: InkWell(
            onTap: busy ? null : onTap,
            splashColor: accent.withValues(alpha: 0.2),
            highlightColor: accent.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: 0.35),
                          accent.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: accent.withValues(alpha: 0.5)),
                    ),
                    child: Center(
                      child: Text(
                        _badge,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.confirmation_number_outlined,
                          size: 16, color: accent),
                      const SizedBox(width: 4),
                      const Text(
                        'Ambil tiket',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ticket success ───────────────────────────────────────────────────────

class _TicketSuccessScreen extends StatefulWidget {
  final Ticket ticket;
  final models.Service service;
  final Kiosk kiosk;
  final ImageProvider? localBg;
  final Color accent;

  const _TicketSuccessScreen({
    required this.ticket,
    required this.service,
    required this.kiosk,
    required this.accent,
    this.localBg,
  });

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
      backgroundColor: const Color(0xFF0A0820),
      body: _KioskBackground(
        kiosk: widget.kiosk,
        localBg: widget.localBg,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399)
                            .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF34D399)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Color(0xFF34D399), size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Antrian Anda',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 56, vertical: 28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.accent.withValues(alpha: 0.25),
                                widget.accent.withValues(alpha: 0.10),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: widget.accent.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    widget.accent.withValues(alpha: 0.3),
                                blurRadius: 32,
                                spreadRadius: -4,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.ticket.number,
                            style: const TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
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
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            widget.accent,
                            widget.accent.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.accent.withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 36, vertical: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Selesai',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Otomatis kembali dalam ${_remaining}s',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Admin sheet (long-press header) ──────────────────────────────────────

class _KioskAdminSheet extends StatelessWidget {
  final bool hasLocalBg;
  final String? printerName;
  final bool printerAutoPrint;
  final VoidCallback onPickLocalBg;
  final VoidCallback onClearLocalBg;
  final VoidCallback onPrinterSettings;
  final VoidCallback onResetDevice;

  const _KioskAdminSheet({
    required this.hasLocalBg,
    required this.printerName,
    required this.printerAutoPrint,
    required this.onPickLocalBg,
    required this.onClearLocalBg,
    required this.onPrinterSettings,
    required this.onResetDevice,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const Text(
              'Pengaturan Kios',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Akses cepat untuk operator kios di perangkat ini.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _SheetTile(
              icon: Icons.image_outlined,
              title: hasLocalBg
                  ? 'Ganti Gambar Latar Lokal'
                  : 'Pilih Gambar Latar Lokal',
              subtitle:
                  'Disimpan di perangkat ini, mengganti pengaturan dari admin.',
              onTap: onPickLocalBg,
            ),
            if (hasLocalBg) ...[
              const SizedBox(height: 8),
              _SheetTile(
                icon: Icons.layers_clear_outlined,
                title: 'Hapus Gambar Latar Lokal',
                subtitle: 'Kembali pakai pengaturan dari admin.',
                onTap: onClearLocalBg,
              ),
            ],
            const SizedBox(height: 8),
            _SheetTile(
              icon: Icons.print_outlined,
              title: printerName == null
                  ? 'Pengaturan Printer'
                  : 'Printer: $printerName',
              subtitle: printerName == null
                  ? 'Pasangkan printer thermal Bluetooth untuk cetak otomatis.'
                  : (printerAutoPrint
                      ? 'Cetak otomatis aktif. Tap untuk ubah.'
                      : 'Cetak otomatis nonaktif. Tap untuk ubah.'),
              onTap: onPrinterSettings,
            ),
            const SizedBox(height: 8),
            _SheetTile(
              icon: Icons.lock_reset_outlined,
              title: 'Reset Perangkat',
              subtitle: 'Hapus Device ID dan kembali ke layar setup.',
              danger: true,
              onTap: onResetDevice,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFF87171) : _kAccentLight;
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Voice mode CTA banner ───────────────────────────────────────────────

class _VoiceCta extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;
  const _VoiceCta({required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.85),
                _kAccentEnd.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5), width: 2),
                ),
                child: const Icon(Icons.mic_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bicara dengan Asisten',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sebutkan layanan yang Anda butuhkan, AI akan '
                          'membantu mengarahkan.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
