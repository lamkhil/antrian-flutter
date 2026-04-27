import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/lookup_cache.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      // Router redirect akan memindahkan ke /admin atau /counter sesuai role.
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Gagal masuk');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showForgotPasswordDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lupa Password'),
        content: const Text(
          'Silakan hubungi administrator untuk mereset password Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Oke'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0A2E), Color(0xFF130E3A), Color(0xFF0A0820)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -80,
              child: _glowBlob(const Color(0xFF6366F1), 300),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: _glowBlob(const Color(0xFF8B5CF6), 250),
            ),
            SafeArea(
              child: Center(
                child: isDesktop ? _desktopLayout() : _mobileLayout(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.25), Colors.transparent],
        ),
      ),
    );
  }

  // ── Layouts ──────────────────────────────────────────────

  Widget _mobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _brandBadge(),
          const SizedBox(height: 24),
          _headerText(),
          const SizedBox(height: 32),
          _formCard(),
          const SizedBox(height: 20),
          _publicShortcuts(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _brandBadge(),
                const SizedBox(height: 32),
                const Text(
                  'Manage your\nqueue smarter',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Streamline operations and deliver\na better customer experience.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white38,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  children: [
                    _statChip('98%', 'Uptime'),
                    const SizedBox(width: 16),
                    _statChip('100%', 'Satisfaction'),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 440,
          height: double.infinity,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            border: Border(
              left: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _brandBadge(),
                const SizedBox(height: 24),
                _headerText(),
                const SizedBox(height: 36),
                _formFields(),
                const SizedBox(height: 24),
                _publicShortcuts(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Reusable pieces ───────────────────────────────────────

  Widget _brandBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.35)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: Color(0xFF818CF8)),
          SizedBox(width: 6),
          Text(
            'Antrian App',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFA5B4FC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang kembali!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Masuk ke akun Anda untuk melanjutkan',
          style: TextStyle(fontSize: 14, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _statChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  // ── Form ─────────────────────────────────────────────────

  Widget _formCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: _formFields(),
        ),
      ),
    );
  }

  Widget _formFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel('Email'),
        const SizedBox(height: 6),
        _input(
          controller: _emailCtrl,
          hint: 'you@example.com',
          prefixIcon: Icons.mail_outline_rounded,
          errorText: _error,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _fieldLabel('Password'),
        const SizedBox(height: 6),
        _input(
          controller: _passwordCtrl,
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          obscure: _obscurePass,
          onSubmitted: (_) => _submit(),
          suffix: GestureDetector(
            onTap: () => setState(() => _obscurePass = !_obscurePass),
            child: Icon(
              _obscurePass
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white38,
              size: 20,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordDialog,
            child: const Text(
              'Lupa password?',
              style: TextStyle(color: Color(0xFF818CF8), fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _signInButton(),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white54,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscure = false,
    Widget? suffix,
    String? errorText,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: Colors.white30, size: 18),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        errorText: errorText,
        errorStyle: const TextStyle(color: Color(0xFFFC8181), fontSize: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFC8181)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFC8181), width: 1.5),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Masuk',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Public shortcuts ─────────────────────────────────────

  Future<void> _pickZoneAndOpenDisplay() async {
    final zones = LookupCache.instance.zones;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF130E3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih tampilan zona',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _zoneTile(
                      ctx,
                      icon: Icons.grid_view_rounded,
                      title: 'Semua Zona',
                      subtitle: 'Tampilkan seluruh loket',
                      value: '',
                    ),
                    if (zones.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Belum ada zona terdaftar.',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      )
                    else
                      ...zones.map(
                        (z) => _zoneTile(
                          ctx,
                          icon: Icons.location_on_outlined,
                          title: z.name,
                          subtitle: z.description?.isNotEmpty == true
                              ? z.description
                              : null,
                          value: z.id,
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) return;
    if (selected.isEmpty) {
      context.go('/display');
    } else {
      context.go('/display/zone/$selected');
    }
  }

  Widget _zoneTile(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    String? subtitle,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFA5B4FC)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white38,
      ),
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  Widget _publicShortcuts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'atau buka layar publik',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _publicShortcutBtn(
                icon: Icons.tv_rounded,
                label: 'Tampilan Zona',
                onTap: _pickZoneAndOpenDisplay,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _publicShortcutBtn(
                icon: Icons.point_of_sale_rounded,
                label: 'Kios',
                onTap: () => context.go('/kiosk'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _publicShortcutBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: const Color(0xFFA5B4FC)),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white.withValues(alpha: 0.04),
      ),
    );
  }
}
