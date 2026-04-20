import 'package:go_router/go_router.dart';
import 'presentation/loket_page.dart';

GoRoute loketRoute = GoRoute(
  path: '/loket',
  name: 'loket',
  builder: (context, state) => const LoketPage(),
);