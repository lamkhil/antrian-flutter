import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum StatusLayanan { aktif, nonAktif }

class Layanan extends Equatable {
  final String id;
  final String zonaId;
  final String lokasiId;
  final String kode;
  final String nama;
  final String deskripsi;
  final int durasiMenit;
  final int biaya;
  final StatusLayanan status;
  final Zona zona;
  final Lokasi lokasi;

  const Layanan({
    required this.id,
    required this.zonaId,
    required this.lokasiId,
    required this.kode,
    required this.nama,
    required this.zona,
    required this.lokasi,
    this.deskripsi = '',
    this.durasiMenit = 15,
    this.biaya = 0,
    this.status = StatusLayanan.aktif,
  });

  Layanan copyWith({
    String? kode,
    String? nama,
    String? deskripsi,
    int? durasiMenit,
    int? biaya,
    StatusLayanan? status,
    Zona? zona,
    String? zonaId,
    String? lokasiId,
    Lokasi? lokasi,
  }) => Layanan(
    id: id,
    zonaId: zonaId ?? this.zonaId,
    lokasiId: lokasiId ?? this.lokasiId,
    lokasi: lokasi ?? this.lokasi,
    zona: zona ?? this.zona,
    kode: kode ?? this.kode,
    nama: nama ?? this.nama,
    deskripsi: deskripsi ?? this.deskripsi,
    durasiMenit: durasiMenit ?? this.durasiMenit,
    biaya: biaya ?? this.biaya,
    status: status ?? this.status,
  );

  factory Layanan.fromJson(Map<String, dynamic> json) => Layanan(
    id: json['id'],
    zonaId: json['zonaId'],
    lokasiId: json['lokasiId'],
    kode: json['kode'],
    nama: json['nama'],
    deskripsi: json['deskripsi'] ?? '',
    durasiMenit: json['durasiMenit'] ?? 15,
    biaya: json['biaya'] ?? 0,
    status: (json['status'] as String).toLowerCase() == 'aktif'
        ? StatusLayanan.aktif
        : StatusLayanan.nonAktif,
    zona: Zona.fromJson(json['zona'] ?? {}),
    lokasi: Lokasi.fromJson(json['lokasi'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'zonaId': zonaId,
    'lokasiId': lokasiId,
    'kode': kode,
    'nama': nama,
    'deskripsi': deskripsi,
    'durasiMenit': durasiMenit,
    'biaya': biaya,
    'status': status.label,
    'zona': zona.toJson(),
    'lokasi': lokasi.toJson(),
  };

  @override
  List<Object?> get props => [id];
}

extension StatusLayananX on StatusLayanan {
  String get label => this == StatusLayanan.aktif ? 'Aktif' : 'Non-aktif';

  Color get badgeBg => this == StatusLayanan.aktif
      ? const Color(0xFFECFDF5)
      : const Color(0xFFFEF2F2);

  Color get badgeColor => this == StatusLayanan.aktif
      ? const Color(0xFF065F46)
      : const Color(0xFF991B1B);

  Color get dotColor => this == StatusLayanan.aktif
      ? const Color(0xFF059669)
      : const Color(0xFFEF4444);
}
