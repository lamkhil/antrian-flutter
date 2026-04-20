import 'package:go_router/go_router.dart';
import 'presentation/login_page.dart';

GoRoute loginRoute = GoRoute(
  path: '/login',
  name: 'login',
  builder: (context, state) => const LoginPage(),
);