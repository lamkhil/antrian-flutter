# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`antrian` — a Flutter queue-management app (Dart SDK ^3.11.4). Uses Firebase (Auth, Firestore), Riverpod (with codegen), go_router, and Dio. UI/domain text is in Indonesian (e.g. `antrian`=queue, `loket`=counter, `layanan`=service, `zona`=zone, `pengguna`=user, `laporan`=report, `pengaturan`=settings).

Domain hierarchy: **Lokasi → Zona → Layanan → Loket → Antrian**. Each level has a Firestore collection (`locations`, `zones`, `services`, `counters`, `antrians`) and a corresponding model that nests its parent (e.g. `Loket` carries `layanan`, `zona`, `lokasi` references).

## Commands

```bash
flutter pub get                              # install deps
flutter run                                  # run app
flutter test                                 # run all tests
flutter test test/widget_test.dart           # run a single test file
flutter analyze                              # lint (uses flutter_lints via analysis_options.yaml)

# Code generation (Riverpod + router providers — required after editing any @riverpod annotated file)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch  --delete-conflicting-outputs

# Scaffold a new feature (uses local Mason brick at ./feature)
mason make feature --name <feature_name>
```

After generating a feature with Mason, wire it into `lib/core/router/routes_registry.dart` by adding the import under the `/// mason:imports` marker and the `GoRoute` under `/// mason:routes`.

## Architecture

### Entry point and bootstrap
`lib/main.dart` initializes `SharedPreferences`, Firebase (via `lib/firebase_options.dart`), and `intl` `id_ID` locale data before `runApp`. The `sharedPreferencesProvider` is overridden at the `ProviderScope` so downstream providers can read it synchronously. `MyApp` is a `ConsumerWidget` that mounts `MaterialApp.router` with the router from `appRouterProvider`.

### Routing & auth gate
- `lib/core/router/app_router.dart` exposes `appRouterProvider` (keepAlive) which builds a `GoRouter`.
- Auth gating lives in the router's `redirect`: if `FirebaseAuth.instance.currentUser == null`, every non-`/login` route is redirected to `/login`; authenticated users visiting `/login` are bounced to `/`. Exception: `/kiosk` and `/display/*` are public (unattended kiosk + zone display screens), bypassing the auth redirect — do not gate them behind login.
- `RouterRefreshNotifier` (passed as `refreshListenable`) makes the router reactive to auth state changes.
- `routes_registry.dart` is the single flat list of `GoRoute`s (`appRoutes`). Each feature owns a `*_route.dart` that exports its `GoRoute`; new routes are registered here.
- `lib/globals/app_navigator.dart` holds the global `navigatorKey` used by `GoRouter` so non-widget code can navigate.

### Feature layout (per-feature, enforced by the Mason brick)
```
lib/features/<name>/
  <name>_route.dart              # GoRoute definition
  application/<name>_controller.dart   # @riverpod controller (generates .g.dart)
  presentation/<name>_page.dart        # UI
```
Existing features: `antrian`, `home`, `laporan`, `layanan`, `login`, `loket`, `pengaturan`, `pengguna`, `zona`. `zona` and `layanan` each have a detail route (`/zona/:id`, `/layanan/:id`) where their child entity (Layanan/Loket) is CRUD-ed in context. The layanan list page also links out to `/layanan/:id` via a "view" action on each row.

Two **standalone screens** live outside the sidebar menu and are rendered as bare `Scaffold` (no `AppLayout`):
- `kiosk` at `/kiosk` — public self-service ticket dispenser. Flow: pick lokasi → pick layanan → `AntrianServices.ambilTiket` writes a new `antrians` doc and returns a ticket; auto-returns to the layanan list after 10s.
- `display` at `/display/:zonaId` — unattended zone screen. Subscribes to `AntrianServices.streamAktifByZona` (Firestore `snapshots()`) and shows per-loket "now serving" plus a waiting-queue list, updating live. Loket list is fetched once on entry (services→loket fan-out).

### Data layer
- `lib/data/models/` — plain Dart model classes. `Zona`, `Lokasi`, `Layanan`, `Antrian` all extend `Equatable` with `props: [id]` (identity-by-id). Models hold no fixture/dummy data — that lives in services.
- `lib/data/services/` — static-method service classes grouped by domain (`auth/`, `lokasi/`, `zona/`, `layanan/`, `loket/`, `pengguna/`, `laporan/`, `notifikasi/`). Methods return `ResponseApi<T>`. Naming convention: `fetch*` / `add` / `update` / `delete` (e.g. `LayananServices.add`, `ZonaServices.updateZona`). One service per domain entity — do not put child-entity methods on the parent service. `NotifikasiServices.fetchDummy()` returns hardcoded placeholder data pending a real backend. `LaporanServices.fetchAntrianRange` pulls raw antrian; aggregation lives in `LaporanState` getters (counts, avg wait, group-by-zona/layanan).

### Shared infrastructure
- `lib/core/storage/shared_preferences.dart` — declares `sharedPreferencesProvider` (overridden in `main.dart`).
- `lib/globals/providers/` — cross-feature Riverpod providers (currently `lokasi/lokasi_provider.dart` for the active location).
- `lib/globals/widgets/` — reusable UI primitives. Prefer these over re-inlining:
  - `AppLayout` (scaffold with sidebar + topbar), `AppTopBar`, `AppSidebar`, `AppDialog` (static loading/error/warning/basic).
  - `StatusBadge` — takes `label/bg/fg/dot`; status enums expose matching getters (`.label`, `.badgeBg`, `.badgeColor`, `.dotColor`).
  - `AppActionButton` — edit/delete icon button; `size`/`iconSize` override (default 28/13; zona_detail uses 26/12).
  - `AppEmptyState`, `AppMobileField`, `AppListToolbar` (search + add button), `AppFormField` (auto-switches to multiline when `maxLines > 1`), `AppDropdownField<T>`.
- `lib/extension/size.dart` — sizing extension helpers.

### State management conventions
- Riverpod with code generation (`@riverpod` / `@Riverpod(keepAlive: true)`); every annotated file has a sibling `*.g.dart` that must be regenerated via `build_runner` after edits.
- The go_router provider is also codegen'd (`app_router.g.dart`).

### Mason brick
The `feature` brick lives in `./feature` and is registered in `mason.yaml`. The `mason-lock.json` currently pins the brick to an absolute macOS path (`/Users/mbam1/...`) — if `mason make` fails on this machine, re-run `mason get` or edit the lockfile to match `./feature`.

### Firebase
Configured for multiple platforms via FlutterFire (`firebase_options.dart`, `firebase.json`, `firebase.indexes.json`). Auth state drives routing; Firestore indexes are tracked in `firebase.indexes.json`.
