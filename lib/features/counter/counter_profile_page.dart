import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_auth_state.dart';
import '../../data/lookup_cache.dart';
import '../../models/app_user.dart';

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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set({
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        _hydrate(user);
        final counters = LookupCache.instance.counters;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/counter'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
                    title: 'Informasi Akun',
                    children: [
                      TextFormField(
                        initialValue: user.email,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCounterId,
                        decoration: const InputDecoration(
                          labelText: 'Loket',
                          border: OutlineInputBorder(),
                        ),
                        items: counters
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCounterId = v),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _saving ? null : () => _saveProfile(user),
                        child: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Simpan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Ganti Password',
                    children: [
                      TextField(
                        controller: _currentPwCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Saat Ini',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPwCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Baru',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_passwordError != null) ...[
                        const SizedBox(height: 8),
                        Text(_passwordError!,
                            style: const TextStyle(color: Colors.redAccent)),
                      ],
                      if (_passwordMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(_passwordMessage!,
                            style: const TextStyle(color: Colors.green)),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed:
                            _changingPassword ? null : _changePassword,
                        child: _changingPassword
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                            : const Text('Ganti Password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
