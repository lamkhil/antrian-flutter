import 'package:flutter/material.dart';

enum AntrianStatus { dipanggil, menunggu, selesai, dibatalkan }

class DashboardStats {
  final int totalHariIni;
  final int selesai;
  final int menunggu;
  final int dibatalkan;
  final int rataWaktuMenit;

  const DashboardStats({
    this.totalHariIni = 0,
    this.selesai = 0,
    this.menunggu = 0,
    this.dibatalkan = 0,
    this.rataWaktuMenit = 0,
  });
}

class AntrianItem {
  final String nomor;
  final String nama;
  final String layanan;
  final String loket;
  final AntrianStatus status;

  const AntrianItem({
    required this.nomor,
    required this.nama,
    required this.layanan,
    required this.loket,
    required this.status,
  });
}

class ZonaItem {
  final String nama;
  final int terisi;
  final int kapasitas;

  const ZonaItem({
    required this.nama,
    required this.terisi,
    required this.kapasitas,
  });

  double get persen => terisi / kapasitas;

  Color get warna {
    if (persen >= 0.85) return const Color(0xFFEF9F27);
    if (persen >= 0.95) return const Color(0xFFE24B4A);
    return const Color(0xFF6366F1);
  }
}

class RiwayatItem {
  final String nomor;
  final String layanan;
  final String waktu;
  final AntrianStatus status;

  const RiwayatItem({
    required this.nomor,
    required this.layanan,
    required this.waktu,
    required this.status,
  });
}

class RingkasanLayanan {
  final String nama;
  final int total;
  final int selesai;
  final int menunggu;

  const RingkasanLayanan({
    required this.nama,
    required this.total,
    required this.selesai,
    required this.menunggu,
  });
}

class HomeState {
  final bool isLoading;
  final DashboardStats stats;
  final List<AntrianItem> antrianAktif;
  final List<ZonaItem> zonaList;
  final List<RiwayatItem> riwayat;
  final List<RingkasanLayanan> ringkasanLayanan;

  const HomeState({
    this.isLoading = false,
    this.stats = const DashboardStats(),
    this.antrianAktif = const [],
    this.zonaList = const [],
    this.riwayat = const [],
    this.ringkasanLayanan = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    DashboardStats? stats,
    List<AntrianItem>? antrianAktif,
    List<ZonaItem>? zonaList,
    List<RiwayatItem>? riwayat,
    List<RingkasanLayanan>? ringkasanLayanan,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      antrianAktif: antrianAktif ?? this.antrianAktif,
      zonaList: zonaList ?? this.zonaList,
      riwayat: riwayat ?? this.riwayat,
      ringkasanLayanan: ringkasanLayanan ?? this.ringkasanLayanan,
    );
  }
}
