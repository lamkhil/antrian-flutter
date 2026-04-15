import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/notifikasi.dart';
import 'package:antrian/data/services/notifikasi/notifikasi_services.dart';
import 'package:antrian/extension/size.dart';
import 'package:antrian/globals/providers/lokasi/lokasi_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<String> breadcrumbs;
  final VoidCallback? onMenuTap;

  const AppTopBar({
    super.key,
    required this.title,
    this.breadcrumbs = const [],
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lokasiAktif = ref.watch(lokasiControllerProvider).aktif;

    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Hamburger (mobile)
              if (onMenuTap != null) ...[
                _IconBtn(icon: Icons.menu_rounded, onTap: onMenuTap!),
                const SizedBox(width: 8),
              ],

              // ── Dropdown lokasi ──────────────────────
              _LokasiButton(lokasi: lokasiAktif),

              const Spacer(),

              // Actions kanan
              const _NotifikasiButton(),
              const SizedBox(width: 6),
              _IconBtn(icon: Icons.settings_outlined, onTap: () {}),
              const SizedBox(width: 8),
              const _ProfileButton(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              if (breadcrumbs.isNotEmpty) _Breadcrumb(crumbs: breadcrumbs),
            ],
          ),
        ),
      ],
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  final List<String> crumbs;

  const _Breadcrumb({required this.crumbs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          crumbs.first,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
        for (var crumb in crumbs.skip(1)) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            size: 12,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 4),
          Text(
            crumb,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
          ),
        ],
      ],
    );
  }
}

// ── Lokasi button + dropdown ──────────────────────────────

class _LokasiButton extends ConsumerWidget {
  final Lokasi? lokasi;

  const _LokasiButton({required this.lokasi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showLokasiSheet(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD1D5DB), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              lokasi?.nama ?? 'Pilih Lokasi',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  void _showLokasiSheet(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) => _LokasiDropdown(ref: ref),
    );
  }
}

// ── Dropdown dialog ───────────────────────────────────────

class _LokasiDropdown extends StatelessWidget {
  final WidgetRef ref;

  const _LokasiDropdown({required this.ref});

  @override
  Widget build(BuildContext context) {
    final aktif = ref.watch(lokasiControllerProvider).aktif;

    // Posisikan di bawah topbar
    return Stack(
      children: [
        Positioned(
          top: 60,
          left: context.isMobile ? 20 : 260,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFF3F4F6),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: const Text(
                        'PILIH LOKASI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    // Items
                    ...(ref.watch(lokasiControllerProvider).daftarLokasi).map((
                      lokasi,
                    ) {
                      final isActive = lokasi.id == aktif?.id;
                      return _LokasiItem(
                        lokasi: lokasi,
                        isActive: isActive,
                        onTap: () {
                          ref
                              .read(lokasiControllerProvider.notifier)
                              .setLokasi(lokasi);
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LokasiItem extends StatefulWidget {
  final Lokasi lokasi;
  final bool isActive;
  final VoidCallback onTap;

  const _LokasiItem({
    required this.lokasi,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_LokasiItem> createState() => _LokasiItemState();
}

class _LokasiItemState extends State<_LokasiItem> {
  bool _hovered = false;

  // Warna ikon per lokasi
  static const _iconColors = [
    (Color(0xFFEEF2FF), Color(0xFF6366F1)),
    (Color(0xFFE1F5EE), Color(0xFF1D9E75)),
    (Color(0xFFFAEEDA), Color(0xFFBA7517)),
    (Color(0xFFFAECE7), Color(0xFFD85A30)), // SPP Siwalankerto — coral
  ];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFFF5F3FF)
                : _hovered
                ? const Color(0xFFF9FAFB)
                : Colors.white,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFF3F4F6), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lokasi.nama,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: widget.isActive
                            ? const Color(0xFF4338CA)
                            : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.lokasi.alamat,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              // Checkmark
              if (widget.isActive)
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool badge;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
              ),
              child: Icon(icon, size: 16, color: const Color(0xFF6B7280)),
            ),
            if (badge)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileSheet(context),
      child: const CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFFEEF2FF),
        child: Text(
          'AD',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4338CA),
          ),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) => const _ProfileDropdown(),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 60,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info user
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFFEEF2FF),
                            child: Text(
                              'AD',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4338CA),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Admin Dinas',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'admin@surabaya.go.id',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Super Admin',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4338CA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 0.5, color: Color(0xFFF3F4F6)),
                    _ProfileMenuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profil saya',
                      onTap: () {},
                    ),
                    const Divider(height: 0.5, color: Color(0xFFF3F4F6)),
                    _ProfileMenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Keluar',
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<_ProfileMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive
        ? const Color(0xFFEF4444)
        : const Color(0xFF374151);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF9FAFB) : Colors.white,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFF3F4F6), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 15, color: color),
              const SizedBox(width: 10),
              Text(widget.label, style: TextStyle(fontSize: 13, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget _NotifikasiButton — ganti _IconBtn notifikasi di AppTopBar

class _NotifikasiButton extends StatelessWidget {
  const _NotifikasiButton();

  @override
  Widget build(BuildContext context) {
    final daftarNotifikasi = NotifikasiServices.fetchDummy();
    final belumDibaca = daftarNotifikasi.any((n) => !n.sudahDibaca);

    return GestureDetector(
      onTap: () => _showNotifikasiSheet(context),
      child: _IconBtn(
        icon: Icons.notifications_outlined,
        onTap: () => _showNotifikasiSheet(context),
        badge: belumDibaca,
      ),
    );
  }

  void _showNotifikasiSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) => const _NotifikasiDropdown(),
    );
  }
}

class _NotifikasiDropdown extends StatelessWidget {
  const _NotifikasiDropdown();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 60,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFF3F4F6),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'NOTIFIKASI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 0.6,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {}, // TODO: tandai semua dibaca
                            child: const Text(
                              'Tandai semua dibaca',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // List
                    ...NotifikasiServices.fetchDummy().map(
                      (n) => _NotifikasiItem(notifikasi: n),
                    ),
                    // Footer
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: navigasi ke halaman notifikasi
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFFF3F4F6),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Lihat semua notifikasi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotifikasiItem extends StatelessWidget {
  final Notifikasi notifikasi;

  const _NotifikasiItem({required this.notifikasi});

  static const _config = {
    TipeNotifikasi.info: (
      Color(0xFFEEF2FF),
      Color(0xFF6366F1),
      Icons.group_outlined,
    ),
    TipeNotifikasi.warning: (
      Color(0xFFFEF3C7),
      Color(0xFFD97706),
      Icons.warning_amber_rounded,
    ),
    TipeNotifikasi.success: (
      Color(0xFFECFDF5),
      Color(0xFF059669),
      Icons.check_rounded,
    ),
    TipeNotifikasi.danger: (
      Color(0xFFFEE2E2),
      Color(0xFFEF4444),
      Icons.close_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (iconBg, iconColor, icon) = _config[notifikasi.tipe]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: notifikasi.sudahDibaca ? Colors.white : const Color(0xFFF5F3FF),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notifikasi.judul,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notifikasi.deskripsi,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  notifikasi.waktu,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
              ],
            ),
          ),
          if (!notifikasi.sudahDibaca)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
