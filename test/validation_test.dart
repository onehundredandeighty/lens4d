import 'package:test/test.dart';

import '../lib/lens4d.dart';
import 'test_utils.dart';

void main() {
  group('Complex Validation Scenarios', () {
    test('should handle validation failures', () {
      final request = MockRequest(headers: {'X-Timeout': 'invalid-number'});

      final timeoutLens = Header.integer().required('X-Timeout');
      expect(() => timeoutLens(request), throwsA(isA<LensFailure>()));
    });

    test('should validate non-empty and non-blank strings', () {
      final request1 = MockRequest(headers: {'X-Name': ''});
      final request2 = MockRequest(headers: {'X-Name': '   '});
      final request3 = MockRequest(headers: {'X-Name': 'valid'});

      final nonEmptyLens = Header.nonEmptyString().required('X-Name');
      final nonBlankLens = Header.nonBlankString().required('X-Name');

      expect(() => nonEmptyLens(request1), throwsA(isA<LensFailure>()));
      expect(() => nonBlankLens(request2), throwsA(isA<LensFailure>()));
      expect(nonEmptyLens(request3), 'valid');
      expect(nonBlankLens(request3), 'valid');
    });

    test('should handle boolean parsing failures', () {
      final request = MockRequest(headers: {'X-Flag': 'maybe'});

      final flagLens = Header.boolean().required('X-Flag');
      expect(() => flagLens(request), throwsA(isA<LensFailure>()));
    });

    test('should handle integer parsing failures in query params', () {
      final request = MockRequest(
        queryParams: {
          'limit': ['not-a-number'],
        },
      );

      final limitLens = Query.integer().required('limit');
      expect(() => limitLens(request), throwsA(isA<LensFailure>()));
    });

    test('should handle missing required query parameters', () {
      final request = MockRequest();

      final searchLens = Query.required('search');
      expect(() => searchLens(request), throwsA(isA<LensFailure>()));
    });

    test('should provide meaningful error messages', () {
      final request = MockRequest();
      final authLens = Header.required('Authorization');

      try {
        authLens(request);
        fail('Expected LensFailure to be thrown');
      } catch (e) {
        expect(e, isA<LensFailure>());
        final failure = e as LensFailure;
        expect(failure.toString(), contains('Authorization'));
        expect(failure.toString(), contains('required'));
      }
    });

    test('should handle multiple validation failures', () {
      final request = MockRequest(
        headers: {'X-Count': 'invalid'},
        queryParams: {'missing-required': []},
      );

      // Test that each lens throws its own specific failure
      final countLens = Header.integer().required('X-Count');
      final requiredLens = Query.required('missing-required');

      expect(() => countLens(request), throwsA(isA<LensFailure>()));
      expect(() => requiredLens(request), throwsA(isA<LensFailure>()));
    });
  });
}
