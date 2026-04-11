import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/loket_controller.dart';

class LoketPage extends ConsumerWidget {
  const LoketPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(loketControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Loket')),
      body: Center(
        child: Text(
          'Value: $value',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(loketControllerProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}