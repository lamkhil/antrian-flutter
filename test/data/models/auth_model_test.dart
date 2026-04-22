import 'package:antrian/data/models/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User permissions', () {
    User buildUser({
      List<String> rolePerms = const [],
      List<String> directPerms = const [],
    }) => User(
      id: 1,
      name: 'Tester',
      email: 't@e.com',
      roles: [
        Role(
          name: 'operator',
          permissions: rolePerms.map((p) => Permission(name: p)).toList(),
        ),
      ],
      directPermissions:
          directPerms.map((p) => Permission(name: p)).toList(),
    );

    test('can() returns true for permission granted via role', () {
      final u = buildUser(rolePerms: ['antrian.read']);
      expect(u.can('antrian.read'), isTrue);
      expect(u.can('antrian.write'), isFalse);
    });

    test('can() returns true for direct permission', () {
      final u = buildUser(directPerms: ['laporan.view']);
      expect(u.can('laporan.view'), isTrue);
    });

    test('canAny / canAll', () {
      final u = buildUser(
        rolePerms: ['a', 'b'],
        directPerms: ['c'],
      );
      expect(u.canAny(['a', 'x']), isTrue);
      expect(u.canAny(['x', 'y']), isFalse);
      expect(u.canAll(['a', 'b', 'c']), isTrue);
      expect(u.canAll(['a', 'd']), isFalse);
    });

    test('hasRole', () {
      final u = buildUser();
      expect(u.hasRole('operator'), isTrue);
      expect(u.hasRole('admin'), isFalse);
    });

    test('permissions getter dedupes role + direct', () {
      final u = buildUser(rolePerms: ['x', 'y'], directPerms: ['y', 'z']);
      expect(u.permissions, {'x', 'y', 'z'});
    });

    test('toJson/fromRawJson roundtrip', () {
      final u = buildUser(rolePerms: ['a'], directPerms: ['b']);
      final restored = User.fromRawJson(u.toRawJson());
      expect(restored.id, u.id);
      expect(restored.email, u.email);
      expect(restored.permissions, u.permissions);
    });
  });
}
