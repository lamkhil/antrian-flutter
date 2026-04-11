import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/{{name}}_controller.dart';

class {{name.pascalCase()}}Page extends ConsumerWidget {
  const {{name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch({{name.camelCase()}}ControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('{{name.pascalCase()}}')),
      body: Center(
        child: Text(
          'Value: $value',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read({{name.camelCase()}}ControllerProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}