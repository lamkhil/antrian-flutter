// zone_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antrian/app/modules/zone/controllers/zone_controller.dart';

class ZoneView extends GetView<ZoneController> {
  const ZoneView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _PanelKiri()),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.36,
                    child: _PanelKanan(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  late Timer _timer;
  String _time = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time = '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}';
    });
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFC107),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: MediaQuery.of(context).size.height * 0.11,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sistem antrian — RS Contoh',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.018,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF412402),
            ),
          ),
          Text(
            _time,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.016,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF633806),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Panel Kiri ────────────────────────────────────────────────────────────

class _PanelKiri extends StatelessWidget {
  // Data dummy — nanti diganti dari controller
  final _recent = const [
    _RecentItem(loket: 'Poli Umum', nomor: 'D014'),
    _RecentItem(loket: 'Kasir 1', nomor: 'B008'),
    _RecentItem(loket: 'Farmasi 1', nomor: 'C019'),
    _RecentItem(loket: 'Pendaftaran 2', nomor: 'A037'),
  ];

  const _PanelKiri();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF1E1E2E))),
      ),
      child: Column(
        children: [
          // Nomor utama
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SEDANG DIPANGGIL',
                  style: TextStyle(
                    fontSize: w * 0.0095,
                    color: const Color(0xFF555555),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pendaftaran 1',
                  style: TextStyle(
                    fontSize: w * 0.015,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFBBBBBB),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A042',
                  style: TextStyle(
                    fontSize: w * 0.11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFC107),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF182A10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Silakan menuju loket',
                    style: TextStyle(
                      fontSize: w * 0.0095,
                      color: const Color(0xFF7BC44A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Riwayat panggilan
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E1E2E))),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DIPANGGIL SEBELUMNYA',
                  style: TextStyle(
                    fontSize: w * 0.0075,
                    color: const Color(0xFF444444),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _recent
                      .map(
                        (item) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _RecentCard(item: item),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentItem {
  final String loket;
  final String nomor;
  const _RecentItem({required this.loket, required this.nomor});
}

class _RecentCard extends StatelessWidget {
  final _RecentItem item;
  const _RecentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        border: Border.all(color: const Color(0xFF1E1E2E)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.loket,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: w * 0.0075,
              color: const Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.nomor,
            style: TextStyle(
              fontSize: w * 0.018,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Panel Kanan ───────────────────────────────────────────────────────────

class _LoketItem {
  final String nama;
  final String zona;
  final String? nomor; // null = tidak aktif
  const _LoketItem({required this.nama, required this.zona, this.nomor});
  bool get aktif => nomor != null;
}

class _PanelKanan extends StatefulWidget {
  @override
  State<_PanelKanan> createState() => _PanelKananState();
}

class _PanelKananState extends State<_PanelKanan> {
  final _loketList = const [
    _LoketItem(nama: 'Pendaftaran 1', zona: 'Zona A', nomor: 'A042'),
    _LoketItem(nama: 'Pendaftaran 2', zona: 'Zona A', nomor: 'A037'),
  ];

  late final ScrollController _scrollController;
  Timer? _scrollTimer;

  // Kecepatan scroll px per tick (16ms)
  static const double _speed = 0.5;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Tunggu frame pertama agar maxScrollExtent sudah tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) async {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (max <= 0) return;

      final current = _scrollController.offset;

      _scrollController.jumpTo(current + _speed);
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final aktifCount = _loketList.where((l) => l.aktif).length;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF1E1E2E))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATUS LOKET',
                style: TextStyle(
                  fontSize: w * 0.0085,
                  color: const Color(0xFF555555),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$aktifCount aktif',
                style: TextStyle(
                  fontSize: w * 0.0085,
                  color: const Color(0xFF444444),
                ),
              ),
            ],
          ),
        ),

        // List infinite scroll
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                _loketList.length * 100 > MediaQuery.of(context).size.height
                ? null
                : _loketList.length,
            itemBuilder: (_, i) =>
                _LoketTile(item: _loketList[i % _loketList.length]),
          ),
        ),
      ],
    );
  }
}

class _LoketTile extends StatelessWidget {
  final _LoketItem item;
  const _LoketTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      alignment: Alignment.centerLeft,
      child: Card(
        color: const Color.fromARGB(255, 64, 64, 64),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          leading: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.aktif
                  ? const Color(0xFF7BC44A)
                  : const Color(0xFF2A2A3A),
            ),
          ),
          title: Text(
            item.nomor ?? '-',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFAAAAAA),
            ),
          ),
          trailing: Text(
            item.nama,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: item.aktif
                  ? const Color(0xFFEEEEEE)
                  : const Color(0xFF2A2A3A),
            ),
          ),
        ),
      ),
    );
  }
}
