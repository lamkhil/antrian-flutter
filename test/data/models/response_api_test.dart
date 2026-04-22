import 'package:antrian/data/models/response_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponseApi', () {
    test('default constructor sets success=true', () {
      final r = ResponseApi<String>(data: 'hello');
      expect(r.success, isTrue);
      expect(r.data, 'hello');
      expect(r.message, isNull);
    });

    test('ResponseApi.error', () {
      final r = ResponseApi.error('network down');
      expect(r.success, isFalse);
      expect(r.message, 'network down');
      expect(r.data, isNull);
    });

    test('fromJson single object', () {
      final r = ResponseApi<int>.fromJson(
        {'data': 5, 'message': 'ok', 'success': true},
        data: (v) => v as int,
      );
      expect(r.data, 5);
      expect(r.message, 'ok');
      expect(r.success, isTrue);
    });

    test('fromJson Laravel pagination shape', () {
      final r = ResponseApi<List<int>>.fromJson(
        {
          'current_page': 2,
          'last_page': 5,
          'per_page': 10,
          'total': 48,
          'next_page_url': '/api/page=3',
          'prev_page_url': '/api/page=1',
          'data': [],
        },
        list: const [],
      );
      expect(r.pagination?.currentPage, 2);
      expect(r.pagination?.lastPage, 5);
      expect(r.pagination?.perPage, 10);
      expect(r.pagination?.total, 48);
      expect(r.pagination?.hasNext, isTrue);
    });

    test('PaginationMeta.hasNext false when nextPageUrl is null', () {
      final m = PaginationMeta(
        currentPage: 5,
        lastPage: 5,
        perPage: 10,
        total: 48,
      );
      expect(m.hasNext, isFalse);
    });
  });
}
