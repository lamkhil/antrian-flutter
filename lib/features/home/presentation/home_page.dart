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
                    if (state.error != null) ...[
                      _ErrorBanner(message: state.error!),
                      const SizedBox(height: 12),
                    ],
                    _StatGrid(state: state, isDesktop: isDesktop),
                    const SizedBox(height: 16),
                    isDesktop
                        ? _DesktopRow(state: state)
                        : _MobileColumn(state: state),
                    const SizedBox(height: 16),
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
  final HomeState state;
  final bool isDesktop;

  const _StatGrid({required this.state, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final total = state.totalHariIni == 0 ? 1 : state.totalHariIni;
    final persenSelesai = (state.selesai / total * 100).toStringAsFixed(1);

    final cards = [
      StatCard(
        label: 'Total antrian hari ini',
        value: '${state.totalHariIni}',
        icon: Icons.confirmation_number_rounded,
        iconBg: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF6366F1),
        delta: 'Per ${_nowHHmm()}',
        deltaPositive: null,
      ),
      StatCard(
        label: 'Selesai dilayani',
        value: '${state.selesai}',
        icon: Icons.check_circle_outline_rounded,
        iconBg: const Color(0xFFEAF3DE),
        iconColor: const Color(0xFF3B6D11),
        delta: '$persenSelesai% dari total',
        deltaPositive: true,
      ),
      StatCard(
        label: 'Sedang menunggu',
        value: '${state.menunggu}',
        icon: Icons.hourglass_empty_rounded,
        iconBg: const Color(0xFFFAEEDA),
        iconColor: const Color(0xFF854F0B),
        delta: state.menunggu == 0 ? 'Tidak ada antrean' : 'Aktif',
        deltaPositive: null,
      ),
      StatCard(
        label: 'Dilewati',
        value: '${state.dilewati}',
        icon: Icons.cancel_outlined,
        iconBg: const Color(0xFFFCEBEB),
        iconColor: const Color(0xFFA32D2D),
        delta: state.dilewati == 0 ? '-' : '${state.dilewati} kasus',
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

  String _nowHHmm() {
    final n = DateTime.now();
    final h = n.hour.toString().padLeft(2, '0');
    final m = n.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
              WaktuTungguCard(menitRata: state.rataTungguMenit.round()),
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
        WaktuTungguCard(menitRata: state.rataTungguMenit.round()),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
            ),
          ),
        ],
      ),
    );
  }
}
