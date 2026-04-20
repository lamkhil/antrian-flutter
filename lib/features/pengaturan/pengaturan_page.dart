import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

class PengaturanPage extends FilamentPage {
  const PengaturanPage({super.key});

  @override String get slug => 'pengaturan';
  @override String get title => 'Pengaturan';
  @override String? get subtitle => 'Konfigurasi umum aplikasi';
  @override IconData get icon => Icons.settings_outlined;
  @override String? get navigationGroup => 'Sistem';
  @override int get navigationSort => 90;

  @override
  Widget buildBody(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Umum',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Halaman ini menjadi placeholder untuk pengaturan aplikasi '
            '(branding, tema, default lokasi, jam operasional, dll).',
            style: TextStyle(color: theme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.palette_outlined,
            label: 'Tema',
            value: 'Amber (default)',
          ),
          _InfoRow(
            icon: Icons.language,
            label: 'Bahasa',
            value: 'id_ID',
          ),
          _InfoRow(
            icon: Icons.storage_outlined,
            label: 'Backend',
            value: 'Cloud Firestore',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
            ),
          ),
          Text(value, style: TextStyle(color: theme.textPrimary)),
        ],
      ),
    );
  }
}
