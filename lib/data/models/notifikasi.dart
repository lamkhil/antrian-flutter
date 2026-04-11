// lib/data/models/notifikasi.dart

enum TipeNotifikasi { info, warning, success, danger }

class Notifikasi {
  final String id;
  final String judul;
  final String deskripsi;
  final String waktu;
  final TipeNotifikasi tipe;
  final bool sudahDibaca;

  const Notifikasi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.waktu,
    required this.tipe,
    this.sudahDibaca = false,
  });
}

final daftarNotifikasi = [
  Notifikasi(
    id: '1',
    judul: 'Antrian baru masuk',
    deskripsi: 'Nomor A-047 menunggu di Zona 1 — MPP Pusat',
    waktu: '2 menit lalu',
    tipe: TipeNotifikasi.info,
  ),
  Notifikasi(
    id: '2',
    judul: 'Waktu tunggu tinggi',
    deskripsi: 'Rata-rata tunggu di Zona 2 melebihi 25 menit',
    waktu: '15 menit lalu',
    tipe: TipeNotifikasi.warning,
  ),
  Notifikasi(
    id: '3',
    judul: 'Loket B3 dibuka kembali',
    deskripsi: 'SPP Menur — loket aktif setelah jeda istirahat',
    waktu: '1 jam lalu',
    tipe: TipeNotifikasi.success,
    sudahDibaca: true,
  ),
  Notifikasi(
    id: '4',
    judul: 'Loket C1 ditutup paksa',
    deskripsi: 'SPP Joyoboyo — petugas tidak hadir',
    waktu: '2 jam lalu',
    tipe: TipeNotifikasi.danger,
    sudahDibaca: true,
  ),
];
