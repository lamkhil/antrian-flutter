import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

import '../../data/services/admin/admin_sdk.dart';
import '../../data/services/admin/service_account_storage.dart';
import '../../globals/widgets/app_dialog.dart';
import '../pengguna/widgets/service_account_setup_dialog.dart';

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
    return const _PengaturanBody();
  }
}

class _PengaturanBody extends StatefulWidget {
  const _PengaturanBody();

  @override
  State<_PengaturanBody> createState() => _PengaturanBodyState();
}

class _PengaturanBodyState extends State<_PengaturanBody> {
  bool _configured = false;
  String? _projectId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final data = await ServiceAccountStorage.readJson();
    if (!mounted) return;
    setState(() {
      _configured = data != null;
      _projectId = data?['project_id'] as String?;
      _loading = false;
    });
  }

  Future<void> _upload() async {
    final saved = await ServiceAccountSetupDialog.show();
    if (saved == true) {
      AdminSdk.reset();
      await _refresh();
    }
  }

  Future<void> _revoke() async {
    final confirm = await AppDialog.warning(
      message:
          'Hapus service account dari perangkat ini? Fitur manajemen '
          'user (tambah/ubah/hapus/reset password) tidak akan berfungsi '
          'sampai file di-upload ulang.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
    );
    if (confirm != true) return;
    await ServiceAccountStorage.clear();
    AdminSdk.reset();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
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
              const _InfoRow(
                icon: Icons.palette_outlined,
                label: 'Tema',
                value: 'Amber (default)',
              ),
              const _InfoRow(
                icon: Icons.language,
                label: 'Bahasa',
                value: 'id_ID',
              ),
              const _InfoRow(
                icon: Icons.storage_outlined,
                label: 'Backend',
                value: 'Cloud Firestore',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Card(child: _buildServiceAccountSection(theme)),
      ],
    );
  }

  Widget _buildServiceAccountSection(FilamentTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.vpn_key_outlined, color: theme.colors.primary),
            const SizedBox(width: 8),
            Text(
              'Firebase Admin SDK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Dipakai untuk manajemen user (tambah/ubah/hapus/reset password). '
          'Upload file serviceAccount.json dari Google Cloud Console. File '
          'disimpan terenkripsi di perangkat ini saja.',
          style: TextStyle(color: theme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          _StatusPill(
            configured: _configured,
            projectId: _projectId,
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _loading ? null : _upload,
              icon: Icon(
                _configured ? Icons.refresh : Icons.upload_file_outlined,
              ),
              label: Text(_configured ? 'Ganti file' : 'Upload file'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colors.primary,
              ),
            ),
            const SizedBox(width: 8),
            if (_configured)
              OutlinedButton.icon(
                onPressed: _loading ? null : _revoke,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colors.danger,
                  side: BorderSide(color: theme.colors.danger),
                ),
              ),
          ],
        ),
        if (!ServiceAccountStorage.isSupportedPlatform) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Color(0xFFB45309),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fitur Admin SDK tidak didukung di Web. Buka aplikasi '
                    'dari desktop atau mobile untuk manajemen user.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool configured;
  final String? projectId;
  const _StatusPill({required this.configured, this.projectId});

  @override
  Widget build(BuildContext context) {
    final bg = configured ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final fg = configured ? const Color(0xFF065F46) : const Color(0xFF991B1B);
    final dot = configured ? const Color(0xFF059669) : const Color(0xFFEF4444);
    final text = configured
        ? 'Terpasang${projectId != null ? ' — $projectId' : ''}'
        : 'Belum di-upload';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = FilamentThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.borderRadius),
      ),
      child: child,
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
