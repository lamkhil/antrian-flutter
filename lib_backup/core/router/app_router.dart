import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:antrian/globals/app_navigator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'router_refresh_notifier.dart';
import 'routes_registry.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = RouterRefreshNotifier();

  return GoRouter(
    navigatorKey: AppNavigator.key,
    initialLocation: '/',
    routes: appRoutes,

    // 🔥 ini yang bikin dia reactive ke auth
    refreshListenable: refreshNotifier,

    // 🔥 ini middleware-nya
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;

      final loc = state.matchedLocation;
      final isLogin = loc == '/login';
      // Kiosk & layar display boleh diakses tanpa login (mesin publik).
      final isPublic = loc == '/kiosk' || loc.startsWith('/display');

      // belum login → paksa ke login, kecuali halaman publik
      if (user == null && !isLogin && !isPublic) {
        return '/login';
      }

      // sudah login → jangan balik ke login
      if (user != null && isLogin) {
        return '/';
      }

      return null;
    },
  );
}
