import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:antrian/data/models/layanan.dart';
import 'package:antrian/data/models/loket.dart';
import 'package:antrian/data/models/zona.dart';
import 'package:antrian/data/models/lokasi.dart';

enum StatusAntrian { menunggu, dipanggil, dilayani, dilewati, selesai }

class Antrian extends Equatable {
  final String id;
  final String nomorAntrian;
  final String nama;
  final String layananId;
  final String zonaId;
  final String lokasiId;
  final String? loketId;
  final StatusAntrian status;
  final DateTime waktuDaftar;
  final DateTime? waktuDipanggil;
  final DateTime? waktuSelesai;
  final Layanan layanan;
  final Zona zona;
  final Lokasi lokasi;
  final Loket? loket;

  const Antrian({
    required this.id,
    required this.nomorAntrian,
    required this.nama,
    required this.layananId,
    required this.zonaId,
    required this.lokasiId,
    required this.status,
    required this.waktuDaftar,
    required this.layanan,
    required this.zona,
    required this.lokasi,
    this.loketId,
    this.loket,
    this.waktuDipanggil,
    this.waktuSelesai,
  });

  factory Antrian.fromJson(Map<String, dynamic> json) => Antrian(
    id: json['id'],
    nomorAntrian: json['nomorAntrian'],
    nama: json['nama'],
    layananId: json['layananId'],
    zonaId: json['zonaId'],
    lokasiId: json['lokasiId'],
    loketId: json['loketId'],
    status: StatusAntrian.values.firstWhere(
      (s) => s.name == (json['status'] as String).toLowerCase(),
      orElse: () => StatusAntrian.menunggu,
    ),
    waktuDaftar: (json['waktuDaftar'] as Timestamp).toDate(),
    waktuDipanggil: json['waktuDipanggil'] != null
        ? (json['waktuDipanggil'] as Timestamp).toDate()
        : null,
    waktuSelesai: json['waktuSelesai'] != null
        ? (json['waktuSelesai'] as Timestamp).toDate()
        : null,
    layanan: Layanan.fromJson(json['layanan'] ?? {}),
    zona: Zona.fromJson(json['zona'] ?? {}),
    lokasi: Lokasi.fromJson(json['lokasi'] ?? {}),
    loket: json['loket'] != null ? Loket.fromJson(json['loket']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nomorAntrian': nomorAntrian,
    'nama': nama,
    'layananId': layananId,
    'zonaId': zonaId,
    'lokasiId': lokasiId,
    'loketId': loketId,
    'status': status.name,
    'waktuDaftar': waktuDaftar.toIso8601String(),
    'waktuDipanggil': waktuDipanggil?.toIso8601String(),
    'waktuSelesai': waktuSelesai?.toIso8601String(),
    'layanan': layanan.toJson(),
    'zona': zona.toJson(),
    'lokasi': lokasi.toJson(),
    'loket': loket?.toJson(),
  };

  @override
  List<Object?> get props => [id];
}

extension StatusAntrianX on StatusAntrian {
  String get label => switch (this) {
    StatusAntrian.menunggu => 'Menunggu',
    StatusAntrian.dipanggil => 'Dipanggil',
    StatusAntrian.dilayani => 'Dilayani',
    StatusAntrian.dilewati => 'Dilewati',
    StatusAntrian.selesai => 'Selesai',
  };

  Color get badgeBg => switch (this) {
    StatusAntrian.menunggu => const Color(0xFFEEF2FF),
    StatusAntrian.dipanggil => const Color(0xFFFEF3C7),
    StatusAntrian.dilayani => const Color(0xFFE1F5EE),
    StatusAntrian.dilewati => const Color(0xFFFEF2F2),
    StatusAntrian.selesai => const Color(0xFFF3F4F6),
  };

  Color get badgeColor => switch (this) {
    StatusAntrian.menunggu => const Color(0xFF3730A3),
    StatusAntrian.dipanggil => const Color(0xFF78350F),
    StatusAntrian.dilayani => const Color(0xFF065F46),
    StatusAntrian.dilewati => const Color(0xFF991B1B),
    StatusAntrian.selesai => const Color(0xFF374151),
  };

  Color get dotColor => switch (this) {
    StatusAntrian.menunggu => const Color(0xFF6366F1),
    StatusAntrian.dipanggil => const Color(0xFFD97706),
    StatusAntrian.dilayani => const Color(0xFF059669),
    StatusAntrian.dilewati => const Color(0xFFEF4444),
    StatusAntrian.selesai => const Color(0xFF9CA3AF),
  };

  Color get statColor => switch (this) {
    StatusAntrian.menunggu => const Color(0xFF6366F1),
    StatusAntrian.dipanggil => const Color(0xFFD97706),
    StatusAntrian.dilayani => const Color(0xFF059669),
    StatusAntrian.dilewati => const Color(0xFFEF4444),
    StatusAntrian.selesai => const Color(0xFF9CA3AF),
  };
}
