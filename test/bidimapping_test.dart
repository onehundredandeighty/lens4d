import 'package:test/test.dart';

import '../lib/lens4d.dart';

void main() {
  group('BiDiMapping', () {
    test('should transform values bi-directionally', () {
      final intMapping = StringBiDiMappings.integer();

      expect(intMapping.fromIn('42'), 42);
      expect(intMapping.fromOut(42), '42');
      expect(intMapping('42'), 42);
    });

    test('should handle boolean conversions', () {
      final boolMapping = StringBiDiMappings.boolean();

      expect(boolMapping.fromIn('true'), true);
      expect(boolMapping.fromIn('TRUE'), true);
      expect(boolMapping.fromIn('false'), false);
      expect(boolMapping.fromIn('FALSE'), false);

      expect(() => boolMapping.fromIn('maybe'), throwsA(isA<ArgumentError>()));
    });

    test('should handle CSV parsing', () {
      final csvMapping = StringBiDiMappings.csv(
        ',',
        StringBiDiMappings.integer(),
      );

      expect(csvMapping.fromIn('1,2,3'), [1, 2, 3]);
      expect(csvMapping.fromOut([1, 2, 3]), '1,2,3');
      expect(csvMapping.fromIn(''), <int>[]);
    });

    test('should handle URI conversions', () {
      final uriMapping = StringBiDiMappings.uri();

      final uri = Uri.parse('https://example.com/path?param=value');
      final uriString = 'https://example.com/path?param=value';

      expect(uriMapping.fromIn(uriString), uri);
      expect(uriMapping.fromOut(uri), uriString);
    });

    test('should handle DateTime conversions', () {
      final dateTimeMapping = StringBiDiMappings.dateTime();

      final dateTime = DateTime.parse('2023-12-25T10:30:00.000Z');
      final dateTimeString = '2023-12-25T10:30:00.000Z';

      expect(dateTimeMapping.fromIn(dateTimeString), dateTime);
      expect(dateTimeMapping.fromOut(dateTime), dateTimeString);
    });

    test('should handle RegExp conversions', () {
      final regexMapping = StringBiDiMappings.regexObject();

      final pattern = r'\d+';
      final regex = RegExp(pattern);

      expect(regexMapping.fromIn(pattern), regex);
      expect(regexMapping.fromOut(regex), pattern);
    });

    test('should validate non-empty strings', () {
      final nonEmptyMapping = StringBiDiMappings.nonEmpty();

      expect(nonEmptyMapping.fromIn('valid'), 'valid');
      expect(nonEmptyMapping.fromOut('valid'), 'valid');
      expect(() => nonEmptyMapping.fromIn(''), throwsA(isA<ArgumentError>()));
    });

    test('should validate non-blank strings', () {
      final nonBlankMapping = StringBiDiMappings.nonBlank();

      expect(nonBlankMapping.fromIn('valid'), 'valid');
      expect(nonBlankMapping.fromOut('valid'), 'valid');
      expect(
        () => nonBlankMapping.fromIn('   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
