import 'package:mason/mason.dart';

void run(HookContext context) {
  final raw = (context.vars['fields'] as String? ?? '').trim();
  final nameRaw = (context.vars['name'] as String? ?? '').trim();
  final group = (context.vars['group'] as String? ?? '').trim();

  final fields = <Map<String, dynamic>>[];
  if (raw.isNotEmpty) {
    for (final part in raw.split(',')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final tokens = trimmed.split(':');
      final n = tokens[0].trim();
      final t = tokens.length > 1 ? tokens[1].trim() : 'String';
      final bare = t.replaceAll('?', '');
      fields.add({
        'name': n,
        'type': t,
        'nullable_type': t.endsWith('?') ? t : '$t?',
        'is_string': bare == 'String',
        'is_int': bare == 'int',
        'is_double': bare == 'double',
        'is_num': bare == 'num',
        'is_bool': bare == 'bool',
        'is_datetime': bare == 'DateTime',
        'is_numeric': bare == 'int' || bare == 'double' || bare == 'num',
        'allow_decimal': bare == 'double' || bare == 'num',
      });
    }
  }

  final snake = _snake(nameRaw);
  // Inject model_name into each field so it's accessible inside the
  // {{#fields_list}}...{{/fields_list}} scope (where {{name}} shadows
  // the model name with the field name).
  for (final f in fields) {
    f['model_name'] = nameRaw;
    f['field_label'] = _titleCase(f['name'] as String);
    f['field_name'] = f['name'];
  }
  context.vars = {
    ...context.vars,
    'name': nameRaw,
    'name_snake': snake,
    'fields_list': fields,
    'has_fields': fields.isNotEmpty,
    'has_group': group.isNotEmpty,
    'first_field': fields.isNotEmpty ? fields.first['name'] : 'id',
  };
}

String _titleCase(String input) {
  if (input.isEmpty) return input;
  // Split camelCase into words, capitalise each.
  final buf = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (i == 0) {
      buf.write(c.toUpperCase());
    } else if (c.toUpperCase() == c && c.toLowerCase() != c) {
      buf.write(' ');
      buf.write(c);
    } else {
      buf.write(c);
    }
  }
  return buf.toString();
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
