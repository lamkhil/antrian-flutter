import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../globals/app_navigator.dart';
import 'router_refresh_notifier.dart';
import 'routes_registry.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshNotifier();
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: AppNavigator.key,
    initialLocation: '/',
    routes: appRoutes,
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loc = state.matchedLocation;
      final isLogin = loc == '/login';
      // Kiosk & display publik (mesin antrian) boleh diakses tanpa login.
      final isPublic = loc == '/kiosk' || loc.startsWith('/display');

      if (user == null && !isLogin && !isPublic) return '/login';
      if (user != null && isLogin) return '/admin';
      return null;
    },
  );
});
