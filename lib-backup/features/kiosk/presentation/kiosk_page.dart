import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/features/kiosk/application/kiosk_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class KioskPage extends ConsumerWidget {
  const KioskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kioskControllerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: switch (state.status) {
          KioskStatus.loadingLokasi => const _Loading(),
          KioskStatus.pilihLokasi => _PilihLokasi(items: state.lokasiList),
          KioskStatus.pilihLayanan => _PilihLayanan(state: state),
          KioskStatus.cetak => state.tiket == null
              ? const _Loading(message: 'Mencetak tiket...')
              : _TiketView(state: state),
          KioskStatus.error => _ErrorView(message: state.error ?? 'Error'),
        },
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const _Header({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF6366F1),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC7D2FE),
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Pilih lokasi ──────────────────────────────────────────

class _PilihLokasi extends ConsumerWidget {
  final List<Lokasi> items;
  const _PilihLokasi({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const _Header(
          title: 'Selamat Datang',
          subtitle: 'Silakan pilih lokasi',
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Belum ada lokasi terdaftar'))
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.2,
                    children: items
                        .map(
                          (l) => _BigButton(
                            label: l.nama,
                            onTap: () => ref
                                .read(kioskControllerProvider.notifier)
                                .pilihLokasi(l),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Pilih layanan ─────────────────────────────────────────

class _PilihLayanan extends ConsumerWidget {
  final KioskState state;
  const _PilihLayanan({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _Header(
          title: 'Pilih Layanan',
          subtitle: state.lokasi?.nama,
          trailing: state.lokasiList.length > 1
              ? TextButton.icon(
                  onPressed: () =>
                      ref.read(kioskControllerProvider.notifier).gantiLokasi(),
                  icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                  label: const Text(
                    'Ganti lokasi',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null,
        ),
        Expanded(
          child: state.layananList.isEmpty
              ? const Center(
                  child: Text('Tidak ada layanan aktif di lokasi ini'),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.8,
                    children: state.layananList
                        .map(
                          (l) => _LayananCard(
                            layanan: l,
                            onTap: () => ref
                                .read(kioskControllerProvider.notifier)
                                .ambilTiket(l),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _LayananCard extends StatelessWidget {
  final Layanan layanan;
  final VoidCallback onTap;
  const _LayananCard({required this.layanan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.room_service_outlined,
                  color: Color(0xFF6366F1),
                ),
              ),
              const Spacer(),
              Text(
                layanan.nama,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${layanan.kode} · ${layanan.zona.nama}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BigButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tiket ─────────────────────────────────────────────────

class _TiketView extends ConsumerStatefulWidget {
  final KioskState state;
  const _TiketView({required this.state});

  @override
  ConsumerState<_TiketView> createState() => _TiketViewState();
}

class _TiketViewState extends ConsumerState<_TiketView> {
  @override
  void initState() {
    super.initState();
    // Auto kembali ke daftar layanan setelah 10 detik.
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        ref.read(kioskControllerProvider.notifier).kembaliKeLayanan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.state.tiket!;
    final fmt = DateFormat('d MMM yyyy · HH:mm', 'id_ID');

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'NOMOR ANTRIAN ANDA',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.nomorAntrian,
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
                fontFamily: 'monospace',
                height: 1,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 16),
            _Row(label: 'Layanan', value: t.layanan.nama),
            const SizedBox(height: 8),
            _Row(label: 'Zona', value: t.zona.nama),
            const SizedBox(height: 8),
            _Row(label: 'Lokasi', value: t.lokasi.nama),
            const SizedBox(height: 8),
            _Row(label: 'Waktu', value: fmt.format(t.waktuDaftar)),
            const SizedBox(height: 24),
            const Text(
              'Silakan menunggu panggilan',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ref
                    .read(kioskControllerProvider.notifier)
                    .kembaliKeLayanan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ── Loading / error ───────────────────────────────────────

class _Loading extends StatelessWidget {
  final String? message;
  const _Loading({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF6366F1),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFEF4444),
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Terjadi kesalahan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  ref.read(kioskControllerProvider.notifier).gantiLokasi(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
