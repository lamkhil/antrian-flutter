import 'dart:io';
import 'package:mason/mason.dart';

void run(HookContext context) {
  final snake = context.vars['name_snake'] as String;
  final pascal = _pascal(context.vars['name'] as String);

  final config = File('lib/core/filament/panel_config.dart');
  if (!config.existsSync()) {
    context.logger.warn('panel_config.dart belum ada — lewati auto-register.');
    return;
  }

  final content = config.readAsStringSync();
  final importLine = "import '../../features/$snake/${snake}_page.dart';";
  final pageLine = '    const ${pascal}Page(),';

  if (content.contains(importLine)) return;

  final updated = content
      .replaceFirst(
        '// filament:imports',
        '// filament:imports\n$importLine',
      )
      .replaceFirst(
        '// filament:pages-begin',
        '// filament:pages-begin\n$pageLine',
      );

  config.writeAsStringSync(updated);
  context.logger.info('Page ${pascal}Page terdaftar di Panel.');
}

String _pascal(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

