import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_auth_state.dart';
import '../../data/lookup_cache.dart';
import '../../models/app_user.dart';
import '_widgets.dart';

class CounterProfilePage extends ConsumerStatefulWidget {
  const CounterProfilePage({super.key});

  @override
  ConsumerState<CounterProfilePage> createState() =>
      _CounterProfilePageState();
}

class _CounterProfilePageState extends ConsumerState<CounterProfilePage> {
  final _nameCtrl = TextEditingController();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  String? _selectedCounterId;
  bool _saving = false;
  bool _changingPassword = false;
  String? _passwordMessage;
  String? _passwordError;
  bool _initialized = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    super.dispose();
  }

  void _hydrate(AppUser user) {
    if (_initialized) return;
    _nameCtrl.text = user.name;
    _selectedCounterId = user.counterId;
    _initialized = true;
  }

  Future<void> _saveProfile(AppUser user) async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'name': _nameCtrl.text.trim(),
        if (_selectedCounterId != null) 'counterId': _selectedCounterId,
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil disimpan')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    setState(() {
      _changingPassword = true;
      _passwordError = null;
      _passwordMessage = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(
            code: 'no-user', message: 'Sesi tidak valid');
      }
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPwCtrl.text,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPwCtrl.text);
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      setState(() => _passwordMessage = 'Password berhasil diganti');
    } on FirebaseAuthException catch (e) {
      setState(() => _passwordError = e.message ?? 'Gagal mengganti password');
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(appAuthStateProvider);
    return ListenableBuilder(
      listenable: auth,
      builder: (ctx, _) {
        final user = auth.user;
        if (user == null) {
          return const CounterShell(
            child: Center(
              child: CircularProgressIndicator(color: kAccentLight),
            ),
          );
        }
        _hydrate(user);
        final counters = LookupCache.instance.counters;
        return CounterShell(
          child: Column(
            children: [
              CounterTopbar(
                title: 'Profil',
                onBack: () => context.go('/counter'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionTitle(text: 'Informasi Akun'),
                          const SizedBox(height: 10),
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  initialValue: user.email,
                                  readOnly: true,
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 14),
                                  decoration: darkInputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icons.mail_outline_rounded,
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _nameCtrl,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  decoration: darkInputDecoration(
                                    labelText: 'Nama',
                                    prefixIcon: Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _DarkDropdown(
                                  value: _selectedCounterId,
                                  items: [
                                    for (final c in counters)
                                      DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                  ],
                                  decoration: darkInputDecoration(
                                    labelText: 'Loket',
                                    prefixIcon:
                                        Icons.point_of_sale_outlined,
                                  ),
                                  onChanged: (v) =>
                                      setState(() => _selectedCounterId = v),
                                ),
                                const SizedBox(height: 18),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GradientButton(
                                    label:
                                        _saving ? 'Menyimpan…' : 'Simpan',
                                    icon: Icons.save_outlined,
                                    onPressed:
                                        _saving ? null : () => _saveProfile(user),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SectionTitle(text: 'Ganti Password'),
                          const SizedBox(height: 10),
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _currentPwCtrl,
                                  obscureText: _obscureCurrent,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  decoration: darkInputDecoration(
                                    labelText: 'Password Saat Ini',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: _eyeToggle(
                                      obscured: _obscureCurrent,
                                      onTap: () => setState(() =>
                                          _obscureCurrent = !_obscureCurrent),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _newPwCtrl,
                                  obscureText: _obscureNew,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  decoration: darkInputDecoration(
                                    labelText: 'Password Baru',
                                    prefixIcon: Icons.lock_reset_rounded,
                                    helperText: 'Minimal 6 karakter.',
                                    suffixIcon: _eyeToggle(
                                      obscured: _obscureNew,
                                      onTap: () => setState(
                                          () => _obscureNew = !_obscureNew),
                                    ),
                                  ),
                                ),
                                if (_passwordError != null) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    _passwordError!,
                                    style: const TextStyle(
                                        color: Color(0xFFFC8181),
                                        fontSize: 12),
                                  ),
                                ],
                                if (_passwordMessage != null) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Color(0xFF34D399), size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        _passwordMessage!,
                                        style: const TextStyle(
                                            color: Color(0xFF34D399),
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 18),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GhostButton(
                                    label: _changingPassword
                                        ? 'Memproses…'
                                        : 'Ganti Password',
                                    icon: Icons.password_rounded,
                                    color: kAccentLight,
                                    onPressed: _changingPassword
                                        ? null
                                        : _changePassword,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _eyeToggle({required bool obscured, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          obscured
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.white38,
          size: 20,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kAccentLight,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// Dropdown styled untuk dark theme — input field dark, menu pop-up juga
/// dark dengan teks putih.
class _DarkDropdown extends StatelessWidget {
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final InputDecoration decoration;
  final ValueChanged<String?> onChanged;

  const _DarkDropdown({
    required this.value,
    required this.items,
    required this.decoration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: decoration,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      iconEnabledColor: Colors.white54,
      dropdownColor: const Color(0xFF1A1438),
      items: items,
      onChanged: onChanged,
    );
  }
}
