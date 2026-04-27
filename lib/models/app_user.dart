import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole {
  admin,
  counter;

  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.counter => 'Loket',
      };

  static UserRole fromName(String? name) {
    return UserRole.values.firstWhere(
      (r) => r.name == name,
      orElse: () => UserRole.counter,
    );
  }
}

class AppUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? counterId;
  final bool paused;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.counterId,
    this.paused = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.name,
        'counterId': counterId,
        'paused': paused,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final raw = map['createdAt'];
    DateTime? created;
    if (raw is Timestamp) created = raw.toDate();
    if (raw is DateTime) created = raw;
    return AppUser(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      role: UserRole.fromName(map['role']?.toString()),
      counterId: map['counterId']?.toString(),
      paused: (map['paused'] as bool?) ?? false,
      createdAt: created,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? counterId,
    bool? paused,
    DateTime? createdAt,
  }) =>
      AppUser(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        role: role ?? this.role,
        counterId: counterId ?? this.counterId,
        paused: paused ?? this.paused,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id];
}
