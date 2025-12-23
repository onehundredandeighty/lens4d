import 'package:test/test.dart';

import '../lib/lens4d.dart';
import 'test_utils.dart';

void main() {
  group('Headers Lens Operations', () {
    test('should extract required header values', () {
      final request = MockRequest(
        headers: {'Authorization': 'Bearer token123'},
      );

      final authLens = Header.required('Authorization');
      expect(authLens(request), 'Bearer token123');
    });

    test('should throw LensFailure for missing required headers', () {
      final request = MockRequest();

      final authLens = Header.required('Authorization');
      expect(() => authLens(request), throwsA(isA<LensFailure>()));
    });

    test('should return null for missing optional headers', () {
      final request = MockRequest();

      final authLens = Header.optional('Authorization');
      expect(authLens(request), isNull);
    });

    test('should use default values for headers', () {
      final request = MockRequest();

      final authLens = Header.defaulted('Authorization', 'default-token');
      expect(authLens(request), 'default-token');
    });

    test('should handle header injection', () {
      final request = MockRequest(
        headers: {'Content-Type': 'application/json'},
      );

      final contentTypeLens = Header.required('Content-Type');

      expect(contentTypeLens(request), 'application/json');

      final updatedRequest = contentTypeLens.inject('text/html', request);
      expect(updatedRequest.headers['Content-Type'], 'text/html');
    });

    test('should convert header to int', () {
      final request = MockRequest(headers: {'X-Timeout': '30'});

      final timeoutLens = Header.integer().required('X-Timeout');
      expect(timeoutLens(request), 30);

      final updated = timeoutLens.inject(60, request);
      expect(updated.headers['X-Timeout'], '60');
    });

    test('should convert header to boolean', () {
      final request = MockRequest(headers: {'X-Debug': 'true'});

      final debugLens = Header.boolean().required('X-Debug');
      expect(debugLens(request), true);
    });

    test('should handle CSV headers', () {
      final request = MockRequest(headers: {'X-Items': '1,2,3,4,5'});

      final itemsLens = Header.csv(
        ',',
        StringBiDiMappings.integer(),
      ).required('X-Items');

      final items = itemsLens(request);
      expect(items, [1, 2, 3, 4, 5]);

      final updated = itemsLens.inject([10, 20, 30], request);
      expect(updated.headers['X-Items'], '10,20,30');
    });

    test('should handle optional integer header', () {
      final request1 = MockRequest();
      final request2 = MockRequest(headers: {'X-Count': '42'});

      final countLens = Header.integer().optional('X-Count');

      expect(countLens(request1), isNull);
      expect(countLens(request2), 42);
    });
  });
}
