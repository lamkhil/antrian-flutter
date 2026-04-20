import 'package:go_router/go_router.dart';
import 'presentation/kiosk_page.dart';

GoRoute kioskRoute = GoRoute(
  path: '/kiosk',
  name: 'kiosk',
  builder: (context, state) => const KioskPage(),
);
