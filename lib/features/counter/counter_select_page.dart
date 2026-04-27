import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/lookup_cache.dart';
import '../../models/counter.dart';
import '_widgets.dart';

class CounterSelectPage extends ConsumerStatefulWidget {
  const CounterSelectPage({super.key});

  @override
  ConsumerState<CounterSelectPage> createState() => _CounterSelectPageState();
}

class _CounterSelectPageState extends ConsumerState<CounterSelectPage> {
  String? _saving;

  Future<void> _pick(Counter counter) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = counter.id);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'counterId': counter.id}, SetOptions(merge: true));
      // Router redirect handles navigation once user doc updates.
    } finally {
      if (mounted) setState(() => _saving = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final counters = LookupCache.instance.counters;
    return CounterShell(
      child: Column(
        children: [
          CounterTopbar(
            badgeLabel: 'Antrian App',
            actions: [
              IconButton(
                tooltip: 'Keluar',
                color: Colors.white70,
                hoverColor: Colors.white.withValues(alpha: 0.06),
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Pilih Loket',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Loket yang Anda pilih akan tersimpan di profil Anda.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      if (counters.isEmpty)
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 16),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    color: Colors.white24, size: 36),
                                SizedBox(height: 8),
                                Text(
                                  'Belum ada loket terdaftar.',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 13),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Hubungi administrator untuk membuat loket.',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        for (final c in counters) ...[
                          _LoketTile(
                            counter: c,
                            loading: _saving == c.id,
                            disabled: _saving != null && _saving != c.id,
                            onTap: () => _pick(c),
                          ),
                          const SizedBox(height: 10),
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoketTile extends StatelessWidget {
  final Counter counter;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _LoketTile({
    required this.counter,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final services = counter.serviceIds
        .map(LookupCache.instance.serviceName)
        .where((s) => s != '-')
        .join(', ');

    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: (loading || disabled) ? null : onTap,
          child: GlassCard(
            radius: 16,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kAccentStart.withValues(alpha: 0.25),
                        kAccentEnd.withValues(alpha: 0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: kAccentStart.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.point_of_sale_outlined,
                      color: kAccentLight, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        counter.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        services.isEmpty
                            ? 'Belum ada layanan'
                            : services,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kAccentLight,
                    ),
                  )
                else
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
