import 'package:mason/mason.dart';

void run(HookContext context) {
  final name = (context.vars['name'] as String? ?? '').trim();
  final group = (context.vars['group'] as String? ?? '').trim();
  context.vars = {
    ...context.vars,
    'name_snake': _snake(name),
    'has_group': group.isNotEmpty,
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
