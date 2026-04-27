import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/app_auth_state.dart';
import '../features/admin/admin_panel.dart';
import '../features/auth/login_page.dart';
import '../features/counter/counter_page.dart';
import '../features/counter/counter_profile_page.dart';
import '../features/counter/counter_select_page.dart';
import '../features/display/display_page.dart';
import '../features/kiosk/kiosk_home_page.dart';
import '../features/kiosk/kiosk_setup_page.dart';
import '../models/app_user.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(appAuthStateProvider);

  return GoRouter(
    initialLocation: '/admin',
    refreshListenable: auth,
    redirect: (ctx, state) {
      final loc = state.matchedLocation;
      final atLogin = loc == '/login';

      // Public routes — kiosk client and lobby display screen.
      if (loc.startsWith('/kiosk') || loc.startsWith('/display')) return null;

      if (!auth.isLoggedIn) return atLogin ? null : '/login';

      // Logged in but profile still loading — keep them on a neutral spot.
      if (auth.isProfileLoading) return atLogin ? '/loading' : null;

      final user = auth.user;
      if (user == null) {
        // Auth user exists but no Firestore profile — treat as misconfigured.
        return atLogin ? null : '/no-profile';
      }

      final inAdmin = loc.startsWith('/admin');
      final inCounter = loc.startsWith('/counter');

      switch (user.role) {
        case UserRole.admin:
          if (atLogin || inCounter) return '/admin';
          return null;
        case UserRole.counter:
          final hasCounter =
              user.counterId != null && user.counterId!.isNotEmpty;
          if (atLogin || inAdmin) {
            return hasCounter ? '/counter' : '/counter/select';
          }
          if (loc == '/counter' && !hasCounter) return '/counter/select';
          if (loc == '/counter/select' && hasCounter) return '/counter';
          return null;
      }
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (ctx, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/loading',
        builder: (ctx, state) => const _LoadingPage(),
      ),
      GoRoute(
        path: '/no-profile',
        builder: (ctx, state) => const _NoProfilePage(),
      ),
      GoRoute(
        path: '/kiosk',
        builder: (ctx, state) => const KioskHomePage(),
      ),
      GoRoute(
        path: '/kiosk/setup',
        builder: (ctx, state) => const KioskSetupPage(),
      ),
      GoRoute(
        path: '/display',
        builder: (ctx, state) => const DisplayPage(),
      ),
      GoRoute(
        path: '/display/zone/:id',
        builder: (ctx, state) =>
            DisplayPage(zoneId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/counter',
        builder: (ctx, state) => const CounterPage(),
      ),
      GoRoute(
        path: '/counter/select',
        builder: (ctx, state) => const CounterSelectPage(),
      ),
      GoRoute(
        path: '/counter/profile',
        builder: (ctx, state) => const CounterProfilePage(),
      ),
      ...adminPanel.buildRoutes(),
    ],
  );
});

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _NoProfilePage extends ConsumerWidget {
  const _NoProfilePage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 56, color: Colors.orange),
              const SizedBox(height: 12),
              const Text(
                'Profil pengguna tidak ditemukan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Akun Anda belum terdaftar di sistem. Hubungi administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.read(appAuthStateProvider).dispose(),
                child: const Text('Keluar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
