import 'package:go_router/go_router.dart';
import 'presentation/pengaturan_page.dart';

GoRoute pengaturanRoute = GoRoute(
  path: '/pengaturan',
  name: 'pengaturan',
  builder: (context, state) => const PengaturanPage(),
);