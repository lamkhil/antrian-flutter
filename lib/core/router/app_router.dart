import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../globals/app_navigator.dart';
import '../filament/panel_config.dart';
import 'router_refresh_notifier.dart';
import 'routes_registry.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshNotifier();
  ref.onDispose(refresh.dispose);

  // Reload tenant permissions setiap kali auth berubah.
  StreamSubscription? authSub;
  authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      // fire-and-forget; TenantScope notify-listeners akan trigger rebuild.
      // ignore: discarded_futures
      adminPanel.loadTenantPermissions();
    }
  });
  ref.onDispose(() => authSub?.cancel());

  return GoRouter(
    navigatorKey: AppNavigator.key,
    initialLocation: '/',
    routes: appRoutes,
    refreshListenable: Listenable.merge([refresh, adminPanel.tenantScope]),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loc = state.matchedLocation;
      final isLogin = loc == '/login';
      // Kiosk & display publik (mesin antrian) boleh diakses tanpa login.
      final isPublic = loc == '/kiosk' || loc.startsWith('/display');

      if (user == null && !isLogin && !isPublic) return '/login';
      if (user != null && isLogin) return '/admin';

      // Multi-tenant: admin boleh akses URL flat `/admin/<slug>`. Non-admin
      // harus pakai URL tenant-scoped `/admin/<tenantId>/<slug>`. Kalau non-
      // admin mengetik URL flat langsung, redirect ke tenant mereka.
      if (user != null &&
          adminPanel.isMultiTenant &&
          loc.startsWith(adminPanel.path)) {
        final perms = adminPanel.tenantScope.permissions;
        if (perms.isGlobalAdmin) return null; // admin bebas
        final rest = loc == adminPanel.path
            ? ''
            : loc.substring(adminPanel.path.length + 1);
        if (rest.isEmpty) return null; // /admin → redirect di-handle Panel
        final segments = rest.split('/');
        final first = segments.first;
        final tenantSlug = adminPanel.tenant!.resource.slug;

        // Non-admin tidak boleh akses tenant resource (mis. /admin/lokasi).
        if (first == tenantSlug) {
          if (perms.allowedIds.isNotEmpty) {
            return '${adminPanel.path}/${perms.allowedIds.first}';
          }
          return null;
        }
        // Kalau segmen pertama bukan tenantId valid, user mengetik URL flat
        // (mis. /admin/zona) → geser ke /admin/<firstTenantId>/zona.
        final isKnownTenantId = perms.allowedIds.contains(first);
        if (!isKnownTenantId && perms.allowedIds.isNotEmpty) {
          return '${adminPanel.path}/${perms.allowedIds.first}/$rest';
        }
      }
      return null;
    },
  );
});
