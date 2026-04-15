import 'package:go_router/go_router.dart';

/// mason:imports
import '../../features/loket/loket_route.dart';
import '../../features/pengaturan/pengaturan_route.dart';
import '../../features/laporan/laporan_route.dart';
import '../../features/pengguna/pengguna_route.dart';
import '../../features/antrian/antrian_route.dart';
import '../../features/layanan/layanan_route.dart';
import '../../features/zona/zona_route.dart';
import '../../features/home/home_route.dart';
import '../../features/login/login_route.dart';
import '../../features/kiosk/kiosk_route.dart';
import '../../features/display/display_route.dart';

final List<GoRoute> appRoutes = [
  /// mason:routes
  loketRoute,
  pengaturanRoute,
  laporanRoute,
  penggunaRoute,
  antrianRoute,
  layananRoute,
  layananDetailRoute,
  zonaRoute,
  zonaDetailRoute,
  homeRoute,
  loginRoute,
  kioskRoute,
  displayRoute,
];
