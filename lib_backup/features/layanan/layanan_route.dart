import 'package:go_router/go_router.dart';
import 'presentation/layanan_detail_page.dart';
import 'presentation/layanan_page.dart';

GoRoute layananRoute = GoRoute(
  path: '/layanan',
  name: 'layanan',
  builder: (context, state) => const LayananPage(),
);

GoRoute layananDetailRoute = GoRoute(
  path: '/layanan/:id',
  name: 'layanan-detail',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return LayananDetailPage(id: id);
  },
);
