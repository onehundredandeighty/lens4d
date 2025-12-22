import 'package:test/test.dart';

import '../lib/lens4d.dart';
import 'test_utils.dart';

void main() {
  group('Query Parameter Lens Operations', () {
    test('should extract single query parameter values', () {
      final request = MockRequest(
        queryParams: {
          'search': ['dart programming'],
        },
      );

      final searchLens = Query.required('search');
      expect(searchLens(request), 'dart programming');
    });

    test('should handle missing query parameters', () {
      final request = MockRequest();

      final searchLens = Query.optional('search');
      expect(searchLens(request), isNull);
    });

    test('should extract multiple query parameter values', () {
      final request = MockRequest(
        queryParams: {
          'tags': ['red', 'blue', 'green'],
        },
      );

      final tagsLens = Query.multi.required('tags');
      expect(tagsLens(request), ['red', 'blue', 'green']);
    });

    test('should inject multiple query values', () {
      final request = MockRequest();

      final tagsLens = Query.multi.required('tags');
      final updated = tagsLens.inject(['javascript', 'dart'], request);
      expect(updated.queryParams['tags'], ['javascript', 'dart']);
    });

    test('should handle empty multi-value as optional', () {
      final request = MockRequest();

      final tagsLens = Query.multi.optional('tags');
      expect(tagsLens(request), isNull);
    });

    test('should convert query to int', () {
      final request = MockRequest(
        queryParams: {
          'limit': ['10'],
        },
      );

      final limitLens = Query.integer().required('limit');
      expect(limitLens(request), 10);
    });

    test('should convert query to boolean', () {
      final request = MockRequest(
        queryParams: {
          'debug': ['true'],
        },
      );

      final debugLens = Query.boolean().required('debug');
      expect(debugLens(request), true);
    });

    test('should use default values for missing query parameters', () {
      final request = MockRequest();

      final searchLens = Query.defaulted('search', 'default-search');
      expect(searchLens(request), 'default-search');
    });

    test('should inject single query parameter values', () {
      final request = MockRequest();

      final searchLens = Query.required('search');
      final updated = searchLens.inject('new search', request);
      expect(updated.queryParams['search'], ['new search']);
    });

    test('should handle multi-value query injection with null', () {
      final request = MockRequest(
        queryParams: {
          'tags': ['existing', 'tags'],
        },
      );

      final tagsLens = Query.multi.optional('tags');
      final updated = tagsLens.inject(null, request);
      expect(updated.queryParams.containsKey('tags'), false);
    });
  });
}
