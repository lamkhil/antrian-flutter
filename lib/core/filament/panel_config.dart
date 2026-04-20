import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

// filament:imports
import '../../features/antrian/antrian_resource.dart';
import '../../features/home/widgets/antrian_aktif_widget.dart';
import '../../features/home/widgets/grafik_mingguan_widget.dart';
import '../../features/home/widgets/ringkasan_stat_widget.dart';
import '../../features/home/widgets/zona_kapasitas_widget.dart';
import '../../features/laporan/laporan_page.dart';
import '../../features/layanan/layanan_resource.dart';
import '../../features/loket/loket_resource.dart';
import '../../features/lokasi/lokasi_resource.dart';
import '../../features/pengaturan/pengaturan_page.dart';
import '../../features/pengguna/pengguna_resource.dart';
import '../../features/zona/zona_resource.dart';

/// Main admin Panel untuk aplikasi Antrian.
///
/// Sidebar & semua route CRUD auto-generate dari resource + pages + widgets
/// di bawah ini. Marker `// filament:*-begin/end` dipakai Mason brick
/// untuk auto-register; jangan dihapus.
final Panel adminPanel = Panel(
  id: 'admin',
  path: '/admin',
  brandName: 'Antrian Admin',
  theme: const FilamentTheme(colors: FilamentColors.amber),
  dashboardTitle: 'Dashboard',
  dashboardIcon: Icons.dashboard_outlined,
  resources: [
    // filament:resources-begin
    LokasiResource(),
    ZonaResource(),
    LayananResource(),
    LoketResource(),
    AntrianResource(),
    PenggunaResource(),
    // filament:resources-end
  ],
  pages: const [
    // filament:pages-begin
    LaporanPage(),
    PengaturanPage(),
    // filament:pages-end
  ],
  widgets: const [
    // filament:widgets-begin
    RingkasanStatWidget(),
    AntrianAktifWidget(),
    GrafikMingguanWidget(),
    ZonaKapasitasWidget(),
    // filament:widgets-end
  ],
);
