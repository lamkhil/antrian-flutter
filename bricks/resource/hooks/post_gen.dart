import 'dart:io';
import 'package:mason/mason.dart';

/// Registers the new resource in `lib/core/filament/panel_config.dart` between
/// the `// filament:resources-begin` and `// filament:resources-end` markers.
///
/// If the file doesn't exist yet, prints instructions.
void run(HookContext context) {
  final snake = context.vars['name_snake'] as String;
  final pascal = _pascal(context.vars['name'] as String);

  final config = File('lib/core/filament/panel_config.dart');
  if (!config.existsSync()) {
    context.logger
        .warn('panel_config.dart belum ada — lewati auto-register.');
    context.logger.info(
        'Register manual: tambahkan `${pascal}Resource()` ke `resources` di Panel.');
    return;
  }

  final content = config.readAsStringSync();
  final importLine =
      "import '../../features/$snake/${snake}_resource.dart';";
  final resourceLine = '    ${pascal}Resource(),';

  if (content.contains(importLine)) {
    context.logger.info('Resource $pascal sudah terdaftar.');
    return;
  }

  final updated = content
      .replaceFirst(
        '// filament:imports',
        '// filament:imports\n$importLine',
      )
      .replaceFirst(
        '// filament:resources-begin',
        '// filament:resources-begin\n$resourceLine',
      );

  config.writeAsStringSync(updated);
  context.logger.info('Resource ${pascal}Resource terdaftar di Panel.');
}

String _pascal(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

