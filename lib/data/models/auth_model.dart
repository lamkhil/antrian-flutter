import 'dart:convert';

/// ===============================
/// AUTH RESPONSE
/// ===============================
class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return AuthResponse(
      user: User.fromJson(data['user']),
      token: data['token'],
    );
  }
}

/// ===============================
/// USER MODEL
/// ===============================
class User {
  final int id;
  final String name;
  final String email;

  final List<Role> roles;
  final List<Permission> directPermissions;

  /// cache biar permission check O(1)
  late final Set<String> _permissionCache;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.directPermissions,
  }) {
    _permissionCache = _buildPermissionCache();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roles: (json['roles'] as List).map((e) => Role.fromJson(e)).toList(),
      directPermissions: (json['permissions'] as List)
          .map((e) => Permission.fromJson(e))
          .toList(),
    );
  }

  /// ===============================
  /// INTERNAL: gabungkan semua permission
  /// ===============================
  Set<String> _buildPermissionCache() {
    final perms = <String>{};

    // permission dari role
    for (final role in roles) {
      for (final p in role.permissions) {
        perms.add(p.name);
      }
    }

    // direct permission user
    for (final p in directPermissions) {
      perms.add(p.name);
    }

    return perms;
  }

  /// ===============================
  /// PUBLIC API (Laravel-like)
  /// ===============================

  /// sama seperti $user->can()
  bool can(String permission) => _permissionCache.contains(permission);

  /// OR condition
  bool canAny(List<String> permissions) =>
      permissions.any(_permissionCache.contains);

  /// AND condition
  bool canAll(List<String> permissions) =>
      permissions.every(_permissionCache.contains);

  bool hasRole(String roleName) => roles.any((r) => r.name == roleName);

  /// expose semua permission (readonly)
  Set<String> get permissions => _permissionCache;

  /// serialize buat simpan ke storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'roles': roles.map((e) => e.toJson()).toList(),
    'permissions': directPermissions.map((e) => e.toJson()).toList(),
  };

  String toRawJson() => jsonEncode(toJson());

  factory User.fromRawJson(String str) => User.fromJson(jsonDecode(str));
}

/// ===============================
/// ROLE
/// ===============================
class Role {
  final String name;
  final List<Permission> permissions;

  Role({required this.name, required this.permissions});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['name'],
      permissions: (json['permissions'] as List)
          .map((e) => Permission.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'permissions': permissions.map((e) => e.toJson()).toList(),
  };
}

/// ===============================
/// PERMISSION
/// ===============================
class Permission {
  final String name;

  Permission({required this.name});

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(name: json['name']);
  }

  Map<String, dynamic> toJson() => {'name': name};
}
