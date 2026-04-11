import 'package:go_router/go_router.dart';
import 'presentation/{{name}}_page.dart';

GoRoute {{name.camelCase()}}Route = GoRoute(
  path: '/{{name}}',
  name: '{{name}}',
  builder: (context, state) => const {{name.pascalCase()}}Page(),
);