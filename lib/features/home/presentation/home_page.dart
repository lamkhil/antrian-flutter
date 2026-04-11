import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antrian/globals/widgets/app_layout.dart';
import 'package:antrian/extension/size.dart';
import '../application/home_controller.dart';
import '../application/home_state.dart';
import 'widgets/stat_card.dart';
import 'widgets/antrian_aktif_card.dart';
import 'widgets/zona_kapasitas_card.dart';
import 'widgets/waktu_tunggu_card.dart';
import 'widgets/riwayat_card.dart';
import 'widgets/ringkasan_layanan_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    return AppLayout(
      title: 'Dashboard',
      breadcrumbs: const ['Home', 'Dashboard'],
      child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(homeControllerProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stat cards ───────────────────────
                    _StatGrid(stats: state.stats, isDesktop: isDesktop),
                    const SizedBox(height: 16),

                    // ── Antrian + Zona + Waktu ───────────
                    isDesktop
                        ? _DesktopRow(state: state)
                        : _MobileColumn(state: state),
                    const SizedBox(height: 16),

                    // ── Riwayat + Ringkasan ──────────────
                    isDesktop || isTablet
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: RiwayatCard(items: state.riwayat),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: RingkasanLayananCard(
                                  items: state.ringkasanLayanan,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              RiwayatCard(items: state.riwayat),
                              const SizedBox(height: 16),
                              RingkasanLayananCard(
                                items: state.ringkasanLayanan,
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

class _StatGrid extends StatelessWidget {
  final DashboardStats stats;
  final bool isDesktop;

  const _StatGrid({required this.stats, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(
        label: 'Total antrian hari ini',
        value: '${stats.totalHariIni}',
        icon: Icons.confirmation_number_rounded,
        iconBg: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF6366F1),
        delta: '↑ 12% dari kemarin',
        deltaPositive: true,
      ),
      StatCard(
        label: 'Selesai dilayani',
        value: '${stats.selesai}',
        icon: Icons.check_circle_outline_rounded,
        iconBg: const Color(0xFFEAF3DE),
        iconColor: const Color(0xFF3B6D11),
        delta:
            '${(stats.selesai / stats.totalHariIni * 100).toStringAsFixed(1)}% dari total',
        deltaPositive: true,
      ),
      StatCard(
        label: 'Sedang menunggu',
        value: '${stats.menunggu}',
        icon: Icons.hourglass_empty_rounded,
        iconBg: const Color(0xFFFAEEDA),
        iconColor: const Color(0xFF854F0B),
        delta: 'Stabil',
        deltaPositive: null,
      ),
      StatCard(
        label: 'Dibatalkan',
        value: '${stats.dibatalkan}',
        icon: Icons.cancel_outlined,
        iconBg: const Color(0xFFFCEBEB),
        iconColor: const Color(0xFFA32D2D),
        delta: '↑ 3 dari kemarin',
        deltaPositive: false,
      ),
    ];

    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 1.6 : 1.5,
      children: cards,
    );
  }
}

class _DesktopRow extends StatelessWidget {
  final HomeState state;

  const _DesktopRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: AntrianAktifCard(items: state.antrianAktif)),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              ZonaKapasitasCard(zones: state.zonaList),
              const SizedBox(height: 16),
              WaktuTungguCard(menitRata: state.stats.rataWaktuMenit),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileColumn extends StatelessWidget {
  final HomeState state;

  const _MobileColumn({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AntrianAktifCard(items: state.antrianAktif),
        const SizedBox(height: 16),
        ZonaKapasitasCard(zones: state.zonaList),
        const SizedBox(height: 16),
        WaktuTungguCard(menitRata: state.stats.rataWaktuMenit),
      ],
    );
  }
}
