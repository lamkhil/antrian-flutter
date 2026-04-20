import 'package:flutter/material.dart';
import 'package:flutter_filament/flutter_filament.dart';

// filament:imports
import '../../data/models/lokasi.dart';
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
import 'antrian_tenant_access.dart';

/// Main admin Panel untuk aplikasi Antrian.
///
/// Multi-tenant: `Lokasi` menjadi tenant. URL tenant-scoped:
/// `/admin/{lokasiId}/zona`, `/admin/{lokasiId}/layanan`, dst.
/// `LokasiResource` sendiri diakses global di `/admin/lokasi`.
///
/// User dengan `role == 'admin'` bypass tenant scope (lihat semua data).
final Panel adminPanel = Panel(
  id: 'admin',
  path: '/admin',
  brandName: 'Antrian Admin',
  theme: const FilamentTheme(colors: FilamentColors.amber),
  dashboardTitle: 'Dashboard',
  dashboardIcon: Icons.dashboard_outlined,
  tenant: TenantConfig<Lokasi>(
    resource: LokasiResource(),
    scopeField: 'lokasiId',
    labelOf: (l) => l.nama,
    slugOf: (l) => l.id,
  ),
  tenantAccess: AntrianTenantAccess(),
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
