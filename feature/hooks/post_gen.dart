import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) {
  final name = context.vars['name']; // nama feature
  final registryFile = File('lib/core/router/routes_registry.dart');

  if (!registryFile.existsSync()) {
    context.logger.err('routes_registry.dart not found');
    return;
  }

  final content = registryFile.readAsStringSync();

  final importLine = "import '../../features/$name/${name}_route.dart';";
  final routeLine = "  ${name}Route,";

  if (!content.contains(importLine)) {
    final updated = content
        .replaceFirst('/// mason:imports', '/// mason:imports\n$importLine')
        .replaceFirst('/// mason:routes', '/// mason:routes\n$routeLine');

    registryFile.writeAsStringSync(updated);
  }

  context.logger.info('✅ Route $name registered');
}
