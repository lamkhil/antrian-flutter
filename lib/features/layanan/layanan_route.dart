import 'package:go_router/go_router.dart';
import 'presentation/layanan_page.dart';

GoRoute layananRoute = GoRoute(
  path: '/layanan',
  name: 'layanan',
  builder: (context, state) => const LayananPage(),
);