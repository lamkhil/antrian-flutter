import 'package:antrian/features/zona/presentation/zona_detail_page.dart';
import 'package:go_router/go_router.dart';
import 'presentation/zona_page.dart';

GoRoute zonaRoute = GoRoute(
  path: '/zona',
  name: 'zona',
  builder: (context, state) => const ZonaPage(),
);

GoRoute zonaDetailRoute = GoRoute(
  path: '/zona/:id',
  name: 'zona-detail',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ZonaDetailPage(id: id);
  },
);
