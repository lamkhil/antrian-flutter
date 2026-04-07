import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/zone_controller.dart';

// ═══════════════════════════════════════════════════════════════
// CONFIG — semua kustomisasi teks & non-warna di sini
// ═══════════════════════════════════════════════════════════════
class ZoneConfig {
  static const String institutionName = 'DPMPTSP';
  static const String institutionSub = 'Sistem Digital';
  static const List<String> counters = ['Loket 1', 'Loket 2', 'Loket 3'];

  static const String nowServingLabel = 'NOMOR DIPANGGIL';
  static const String waitingListLabel = 'ANTRIAN MENUNGGU';
  static const String recentDoneLabel = 'BARU SELESAI';
  static const String tickerMessage =
      'Harap siapkan kartu identitas dan surat pendukung Anda  ·  '
      'Nomor antrian yang tidak hadir dalam 3 kali panggilan akan dilewati  ·  '
      'Jam operasional: 07.00 – 16.00 WIB  ·  '
      'Terima kasih atas kesabaran Anda  ·  ';

  static const Duration callBlinkDuration = Duration(milliseconds: 800);
  static const Duration tickerSpeed = Duration(milliseconds: 35);
}

// ═══════════════════════════════════════════════════════════════
// ZONE COLORS — semua warna aware terhadap brightness
// ═══════════════════════════════════════════════════════════════
class ZoneColors {
  final Color bg;
  final Color panel;
  final Color card;
  final Color border;
  final Color accent;
  final Color accentDim;
  final Color gold;
  final Color goldDim;
  final Color danger;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const ZoneColors._({
    required this.bg,
    required this.panel,
    required this.card,
    required this.border,
    required this.accent,
    required this.accentDim,
    required this.gold,
    required this.goldDim,
    required this.danger,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static const ZoneColors dark = ZoneColors._(
    bg: Color(0xFF050D1A),
    panel: Color(0xFF0A1628),
    card: Color(0xFF0D1F3C),
    border: Color(0xFF1A3050),
    accent: Color(0xFF00E5C3),
    accentDim: Color(0xFF007A69),
    gold: Color(0xFFFFCC44),
    goldDim: Color(0xFF7A5E00),
    danger: Color(0xFFFF5F5F),
    textPrimary: Color(0xFFEAF4FF),
    textSecondary: Color(0xFF4A7A9B),
    textMuted: Color(0xFF243A52),
  );

  static const ZoneColors light = ZoneColors._(
    bg: Color(0xFFF0F4F8),
    panel: Color(0xFFFFFFFF),
    card: Color(0xFFF7FAFC),
    border: Color(0xFFD0DDE8),
    accent: Color(0xFF00897B),
    accentDim: Color(0xFFB2DFDB),
    gold: Color(0xFFD4860A),
    goldDim: Color(0xFFFFF3CD),
    danger: Color(0xFFD32F2F),
    textPrimary: Color(0xFF0D1F3C),
    textSecondary: Color(0xFF4A6070),
    textMuted: Color(0xFF8FA8BC),
  );

  static ZoneColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

// ═══════════════════════════════════════════════════════════════
// MODEL
// ═══════════════════════════════════════════════════════════════
class QueueItem {
  final String id;
  final String number;
  final String name;
  final QueueStatus status;
  final String? counter;
  final DateTime createdAt;

  const QueueItem({
    required this.id,
    required this.number,
    required this.name,
    required this.status,
    this.counter,
    required this.createdAt,
  });
}

enum QueueStatus { waiting, serving, done, skipped }

// ═══════════════════════════════════════════════════════════════
// DUMMY DATA (ganti dengan Obx + controller)
// ═══════════════════════════════════════════════════════════════
final _dummyItems = <QueueItem>[
  QueueItem(
    id: '1',
    number: 'A-047',
    name: 'Budi Santoso',
    status: QueueStatus.serving,
    counter: 'Loket 1',
    createdAt: DateTime.now(),
  ),
  QueueItem(
    id: '2',
    number: 'A-048',
    name: 'Siti Rahayu',
    status: QueueStatus.serving,
    counter: 'Loket 2',
    createdAt: DateTime.now(),
  ),
  QueueItem(
    id: '3',
    number: 'B-012',
    name: 'Ahmad Fauzi',
    status: QueueStatus.serving,
    counter: 'Loket 3',
    createdAt: DateTime.now(),
  ),
  QueueItem(
    id: '4',
    number: 'A-049',
    name: 'Dewi Lestari',
    status: QueueStatus.waiting,
    createdAt: DateTime.now(),
  ),
  QueueItem(
    id: '5',
    number: 'A-050',
    name: 'Eko Prasetyo',
    status: QueueStatus.waiting,
    createdAt: DateTime.now(),
  ),
  QueueItem(
    id: '6',
    number: 'A-051',
    name: 'Fitri Handayani',
    status: QueueStatus.waiting,
    createdAt: DateTime.now(),
  ),
  QueueItem(
    id: '7',
    number: 'B-013',
    name: 'Gita Permata',
    status: QueueStatus.waiting,
    createdAt: DateTime.now(),
  ),
  QueueItem(
    id: '8',
    number: 'B-014',
    name: 'Hendra Kusuma',
    status: QueueStatus.waiting,
    createdAt: DateTime.now(),
  ),
  QueueItem(
    id: '9',
    number: 'A-046',
    name: 'Indah Sari',
    status: QueueStatus.done,
    counter: 'Loket 1',
    createdAt: DateTime.now(),
  ),
  QueueItem(
    id: '10',
    number: 'B-011',
    name: 'Joko Widodo',
    status: QueueStatus.done,
    counter: 'Loket 2',
    createdAt: DateTime.now(),
  ),
];

// ═══════════════════════════════════════════════════════════════
// THEME CONTROLLER (GetX) — toggle dark/light dari mana saja
// ═══════════════════════════════════════════════════════════════
class ZoneThemeController extends GetxController {
  final _isDark = true.obs;
  bool get isDark => _isDark.value;

  void toggle() {
    _isDark.value = !_isDark.value;
    Get.changeThemeMode(_isDark.value ? ThemeMode.dark : ThemeMode.light);
  }
}

// ═══════════════════════════════════════════════════════════════
// MAIN VIEW
// ═══════════════════════════════════════════════════════════════
class ZoneView extends GetView<ZoneController> {
  const ZoneView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final c = ZoneColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          const _TopBar(),
          Expanded(
            child: Row(
              children: [
                const Expanded(flex: 6, child: _CallingPanel()),
                Builder(
                  builder: (ctx) =>
                      Container(width: 1, color: ZoneColors.of(ctx).border),
                ),
                const Expanded(flex: 4, child: _WaitingPanel()),
              ],
            ),
          ),
          const _TickerBar(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════
class _TopBar extends StatefulWidget {
  const _TopBar();
  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  final _theme = Get.find<ZoneThemeController>();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final c = ZoneColors.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: c.panel,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: c.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: c.accent.withOpacity(0.4)),
            ),
            child: Icon(
              Icons.local_hospital_rounded,
              color: c.accent,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            ZoneConfig.institutionName,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '· ${ZoneConfig.institutionSub}',
            style: TextStyle(color: c.textSecondary, fontSize: 11),
          ),
          const Spacer(),
          Text(
            '${_pad(_now.hour)}:${_pad(_now.minute)}:${_pad(_now.second)}',
            style: TextStyle(
              color: c.accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${_pad(_now.day)}/${_pad(_now.month)}/${_now.year}',
            style: TextStyle(color: c.textSecondary, fontSize: 11),
          ),
          const SizedBox(width: 20),
          // ── Toggle dark/light ──
          Obx(
            () => GestureDetector(
              onTap: _theme.toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: c.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.accent.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _theme.isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: c.accent,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _theme.isDark ? 'DARK' : 'LIGHT',
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PANEL KIRI — NOMOR DIPANGGIL
// ═══════════════════════════════════════════════════════════════
class _CallingPanel extends StatelessWidget {
  const _CallingPanel();

  @override
  Widget build(BuildContext context) {
    final c = ZoneColors.of(context);
    final serving = _dummyItems
        .where((e) => e.status == QueueStatus.serving)
        .toList();

    return Container(
      color: c.panel,
      child: Column(
        children: [
          _PanelHeader(label: ZoneConfig.nowServingLabel, color: c.accent),
          Expanded(
            child: serving.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada yang dipanggil',
                      style: TextStyle(color: c.textSecondary),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: serving.length == 1 ? 1 : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: serving.length == 1 ? 2.4 : 1.6,
                    ),
                    itemCount: serving.length,
                    itemBuilder: (_, i) => _CallingCard(item: serving[i]),
                  ),
          ),
          _BottomStats(colors: c),
        ],
      ),
    );
  }
}

class _CallingCard extends StatefulWidget {
  final QueueItem item;
  const _CallingCard({required this.item});
  @override
  State<_CallingCard> createState() => _CallingCardState();
}

class _CallingCardState extends State<_CallingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: ZoneConfig.callBlinkDuration,
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ZoneColors.of(context);
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: c.accent.withOpacity(0.25 + 0.5 * _glow.value),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: c.accent.withOpacity(0.07 * _glow.value),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.item.counter ?? '—',
                style: TextStyle(
                  color: c.accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.number,
              style: TextStyle(
                color: Color.lerp(c.textPrimary, c.accent, 0.35 * _glow.value),
                fontSize: 50,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.name,
              style: TextStyle(color: c.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomStats extends StatelessWidget {
  final ZoneColors colors;
  const _BottomStats({required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final waiting = _dummyItems
        .where((e) => e.status == QueueStatus.waiting)
        .length;
    final done = _dummyItems.where((e) => e.status == QueueStatus.done).length;
    final skipped = _dummyItems
        .where((e) => e.status == QueueStatus.skipped)
        .length;
    final total = _dummyItems.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          _MiniStat('TOTAL', '$total', c.textSecondary, c),
          _VDiv(c),
          _MiniStat('MENUNGGU', '$waiting', c.gold, c),
          _VDiv(c),
          _MiniStat('SELESAI', '$done', c.accent, c),
          _VDiv(c),
          _MiniStat('DILEWATI', '$skipped', c.danger, c),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final ZoneColors c;
  const _MiniStat(this.label, this.value, this.color, this.c);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 8,
            letterSpacing: 1.5,
          ),
        ),
      ],
    ),
  );
}

class _VDiv extends StatelessWidget {
  final ZoneColors c;
  const _VDiv(this.c);
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 28,
    color: c.border,
    margin: const EdgeInsets.symmetric(horizontal: 6),
  );
}

// ═══════════════════════════════════════════════════════════════
// PANEL KANAN — DAFTAR ANTRIAN
// ═══════════════════════════════════════════════════════════════
class _WaitingPanel extends StatelessWidget {
  const _WaitingPanel();

  @override
  Widget build(BuildContext context) {
    final c = ZoneColors.of(context);
    final waiting = _dummyItems
        .where((e) => e.status == QueueStatus.waiting)
        .toList();
    final done = _dummyItems
        .where((e) => e.status == QueueStatus.done)
        .take(3)
        .toList();

    return Container(
      color: c.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeader(
            label: ZoneConfig.waitingListLabel,
            color: c.gold,
            count: waiting.length,
          ),
          Expanded(
            flex: 6,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              itemCount: waiting.length,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (_, i) => _WaitingRow(item: waiting[i], rank: i + 1),
            ),
          ),
          Divider(height: 1, thickness: 1, color: c.border),
          _PanelHeader(
            label: ZoneConfig.recentDoneLabel,
            color: c.textSecondary,
            count: done.length,
          ),
          Expanded(
            flex: 3,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
              itemCount: done.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) => _DoneRow(item: done[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared panel header ───
class _PanelHeader extends StatelessWidget {
  final String label;
  final Color color;
  final int? count;
  const _PanelHeader({required this.label, required this.color, this.count});

  @override
  Widget build(BuildContext context) {
    final c = ZoneColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const Spacer(),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WaitingRow extends StatelessWidget {
  final QueueItem item;
  final int rank;
  const _WaitingRow({required this.item, required this.rank});

  @override
  Widget build(BuildContext context) {
    final c = ZoneColors.of(context);
    final isNext = rank == 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isNext ? c.goldDim.withOpacity(0.25) : c.card,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isNext ? c.gold.withOpacity(0.45) : c.border,
          width: isNext ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              rank.toString().padLeft(2, '0'),
              style: TextStyle(
                color: isNext ? c.gold : c.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.number,
            style: TextStyle(
              color: isNext ? c.gold : c.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                color: isNext ? c.textPrimary : c.textSecondary,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: c.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: c.gold.withOpacity(0.4), width: 0.5),
              ),
              child: Text(
                'BERIKUTNYA',
                style: TextStyle(
                  color: c.gold,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DoneRow extends StatelessWidget {
  final QueueItem item;
  const _DoneRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = ZoneColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.card.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: c.accentDim, size: 13),
          const SizedBox(width: 8),
          Text(
            item.number,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.lineThrough,
              decorationColor: c.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(color: c.textMuted, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.counter != null)
            Text(
              item.counter!,
              style: TextStyle(color: c.textMuted, fontSize: 9),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TICKER BAR
// ═══════════════════════════════════════════════════════════════
class _TickerBar extends StatefulWidget {
  const _TickerBar();
  @override
  State<_TickerBar> createState() => _TickerBarState();
}

class _TickerBarState extends State<_TickerBar> {
  final ScrollController _scroll = ScrollController();
  late Timer _timer;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(ZoneConfig.tickerSpeed, (_) {
      if (!_scroll.hasClients) return;
      _offset += 1.2;
      if (_offset >= _scroll.position.maxScrollExtent) _offset = 0;
      _scroll.jumpTo(_offset);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ZoneColors.of(context);
    return Container(
      height: 30,
      color: c.accentDim.withOpacity(0.15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: c.accent.withOpacity(0.12),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: c.accent, size: 12),
                const SizedBox(width: 6),
                Text(
                  'INFO',
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ZoneConfig.tickerMessage * 5,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// THEME DATA HELPER — pasang di GetMaterialApp
// ═══════════════════════════════════════════════════════════════
//
// Cara pakai di main.dart:
//
//   void main() {
//     Get.put(ZoneThemeController());
//     runApp(
//       GetMaterialApp(
//         theme:     ZoneTheme.light,
//         darkTheme: ZoneTheme.dark,
//         themeMode: ThemeMode.dark,
//         home: const ZoneView(),
//       ),
//     );
//   }
//
class ZoneTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ZoneColors.dark.bg,
    colorScheme: ColorScheme.dark(
      primary: ZoneColors.dark.accent,
      surface: ZoneColors.dark.panel,
    ),
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: ZoneColors.light.bg,
    colorScheme: ColorScheme.light(
      primary: ZoneColors.light.accent,
      surface: ZoneColors.light.panel,
    ),
  );
}
