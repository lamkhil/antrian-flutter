import 'package:antrian/data/models/notifikasi.dart';

class NotifikasiServices {
  // TODO: ganti dengan fetch dari Firestore saat backend notifikasi siap.
  static List<Notifikasi> fetchDummy() => const [
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
}
