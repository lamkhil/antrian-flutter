import 'package:go_router/go_router.dart';
import 'presentation/laporan_page.dart';

GoRoute laporanRoute = GoRoute(
  path: '/laporan',
  name: 'laporan',
  builder: (context, state) => const LaporanPage(),
);