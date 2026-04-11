import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/laporan_controller.dart';

class LaporanPage extends ConsumerWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(laporanControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: Center(
        child: Text(
          'Value: $value',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(laporanControllerProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}