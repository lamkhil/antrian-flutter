import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/antrian_controller.dart';

class AntrianPage extends ConsumerWidget {
  const AntrianPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(antrianControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Antrian')),
      body: Center(
        child: Text(
          'Value: $value',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(antrianControllerProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}