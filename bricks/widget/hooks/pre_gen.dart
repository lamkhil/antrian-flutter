import 'package:mason/mason.dart';

void run(HookContext context) {
  final name = (context.vars['name'] as String? ?? '').trim();
  final type = context.vars['type'] as String? ?? 'stat';
  context.vars = {
    ...context.vars,
    'name_snake': _snake(name),
    'is_stat': type == 'stat',
    'is_chart': type == 'chart',
    'is_custom': type == 'custom',
  };
}

String _snake(String input) {
  final buf = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (c.toUpperCase() == c && c.toLowerCase() != c && i != 0) {
      buf.write('_');
    }
    buf.write(c.toLowerCase());
  }
  return buf.toString();
}
