import 'package:antrian/data/models/lokasi.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum StatusZona { aktif, nonAktif }

class Zona extends Equatable {
  final String id;
  final String kode;
  final String nama;
  final String lokasiId;
  final Lokasi lokasi;
  final int kapasitas;
  final int antrianAktif;
  final int jumlahLayanan;
  final StatusZona status;

  const Zona({
    required this.id,
    required this.kode,
    required this.nama,
    required this.lokasiId,
    required this.lokasi,
    this.kapasitas = 10,
    this.antrianAktif = 0,
    this.jumlahLayanan = 0,
    this.status = StatusZona.aktif,
  });

  Zona copyWith({
    String? kode,
    String? nama,
    String? lokasiId,
    Lokasi? lokasi,
    int? kapasitas,
    int? antrianAktif,
    StatusZona? status,
    int? jumlahLayanan,
  }) => Zona(
    id: id,
    kode: kode ?? this.kode,
    lokasi: lokasi ?? this.lokasi,
    nama: nama ?? this.nama,
    lokasiId: lokasiId ?? this.lokasiId,
    jumlahLayanan: jumlahLayanan ?? this.jumlahLayanan,
    kapasitas: kapasitas ?? this.kapasitas,
    antrianAktif: antrianAktif ?? this.antrianAktif,
    status: status ?? this.status,
  );

  factory Zona.fromJson(Map<String, dynamic> json) => Zona(
    id: json['id'],
    kode: json['kode'],
    nama: json['nama'],
    lokasiId: json['lokasiId'],
    lokasi: Lokasi.fromJson(json['lokasi']),
    kapasitas: json['kapasitas'] ?? 0,
    antrianAktif: json['antrianAktif'] ?? 0,
    jumlahLayanan: json['jumlahLayanan'] ?? 0,
    status: switch (json['status']) {
      'aktif' => StatusZona.aktif,
      'nonAktif' => StatusZona.nonAktif,
      _ => StatusZona.aktif,
    },
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kode': kode,
    'nama': nama,
    'lokasiId': lokasiId,
    'lokasi': lokasi.toJson(),
    'kapasitas': kapasitas,
    'antrianAktif': antrianAktif,
    'jumlahLayanan': jumlahLayanan,
    'status': status == StatusZona.aktif ? 'aktif' : 'nonAktif',
  };

  @override
  List<Object?> get props => [id];
}

extension StatusZonaX on StatusZona {
  String get label => switch (this) {
    StatusZona.aktif => 'Aktif',
    StatusZona.nonAktif => 'Non-aktif',
  };

  Color get badgeBg => switch (this) {
    StatusZona.aktif => const Color(0xFFECFDF5),
    StatusZona.nonAktif => const Color(0xFFFEF2F2),
  };

  Color get badgeColor => switch (this) {
    StatusZona.aktif => const Color(0xFF065F46),
    StatusZona.nonAktif => const Color(0xFF991B1B),
  };

  Color get dotColor => switch (this) {
    StatusZona.aktif => const Color(0xFF059669),
    StatusZona.nonAktif => const Color(0xFFEF4444),
  };
}
