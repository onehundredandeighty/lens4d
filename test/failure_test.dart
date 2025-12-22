import 'package:test/test.dart';

import '../lib/lens4d.dart';
import 'test_utils.dart';

void main() {
  group('LensFailure and Failure Types', () {
    test('should create different failure types', () {
      final meta = Meta(
        required: true,
        location: 'header',
        paramMeta: const StringParam(),
        name: 'test',
      );

      final missing = Missing(meta);
      final invalid = Invalid(meta);
      final unsupported = Unsupported(meta);

      expect(missing.type, FailureType.missing);
      expect(invalid.type, FailureType.invalid);
      expect(unsupported.type, FailureType.unsupported);

      expect(missing.toString(), contains('is required'));
      expect(invalid.toString(), contains('must be string'));
      expect(unsupported.toString(), contains('is not acceptable'));
    });

    test('should aggregate failures correctly', () {
      final meta = Meta(
        required: true,
        location: 'header',
        paramMeta: const StringParam(),
        name: 'test',
      );

      final failure1 = LensFailure([Missing(meta), Invalid(meta)]);
      expect(failure1.overall(), FailureType.invalid);

      final failure2 = LensFailure([Missing(meta), Unsupported(meta)]);
      expect(failure2.overall(), FailureType.unsupported);

      final failure3 = LensFailure([Missing(meta)]);
      expect(failure3.overall(), FailureType.missing);
    });
  });

  group('Lens Metadata', () {
    test('should provide correct metadata information', () {
      final lens = Header.integer().required('X-Timeout');
      
      expect(lens.meta.required, true);
      expect(lens.meta.location, 'header');
      expect(lens.meta.name, 'X-Timeout');
      expect(lens.meta.paramMeta, isA<IntegerParam>());
    });

    test('should display lens information correctly', () {
      final lens = Header.required('Authorization');
      expect(lens.toString(), 'Required header \'Authorization\'');

      final optionalLens = Header.optional('X-Optional');
      expect(optionalLens.toString(), 'Optional header \'X-Optional\'');
    });
  });
}
