import 'package:flutter_filament/flutter_filament.dart';

// filament:imports

/// The main admin Panel for this app.
///
/// Resources, custom pages and dashboard widgets added via Mason bricks are
/// registered between the `begin`/`end` markers. Do not remove the markers —
/// the brick post_gen hooks rely on them for auto-registration.
final Panel adminPanel = Panel(
  id: 'admin',
  path: '/admin',
  brandName: 'Antrian Admin',
  theme: const FilamentTheme(colors: FilamentColors.amber),
  dashboardTitle: 'Dashboard',
  resources: [
    // filament:resources-begin
    // filament:resources-end
  ],
  pages: [
    // filament:pages-begin
    // filament:pages-end
  ],
  widgets: [
    // filament:widgets-begin
    // filament:widgets-end
  ],
);
