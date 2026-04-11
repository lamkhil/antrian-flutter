import 'dart:developer';

import 'package:antrian/globals/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  final bool collapsed;
  final VoidCallback? onClose;

  const AppSidebar({super.key, this.collapsed = false, this.onClose});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? 60 : 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Brand(collapsed: collapsed),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 6 : 10,
                vertical: 8,
              ),
              children: [
                if (!collapsed)
                  _NavSection(
                    label: 'Main',
                    collapsed: collapsed,
                    items: _mainItems,
                  )
                else
                  ..._mainItems.map(
                    (item) => _NavItem(
                      icon: item.icon,
                      label: item.label,
                      route: item.route,
                      badge: item.badge,
                      collapsed: collapsed,
                    ),
                  ),
                const SizedBox(height: 8),
                if (!collapsed)
                  _NavSection(
                    label: 'Sistem',
                    collapsed: collapsed,
                    items: _sistemItems,
                  )
                else
                  ..._sistemItems.map(
                    (item) => _NavItem(
                      icon: item.icon,
                      label: item.label,
                      route: item.route,
                      collapsed: collapsed,
                    ),
                  ),
              ],
            ),
          ),
          _UserFooter(collapsed: collapsed),
        ],
      ),
    );
  }

  static final _mainItems = [
    _NavItemData(icon: Icons.grid_view_rounded, label: 'Dashboard', route: '/'),
    _NavItemData(
      icon: Icons.location_city_rounded,
      label: 'Zona',
      route: '/zona',
    ),
    _NavItemData(
      icon: Icons.layers_rounded,
      label: 'Layanan',
      route: '/layanan',
    ),
    _NavItemData(
      icon: Icons.confirmation_number_rounded,
      label: 'Antrian',
      route: '/antrian',
    ),
  ];

  static final _sistemItems = [
    _NavItemData(
      icon: Icons.people_alt_rounded,
      label: 'Pengguna',
      route: '/pengguna',
    ),
    _NavItemData(
      icon: Icons.bar_chart_rounded,
      label: 'Laporan',
      route: '/laporan',
    ),
    _NavItemData(
      icon: Icons.settings_rounded,
      label: 'Pengaturan',
      route: '/pengaturan',
    ),
  ];
}

// ── Data model ────────────────────────────────────────────

class _NavItemData {
  final IconData icon;
  final String label;
  final String route;
  final String? badge;

  const _NavItemData({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
  });
}

// ── Brand ─────────────────────────────────────────────────

class _Brand extends StatelessWidget {
  final bool collapsed;

  const _Brand({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.confirmation_number_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Antrian',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'Admin Panel',
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Nav section ───────────────────────────────────────────

class _NavSection extends StatelessWidget {
  final String label;
  final bool collapsed;
  final List<_NavItemData> items;

  const _NavSection({
    required this.label,
    required this.collapsed,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!collapsed)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.7,
              ),
            ),
          ),
        ...items.map(
          (item) => _NavItem(
            icon: item.icon,
            label: item.label,
            route: item.route,
            badge: item.badge,
            collapsed: collapsed,
          ),
        ),
      ],
    );
  }
}

// ── Nav item ──────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String? badge;
  final bool collapsed;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    String currentRoute = '.';
    try {
      currentRoute = GoRouterState.of(context).matchedLocation;
    } catch (e) {
      log('Transition triggerd');
    }
    bool isActive = currentRoute.startsWith(route);
    if (route == '/' && currentRoute != '/') {
      isActive = false;
    }

    final item = InkWell(
      onTap: () => context.replace(route),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: collapsed ? 0 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: collapsed
            ? Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: isActive
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF6B7280),
                ),
              )
            : Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isActive
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w500
                            : FontWeight.normal,
                        color: isActive
                            ? const Color(0xFF4338CA)
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );

    // Tooltip saat collapsed
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Tooltip(message: label, preferBelow: false, child: item),
      );
    }

    return Padding(padding: const EdgeInsets.only(bottom: 1), child: item);
  }
}

// ── User footer ───────────────────────────────────────────

class _UserFooter extends StatelessWidget {
  final bool collapsed;

  const _UserFooter({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(collapsed ? 8 : 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
      ),
      child: collapsed
          ? Center(
              child: Tooltip(
                message: 'Admin — Super Admin',
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Text(
                    'AD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                ),
              ),
            )
          : InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
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
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            'Super Admin',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.expand_more_rounded,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
