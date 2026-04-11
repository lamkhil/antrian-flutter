import 'package:go_router/go_router.dart';
import 'presentation/antrian_page.dart';

GoRoute antrianRoute = GoRoute(
  path: '/antrian',
  name: 'antrian',
  builder: (context, state) => const AntrianPage(),
);