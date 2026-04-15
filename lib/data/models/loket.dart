import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/lokasi.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum StatusLoket { aktif, tutup, istirahat }

class Loket extends Equatable {
  final String id;
  final String layananId;
  final String zonaId;
  final String lokasiId;
  final String kode;
  final String nama;
  final String? petugas;
  final StatusLoket status;
  final Layanan layanan;
  final Zona zona;
  final Lokasi lokasi;

  const Loket({
    required this.id,
    required this.layananId,
    required this.zonaId,
    required this.lokasiId,
    required this.kode,
    required this.nama,
    required this.layanan,
    required this.zona,
    required this.lokasi,
    this.petugas,
    this.status = StatusLoket.aktif,
  });

  Loket copyWith({
    String? layananId,
    String? zonaId,
    String? lokasiId,
    String? kode,
    String? nama,
    String? petugas,
    StatusLoket? status,
    Layanan? layanan,
    Zona? zona,
    Lokasi? lokasi,
  }) => Loket(
    id: id,
    layananId: layananId ?? this.layananId,
    zonaId: zonaId ?? this.zonaId,
    lokasiId: lokasiId ?? this.lokasiId,
    kode: kode ?? this.kode,
    nama: nama ?? this.nama,
    petugas: petugas ?? this.petugas,
    status: status ?? this.status,
    layanan: layanan ?? this.layanan,
    zona: zona ?? this.zona,
    lokasi: lokasi ?? this.lokasi,
  );

  factory Loket.fromJson(Map<String, dynamic> json) => Loket(
    id: json['id'],
    layananId: json['layananId'],
    zonaId: json['zonaId'],
    lokasiId: json['lokasiId'],
    kode: json['kode'],
    nama: json['nama'],
    petugas: json['petugas'],
    status: StatusLoket.values.firstWhere(
      (s) => s.name == (json['status'] as String?)?.toLowerCase(),
      orElse: () => StatusLoket.aktif,
    ),
    layanan: Layanan.fromJson(json['layanan'] ?? {}),
    zona: Zona.fromJson(json['zona'] ?? {}),
    lokasi: Lokasi.fromJson(json['lokasi'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'layananId': layananId,
    'zonaId': zonaId,
    'lokasiId': lokasiId,
    'kode': kode,
    'nama': nama,
    'petugas': petugas,
    'status': status.name,
    'layanan': layanan.toJson(),
    'zona': zona.toJson(),
    'lokasi': lokasi.toJson(),
  };

  @override
  List<Object?> get props => [id];
}

extension StatusLoketX on StatusLoket {
  String get label => switch (this) {
    StatusLoket.aktif => 'Aktif',
    StatusLoket.tutup => 'Tutup',
    StatusLoket.istirahat => 'Istirahat',
  };

  Color get badgeBg => switch (this) {
    StatusLoket.aktif => const Color(0xFFECFDF5),
    StatusLoket.tutup => const Color(0xFFFEF2F2),
    StatusLoket.istirahat => const Color(0xFFFEF3C7),
  };

  Color get badgeColor => switch (this) {
    StatusLoket.aktif => const Color(0xFF065F46),
    StatusLoket.tutup => const Color(0xFF991B1B),
    StatusLoket.istirahat => const Color(0xFF78350F),
  };

  Color get dotColor => switch (this) {
    StatusLoket.aktif => const Color(0xFF059669),
    StatusLoket.tutup => const Color(0xFFEF4444),
    StatusLoket.istirahat => const Color(0xFFD97706),
  };
}
