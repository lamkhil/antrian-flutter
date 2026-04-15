import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum RolePengguna { admin, supervisor, operator }

enum StatusPengguna { aktif, nonAktif }

class Pengguna extends Equatable {
  final String id;
  final String nama;
  final String email;
  final RolePengguna role;
  final StatusPengguna status;
  final String? lokasiId;

  const Pengguna({
    required this.id,
    required this.nama,
    required this.email,
    this.role = RolePengguna.operator,
    this.status = StatusPengguna.aktif,
    this.lokasiId,
  });

  Pengguna copyWith({
    String? nama,
    String? email,
    RolePengguna? role,
    StatusPengguna? status,
    String? lokasiId,
  }) => Pengguna(
    id: id,
    nama: nama ?? this.nama,
    email: email ?? this.email,
    role: role ?? this.role,
    status: status ?? this.status,
    lokasiId: lokasiId ?? this.lokasiId,
  );

  factory Pengguna.fromJson(Map<String, dynamic> json) => Pengguna(
    id: json['id'],
    nama: json['nama'] ?? '',
    email: json['email'] ?? '',
    role: RolePengguna.values.firstWhere(
      (r) => r.name == (json['role'] as String?)?.toLowerCase(),
      orElse: () => RolePengguna.operator,
    ),
    status: StatusPengguna.values.firstWhere(
      (s) => s.name == (json['status'] as String?)?.toLowerCase(),
      orElse: () => StatusPengguna.aktif,
    ),
    lokasiId: json['lokasiId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'email': email,
    'role': role.name,
    'status': status.name,
    'lokasiId': lokasiId,
  };

  @override
  List<Object?> get props => [id];
}

extension RolePenggunaX on RolePengguna {
  String get label => switch (this) {
    RolePengguna.admin => 'Admin',
    RolePengguna.supervisor => 'Supervisor',
    RolePengguna.operator => 'Operator',
  };
}

extension StatusPenggunaX on StatusPengguna {
  String get label => switch (this) {
    StatusPengguna.aktif => 'Aktif',
    StatusPengguna.nonAktif => 'Non-aktif',
  };

  Color get badgeBg => switch (this) {
    StatusPengguna.aktif => const Color(0xFFECFDF5),
    StatusPengguna.nonAktif => const Color(0xFFFEF2F2),
  };

  Color get badgeColor => switch (this) {
    StatusPengguna.aktif => const Color(0xFF065F46),
    StatusPengguna.nonAktif => const Color(0xFF991B1B),
  };

  Color get dotColor => switch (this) {
    StatusPengguna.aktif => const Color(0xFF059669),
    StatusPengguna.nonAktif => const Color(0xFFEF4444),
  };
}
