import 'package:mason/mason.dart';

/// Parses the `fields` string ("nama:String, harga:int, aktif:bool")
/// into a list of {name, type, isString, isNum, isBool, isDate, dartDefault}
/// entries so the Mustache template can render each field block.
void run(HookContext context) {
  final raw = (context.vars['fields'] as String? ?? '').trim();
  final nameRaw = (context.vars['name'] as String? ?? '').trim();

  final fields = <Map<String, dynamic>>[];
  if (raw.isNotEmpty) {
    for (final part in raw.split(',')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final tokens = trimmed.split(':');
      final n = tokens[0].trim();
      final t = tokens.length > 1 ? tokens[1].trim() : 'String';
      fields.add({
        'name': n,
        'type': t,
        'nullable_type': t.endsWith('?') ? t : '$t?',
        'is_string': t == 'String' || t == 'String?',
        'is_int': t == 'int' || t == 'int?',
        'is_double': t == 'double' || t == 'double?',
        'is_num': t == 'num' || t == 'num?',
        'is_bool': t == 'bool' || t == 'bool?',
        'is_datetime': t == 'DateTime' || t == 'DateTime?',
      });
    }
  }

  final snake = _snake(nameRaw);
  context.vars = {
    ...context.vars,
    'name': nameRaw,
    'name_snake': snake,
    'fields_list': fields,
    'has_fields': fields.isNotEmpty,
    'has_datetime': fields.any((f) => f['is_datetime'] == true),
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
