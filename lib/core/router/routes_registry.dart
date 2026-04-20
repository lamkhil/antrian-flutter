import 'package:go_router/go_router.dart';
import '../../features/display/display_route.dart';
import '../../features/kiosk/kiosk_route.dart';
import '../../features/login/login_route.dart';
import '../filament/panel_config.dart';

/// Flat list of all GoRoutes. Most routes come from [adminPanel.buildRoutes()]
/// (dashboard, resources, custom FilamentPages). Login/kiosk/display live
/// outside the panel because they are either public kiosks or the auth gate.
final List<GoRoute> appRoutes = [
  ...adminPanel.buildRoutes(),
  loginRoute,
  kioskRoute,
  displayRoute,
];
