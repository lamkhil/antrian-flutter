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
  /// Daftar lokasi (tenant) yang user ini punya akses.
  /// Admin global bypass ini — lihat semua lokasi.
  final List<String> lokasiIds;

  const Pengguna({
    required this.id,
    required this.nama,
    required this.email,
    this.role = RolePengguna.operator,
    this.status = StatusPengguna.aktif,
    this.lokasiIds = const [],
  });

  Pengguna copyWith({
    String? nama,
    String? email,
    RolePengguna? role,
    StatusPengguna? status,
    List<String>? lokasiIds,
  }) => Pengguna(
    id: id,
    nama: nama ?? this.nama,
    email: email ?? this.email,
    role: role ?? this.role,
    status: status ?? this.status,
    lokasiIds: lokasiIds ?? this.lokasiIds,
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
    // Kompatibel dengan data lama yang masih punya single `lokasiId`.
    lokasiIds: _readLokasiIds(json),
  );

  static List<String> _readLokasiIds(Map<String, dynamic> json) {
    final list = json['lokasiIds'];
    if (list is List) return list.map((e) => e.toString()).toList();
    final single = json['lokasiId'];
    if (single is String && single.isNotEmpty) return [single];
    return const [];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'email': email,
    'role': role.name,
    'status': status.name,
    'lokasiIds': lokasiIds,
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
