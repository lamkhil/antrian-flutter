import 'package:go_router/go_router.dart';
import 'presentation/pengguna_page.dart';

GoRoute penggunaRoute = GoRoute(
  path: '/pengguna',
  name: 'pengguna',
  builder: (context, state) => const PenggunaPage(),
);