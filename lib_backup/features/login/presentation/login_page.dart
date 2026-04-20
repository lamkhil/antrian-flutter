import 'dart:ui';
import 'package:antrian/globals/widgets/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antrian/extension/size.dart';
import '../application/login_controller.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = context.isDesktop;

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
            // Ambient glow blobs
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
            // Content
            SafeArea(
              child: Center(
                child: isDesktop
                    ? _desktopLayout(context, ref)
                    : _mobileLayout(context, ref),
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
          colors: [color.withOpacity(0.25), Colors.transparent],
        ),
      ),
    );
  }

  // ── Layouts ──────────────────────────────────────────────

  Widget _mobileLayout(BuildContext context, WidgetRef ref) {
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
          _formCard(context, ref),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _desktopLayout(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Left — hero panel
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
        // Right — form panel
        Container(
          width: 440,
          height: double.infinity,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border(
              left: BorderSide(color: Colors.white.withOpacity(0.07)),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _brandBadge(),
              const SizedBox(height: 24),
              _headerText(),
              const SizedBox(height: 36),
              _formFields(ref),
            ],
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
        color: const Color(0xFF6366F1).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.35)),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
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

  Widget _formCard(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: _formFields(ref),
        ),
      ),
    );
  }

  Widget _formFields(WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);
    final notifier = ref.read(loginControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel('Email'),
        const SizedBox(height: 6),
        _input(
          hint: 'you@example.com',
          prefixIcon: Icons.mail_outline_rounded,
          onChanged: notifier.setEmail,
          errorText: state.error,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _fieldLabel('Password'),
        const SizedBox(height: 6),
        _input(
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          onChanged: notifier.setPassword,
          obscure: state.obscurePass,
          suffix: GestureDetector(
            onTap: notifier.togglePassword,
            child: Icon(
              state.obscurePass
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
            onPressed: () {
              AppDialog.basic(
                title: "Lupa Password",
                message:
                    "Silakan hubungi administrator untuk mereset password Anda.",
                positiveText: "Oke",
              );
            },
            child: const Text(
              'Lupa password?',
              style: TextStyle(color: Color(0xFF818CF8), fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _signInButton(ref),
        const SizedBox(height: 20),
        // _divider(),
        // const SizedBox(height: 16),
        // _socialButtons(),
        // const SizedBox(height: 20),
        // Center(
        //   child: RichText(
        //     text: const TextSpan(
        //       style: TextStyle(color: Colors.white38, fontSize: 13),
        //       children: [
        //         TextSpan(text: "Don't have an account? "),
        //         TextSpan(
        //           text: 'Sign up',
        //           style: TextStyle(
        //             color: Color(0xFF818CF8),
        //             fontWeight: FontWeight.w500,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
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
    required String hint,
    required IconData prefixIcon,
    Function(String)? onChanged,
    bool obscure = false,
    Widget? suffix,
    String? errorText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      obscureText: obscure,
      onChanged: onChanged,
      keyboardType: keyboardType,
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
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFC8181)),
        ),
      ),
    );
  }

  Widget _signInButton(WidgetRef ref) {
    final isLoading = ref.watch(loginControllerProvider).isLoading;
    final notifier = ref.read(loginControllerProvider.notifier);

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
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : notifier.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
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

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
      ],
    );
  }

  Widget _socialButtons() {
    return Row(
      children: [
        Expanded(child: _socialBtn('G', 'Google')),
        const SizedBox(width: 12),
        Expanded(child: _socialBtn('', 'Apple')),
      ],
    );
  }

  Widget _socialBtn(String icon, String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white.withOpacity(0.04),
      ),
      child: Text(
        '$icon  $label',
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
