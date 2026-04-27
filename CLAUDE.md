# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`antrian` — a Flutter queue-management app (Dart SDK ^3.11.4) built on a local FilamentPHP-inspired admin framework (`packages/flutter_filament`, **NOT** the 3D rendering library of the same name on pub.dev). Stack: Firebase (Auth + Firestore), Riverpod (plain providers, **no codegen**), go_router, flutter_tts, audioplayers.

**Conventions:** code identifiers (variables, functions, files) in English; UI/menu text and Firestore-domain prose in Indonesian (`loket`=counter, `layanan`=service, `zona`=zone, `pengguna`=user, `kios`=kiosk, `antrian`=ticket/queue).

**Domain hierarchy:** `Zone → Service → Counter → User`, plus standalone `Kiosk` (no zone link). Lokasi (location) was intentionally dropped on 2026-04-27 during a full rebuild; the prior implementation lives in `lib-backup/` for reference only — **do not import from it**.

**Constraints:**
- A `Service` belongs to exactly one `Zone`.
- A `Counter` handles many Services (many-to-many via `Counter.serviceIds: List<String>`).
- A `User` belongs to one `Counter` (counter user picks at login → persisted to `users/<uid>.counterId`).
- A `Kiosk` has `name + deviceId + active`; the kiosk client device stores its own deviceId in SharedPreferences on first launch.

## Commands

```bash
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --debug --target-platform android-arm64   # quickest end-to-end compile check
```

No code generation is used in `lib/` — plain Riverpod `Provider`/`ChangeNotifier`. The `mason.yaml` brick (`./feature`) belongs to the old `lib-backup/` structure and is **not** used for new features.

## Architecture

