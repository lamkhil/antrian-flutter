import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/lookup_cache.dart';
import '../../models/counter.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Loket'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: counters.isEmpty
          ? const Center(child: Text('Belum ada loket terdaftar.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: counters.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final c = counters[i];
                final services = c.serviceIds
                    .map(LookupCache.instance.serviceName)
                    .join(', ');
                final loading = _saving == c.id;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.point_of_sale_outlined,
                        size: 32),
                    title: Text(c.name,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      services.isEmpty ? 'Belum ada layanan' : services,
                    ),
                    trailing: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: loading ? null : () => _pick(c),
                  ),
                );
              },
            ),
    );
  }
}
