import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/pengaturan_controller.dart';

class PengaturanPage extends ConsumerWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(pengaturanControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Center(
        child: Text(
          'Value: $value',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(pengaturanControllerProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}