### Entry point
`lib/main.dart` initializes Firebase, `intl` `id_ID` data, and primes `LookupCache.instance` (one-shot fetch + Firestore `snapshots()` subscription on `zones`/`services`/`counters` so flutter_filament's synchronous `Select.options` can read fresh data without async hops). Then `runApp(ProviderScope(...))` mounting `MaterialApp.router` with `appRouterProvider`.

### Routing & auth gate (`lib/app/router.dart`)
`appRouterProvider` builds a single GoRouter; auth gating is in `redirect`. Driven by `AppAuthState` (`lib/data/app_auth_state.dart`) — a `ChangeNotifier` combining Firebase Auth state with the user's Firestore profile doc; passed as `refreshListenable`.

**Public routes (bypass auth):** `/login`, `/kiosk*`, `/display*`.

**Role-based redirects (logged in):**
- `admin` → `/admin/*` (flutter_filament panel); blocked from `/counter*`.
- `counter` with `counterId` set → `/counter`.
- `counter` without `counterId` → `/counter/select`.

Special routes: `/loading` (user-doc still loading), `/no-profile` (auth user has no Firestore profile).

### Admin panel (`lib/features/admin/`)
Built on flutter_filament. `admin_panel.dart` exports the singleton `Panel` (`adminPanel`) with brand, theme (`FilamentColors.indigo`), sidebar footer (current user + logout), and the resources list. The router includes `...adminPanel.buildRoutes()` → routes mounted at `/admin/<slug>/...` with auto-built sidebar grouped by `navigationGroup`.

**Per-resource layout (Filament-style):**
```
lib/features/admin/resources/<entity>/
  <entity>_resource.dart           # Resource<T> subclass: form, table, pages(), relations()
  pages/
    list_<plural>.dart             # ListXxx → ListRecordsPage<T>
    create_<singular>.dart         # CreateXxx → CreateRecordPage<T>
    view_<singular>.dart           # ViewXxx → ViewRecordPage<T>
    edit_<singular>.dart           # EditXxx → EditRecordPage<T>
  relations/                       # optional
    <child>_relation_manager.dart  # RelationManager<TParent, TChild>
```

Five resources today: `user/`, `counter/`, `service/`, `zone/`, `kiosk/`. Two relation managers (rendered as tabs on edit/view): `counter/relations/users_relation_manager.dart` (users assigned to this loket), `zone/relations/services_relation_manager.dart` (services in this zone).

Each page widget exposes a static `route()` returning a `ResourcePage<T>` (mirrors Filament's `ListUsers::route('/')`). Resources override `pages()` explicitly:

```dart
@override
Map<String, ResourcePage<AppUser>> pages() => {
  'index':  ListUsers.route(),
  'create': CreateUser.route(),
  'view':   ViewUser.route(),
  'edit':   EditUser.route(),
};
```

**Adding a new resource:** create the entity folder, write the resource + 4 page widgets (+ optional relations), then register the resource instance in `admin_panel.dart`'s `resources: [...]`. Routes and sidebar entries are auto-derived.

### Counter operator UI (`lib/features/counter/`)
**Not** a flutter_filament panel — custom `Scaffold` per page since the operator screen is action-driven, not CRUD.

- `counter_select_page.dart` — pick a Loket, write `users/<uid>.counterId`. Router redirects here when a counter user has no counterId.
- `counter_page.dart` — main operator screen. Header (loket + user + paused badge), current ticket card with **Selesai (Serve) / Panggil Ulang / Skip / Transfer**, big **Panggil Antrian Berikutnya** button (disabled when there's an active called ticket or user is paused), **Istirahat / Lanjutkan** toggle (writes `users/<uid>.paused`), waiting list. The "+ Tiket Tes" header button is a stand-in for the kiosk client and **should be removed once the kiosk is in real use**.
- `counter_profile_page.dart` — name, change password (re-auth + `updatePassword`), change loket.

### Kiosk client (`lib/features/kiosk/`) — public
- `/kiosk/setup` — first-launch input for Device ID; `KioskSession.resolve()` validates against `kiosks` Firestore (`active == true`); on success persisted to SharedPreferences (`kiosk_device_id`).
- `/kiosk` — bootstraps from SharedPreferences (re-validates against Firestore on every cold start; if Kiosk record gone or deactivated, redirects to `/setup`). Service grid; tap → `TicketService.createTicket(serviceId)` → fullscreen success with the ticket number XL + 12s auto-return.

### Public display (`lib/features/display/`) — public
- `/display` — all-counter live board.
- `/display/zone/:id` — same board scoped to one zone (counters/tickets/waiting filtered by `service.zoneId == :id`).

Streams `tickets` for today (`createdAt >= startOfDay`); groups by counter for "now serving"; per-service waiting count in the footer bar; on each new `called` (or `recallCount` increment for that ticket) fires `audioplayers` chime (`assets/sounds/chime.wav`, ~1s ding-dong) followed by `flutter_tts` Indonesian announcement (`id-ID`), plus a 4-second amber-glow border highlight on the affected counter card. Live clock in header. All audio/TTS calls are wrapped in try/catch — if the audio backend is missing (emulator without audio, web), UI still works.

### Data layer (`lib/data/`)
- `firestore_data_source.dart` — `FirestoreDataSource<T>` implements flutter_filament's `DataSource<T>`. Fields: `whereEquals: Map<String, dynamic>?` (Firestore-side equality filter for relation scoping), `searchMatcher`, `createOverride` (e.g. user creation hook), `deleteHook`. List queries are one-shot then client-side filtered/sorted/paginated (fine for small admin collections).
- `lookup_cache.dart` — singleton primed in `main()`, exposes sync `zones` / `services` / `counters` lists used by form `Select` options and table cell formatters. Helpers: `zoneName(id)`, `serviceName(id)`, `counterName(id)`.
- `admin_user_service.dart` — uses a **secondary Firebase app** (`'admin_user_creator'`) to create Firebase Auth users without clobbering the admin's session. Auth-account deletion is **not possible** client-side (would need server Admin SDK); we delete only the Firestore profile. Reversed earlier `firebase_admin_sdk` decision.
- `app_auth_state.dart` — `ChangeNotifier` for the router (auth state + user-doc stream).
- `kiosk_session.dart` — SharedPreferences-backed device-id for kiosk app + `resolve()` lookup against `kiosks`.
- `ticket_service.dart` — operations on `tickets`:
  - `createTicket(serviceId)` — atomic per-service-per-day numbering via Firestore transaction on `services/<id>/dailyCounters/<YYYY-MM-DD>.next`. Number format: `<service.code or first-letter-uppercase>-<NNN>` (e.g. `A-007`). Counter doc per date → automatic daily reset.
  - `callNext({counterId, serviceIds})` — picks oldest waiting ticket among the counter's services; transaction-guarded (re-checks `status == waiting` before claiming, so two counters can't grab the same ticket).
  - `skip(ticketId)` — back to `waiting`, `counterId = null`, `queuedAt = serverTimestamp()`, `skipCount++` → automatically goes to end of queue (queue is sorted by `queuedAt`).
  - `serve(ticketId, customerName?, customerPhone?, notes?)` — `status = done`, `doneAt = now`.
  - `recall(ticketId)` — only bumps `recallCount` (no state change); display picks up the bump and re-fires chime/TTS.
  - `transfer({ticketId, targetCounterId})` — `counterId = target`, stays `called`.
- `streamTodayTickets({counterId, serviceIds})` (in `TicketService`) — live stream used by counter operator screen; sorts called-by-this-counter first, then waiting by `queuedAt`.

### Models (`lib/models/`) — English class names
`AppUser` (`UserRole` enum: `admin` / `counter`; `counterId`; `paused`), `Zone`, `Service` (`zoneId`, `code`), `Counter` (`serviceIds`), `Kiosk` (`deviceId`, `active`), `Ticket` (`TicketStatus`: `waiting` / `called` / `done`; `sequenceNumber: int` + `number: String` like `"A-007"`; `queuedAt` for ordering after skip; `skipCount`, `recallCount`, optional `customerName` / `customerPhone` / `notes`).

All extend `Equatable` with `props: [id]` (identity-by-id). Each has `toMap()` / `fromMap(map)` for Firestore round-trip with Timestamp ↔ DateTime conversion via local helpers.

### Firestore collections
- `users` — keyed by Firebase Auth uid; `{name, email, role, counterId?, paused, createdAt}`
- `zones` — `{name, description?, createdAt}`
- `services` — `{name, zoneId, code?, createdAt}`
- `services/<id>/dailyCounters/<YYYY-MM-DD>` — `{next: int, updatedAt}` (per-service daily ticket counter)
- `counters` — `{name, serviceIds: List<String>, createdAt}`
- `kiosks` — `{name, deviceId, active, createdAt}`
- `tickets` — see Ticket model

**Composite index needed** on `tickets`: `status` + `serviceId` + `createdAt` + `queuedAt`. Firestore prints the create-URL on first failed query — click and create.

## Bootstrap (first run on a new environment)

1. `flutter pub get`
2. Verify `lib/firebase_options.dart` matches the target FlutterFire project; if not, `flutterfire configure`.
3. **Create the first admin manually** (no UI to bootstrap):
   - Firebase Auth: create user with email + password
   - Firestore: write `users/<uid>` with `{ name: "Admin", email: "...", role: "admin" }`
4. `flutter run` (Android target preferred for full audio/TTS; web works but limited audio backends).
5. Login → `/admin`. Create base data via the panel: Zona → Layanan → Loket → Kios → counter Pengguna.

## Manual end-to-end smoke test

1. Login as admin → buat: **Zona** "Lobi" → **Layanan** "Pendaftaran" (code `A`, zona Lobi) → **Loket** "Loket 1" (centang Pendaftaran) → **Pengguna** `counter@x` role=Loket → **Kios** "Lobi-1" (Device ID `LOBI-01`).
2. New tab `/kiosk` → input `LOBI-01` → tap **Pendaftaran** → tiket `A-001` keluar.
3. New tab `/display` (atau `/display/zone/<lobi-id>` untuk filter zona).
4. New tab `/login` → `counter@x` → pilih Loket 1 → `/counter` → **Panggil Antrian Berikutnya**. Display akan flash + chime + TTS: *"Nomor antrian A 001, silakan menuju Loket 1."*.

## Local framework: `packages/flutter_filament`

Filament 5-inspired admin framework. Edit freely; **bump `version` in its `pubspec.yaml` and add a CHANGELOG entry** when changing public API. Current `0.2.1` highlights:
- `Resource<T>.pages()` returns `Map<String, ResourcePage<T>>` (key = page name, e.g. `'index'`, `'create'`).
- `Resource<T>.relations()` returns `List<RelationManager>`; rendered as tabs on edit/view via `RelationTabs` widget.
- `ResourcePage.list/create/view/edit` factories take optional `builder` so users can wrap default pages with custom widgets while preserving page-kind semantics (used for header-action derivation).
- `RelationManager<TParent, TChild>` — manajer relasi ala Filament; expose `title`, `icon`, `table(parent)`, `dataSource(parent)`, `childId(record)`.
- See `packages/flutter_filament/CHANGELOG.md` for the full migration history (incl. the breaking 0.1.x → 0.2.0 jump).

## What's intentionally NOT built (current state, 2026-04-27)

- Cetak fisik tiket di kiosk (tampil di layar saja, belum integrasi printer ESC/POS)
- Server-side Auth account deletion (admin can only delete Firestore profile)
- Display per-counter (`/display/counter/:id`) — easy to add by mirroring zone filter
- Custom hooks on per-resource pages (header actions tambahan, tab kustom) — extension points exist (override `build()` di page widget), tinggal pakai
- Seed script untuk bootstrap data awal — masih manual via admin panel
- Audio chime customization UI (kalau mau, ganti `assets/sounds/chime.wav` dan rebuild)
