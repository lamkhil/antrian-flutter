import 'dart:convert';

import 'package:antrian/data/services/admin/service_account_storage.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _validSample() => {
      'type': 'service_account',
      'project_id': 'my-project',
      'private_key_id': 'abc123',
      'private_key':
          '-----BEGIN PRIVATE KEY-----\nMIIEv...\n-----END PRIVATE KEY-----\n',
      'client_email': 'sa@my-project.iam.gserviceaccount.com',
      'client_id': '1234567890',
      'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
      'token_uri': 'https://oauth2.googleapis.com/token',
    };

void main() {
  group('ServiceAccountStorage.validate', () {
    test('accepts a fully-valid service account JSON', () {
      final raw = jsonEncode(_validSample());
      final parsed = ServiceAccountStorage.validate(raw);
      expect(parsed['project_id'], 'my-project');
      expect(parsed['client_email'], isNotEmpty);
    });

    test('rejects invalid JSON syntax', () {
      expect(
        () => ServiceAccountStorage.validate('{not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects non-object JSON (array)', () {
      expect(
        () => ServiceAccountStorage.validate('[1,2,3]'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects non-object JSON (string)', () {
      expect(
        () => ServiceAccountStorage.validate('"just a string"'),
        throwsA(isA<FormatException>()),
      );
    });

    for (final field in [
      'type',
      'project_id',
      'private_key',
      'client_email',
      'client_id',
    ]) {
      test('rejects missing $field', () {
        final data = _validSample()..remove(field);
        expect(
          () => ServiceAccountStorage.validate(jsonEncode(data)),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains(field),
            ),
          ),
        );
      });

      test('rejects empty $field', () {
        final data = _validSample()..[field] = '';
        expect(
          () => ServiceAccountStorage.validate(jsonEncode(data)),
          throwsA(isA<FormatException>()),
        );
      });
    }

    test('rejects wrong type (not "service_account")', () {
      final data = _validSample()..['type'] = 'user';
      expect(
        () => ServiceAccountStorage.validate(jsonEncode(data)),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('service_account'),
          ),
        ),
      );
    });

    test('rejects private_key without BEGIN PRIVATE KEY marker', () {
      final data = _validSample()..['private_key'] = 'not-a-real-key';
      expect(
        () => ServiceAccountStorage.validate(jsonEncode(data)),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('private_key'),
          ),
        ),
      );
    });

    test('rejects non-string field value (numeric project_id)', () {
      final data = _validSample()..['project_id'] = 42;
      expect(
        () => ServiceAccountStorage.validate(jsonEncode(data)),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
