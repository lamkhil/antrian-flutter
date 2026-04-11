class Lokasi {
  final String id;
  final String nama;
  final String alamat;
  final int zonaAktif;

  const Lokasi({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.zonaAktif,
  });
}

// Master list — ganti/tambah sesuai data dari API
const daftarLokasi = [
  Lokasi(
    id: 'mpp-pusat',
    nama: 'MPP Pusat',
    alamat: 'Jl. Jimerto No.25',
    zonaAktif: 3,
  ),
  Lokasi(
    id: 'spp-menur',
    nama: 'SPP Menur',
    alamat: 'Jl. Menur No.31',
    zonaAktif: 2,
  ),
  Lokasi(
    id: 'spp-joyoboyo',
    nama: 'SPP Joyoboyo',
    alamat: 'Jl. Joyoboyo No.10',
    zonaAktif: 1,
  ),
  Lokasi(
    id: 'spp-siwalankerto',
    nama: 'SPP Siwalankerto',
    alamat: 'Jl. Siwalankerto No.5',
    zonaAktif: 2,
  ),
];
