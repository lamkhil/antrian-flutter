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
