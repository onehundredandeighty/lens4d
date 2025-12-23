import 'bidi_lens.dart';
import 'bidimapping.dart';
import 'failure.dart';
import 'interfaces.dart';
import 'lens.dart';
import 'lens_get_set.dart';
import 'lens_spec.dart';
import 'meta.dart';
import 'string_mappings.dart';

/// Represents a bi-directional extraction of an entity from a target, or an insertion into a target.
///
/// A BiDiLensSpec extends [LensSpec] with injection capabilities, allowing both extraction and
/// insertion of values. It serves as a factory for creating concrete [BiDiLens] instances.
class BiDiLensSpec<IN extends Object, OUT> extends LensSpec<IN, OUT>
    implements BiDiLensBuilder<IN, OUT> {
  /// The injection function that sets values into the target.
  final LensSet<IN, OUT> set;

  /// Create a new BiDiLensSpec with the specified location, parameter metadata,
  /// extraction function, and injection function.
  BiDiLensSpec(
    String location,
    ParamMeta paramMeta,
    LensGet<IN, OUT> get,
    this.set,
  ) : super(location, paramMeta, get);

  /// Create a LensSpec which applies the uni-directional transformation to the result.
  ///
  /// When mapping with just one function (unidirectional), the result loses bidirectional
  /// capability and returns a regular [LensSpec] instead of a [BiDiLensSpec].
  @override
  LensSpec<IN, NEXT> map<NEXT>(NEXT Function(OUT) nextIn) =>
      LensSpec(location, paramMeta, get.map(nextIn));

  /// Create another BiDiLensSpec which applies the bi-directional transformations to the result.
  ///
  /// Any resultant Lens can be used to extract or insert the final type from/into a target.
  BiDiLensSpec<IN, NEXT> mapBiDi<NEXT>(
    NEXT Function(OUT) nextIn,
    OUT Function(NEXT) nextOut,
  ) => mapWithNewMeta(nextIn, nextOut, paramMeta);

  BiDiLensSpec<IN, NEXT> mapWithNewMeta<NEXT>(
    NEXT Function(OUT) nextIn,
    OUT Function(NEXT) nextOut,
    ParamMeta newParamMeta,
  ) => BiDiLensSpec(location, newParamMeta, get.map(nextIn), set.map(nextOut));

  BiDiLensSpec<IN, NEXT> mapWithMapping<NEXT>(BiDiMapping<OUT, NEXT> mapping) {
    return mapBiDi(mapping.fromIn, mapping.fromOut);
  }

  @override
  BiDiLens<IN, OUT> defaulted(
    String name,
    OUT defaultValue, {
    String? description,
  }) => defaultedTo(
    name,
    Lens(
      Meta(
        required: false,
        location: location,
        paramMeta: paramMeta,
        name: name,
        description: description,
      ),
      (_) => defaultValue,
    ),
  );

  @override
  BiDiLens<IN, OUT> defaultedTo(
    String name,
    LensExtractor<IN, OUT> defaultLens, {
    String? description,
  }) {
    final getLens = (IN target) => get(name, target);
    final setLens =
        (String name, List<OUT> values, IN target) => set(name, values, target);
    return BiDiLens(
      Meta(
        required: false,
        location: location,
        paramMeta: paramMeta,
        name: name,
        description: description,
      ),
      (target) {
        final results = getLens(target);
        return results.isEmpty ? defaultLens(target) : results.first;
      },
      (OUT value, IN target) => setLens(name, [value], target),
    );
  }

  @override
  BiDiLens<IN, OUT?> optional(String name, {String? description}) {
    final getLens = (IN target) => get(name, target);
    final setLens =
        (String name, List<OUT> values, IN target) => set(name, values, target);
    return BiDiLens(
      Meta(
        required: false,
        location: location,
        paramMeta: paramMeta,
        name: name,
        description: description,
      ),
      (target) {
        final results = getLens(target);
        return results.isEmpty ? null : results.first;
      },
      (OUT? value, IN target) =>
          setLens(name, value != null ? [value] : [], target),
    );
  }

  @override
  BiDiLens<IN, OUT> required(String name, {String? description}) {
    final meta = Meta(
      required: true,
      location: location,
      paramMeta: paramMeta,
      name: name,
      description: description,
    );
    final getLens = (IN target) => get(name, target);
    final setLens =
        (String name, List<OUT> values, IN target) => set(name, values, target);
    return BiDiLens(meta, (target) {
      final results = getLens(target);
      if (results.isEmpty) {
        throw LensFailure.single(Missing(meta), target: target);
      }
      return results.first;
    }, (OUT value, IN target) => setLens(name, [value], target));
  }

  BiDiLensBuilder<IN, List<OUT>> get multi => _MultiBiDiLensBuilder(this);
}

class _MultiBiDiLensBuilder<IN extends Object, OUT>
    implements BiDiLensBuilder<IN, List<OUT>> {
  final BiDiLensSpec<IN, OUT> _spec;

  _MultiBiDiLensBuilder(this._spec);

  @override
  BiDiLens<IN, List<OUT>> defaulted(
    String name,
    List<OUT> defaultValue, {
    String? description,
  }) => defaultedTo(
    name,
    Lens(
      Meta(
        required: false,
        location: _spec.location,
        paramMeta: ArrayParam(_spec.paramMeta),
        name: name,
        description: description,
      ),
      (_) => defaultValue,
    ),
  );

  @override
  BiDiLens<IN, List<OUT>> defaultedTo(
    String name,
    LensExtractor<IN, List<OUT>> defaultLens, {
    String? description,
  }) {
    final getLens = (IN target) => _spec.get(name, target);
    final setLens =
        (String name, List<OUT> values, IN target) =>
            _spec.set(name, values, target);
    return BiDiLens(
      Meta(
        required: false,
        location: _spec.location,
        paramMeta: ArrayParam(_spec.paramMeta),
        name: name,
        description: description,
      ),
      (target) {
        final results = getLens(target);
        return results.isEmpty ? defaultLens(target) : results;
      },
      (List<OUT> values, IN target) => setLens(name, values, target),
    );
  }

  @override
  BiDiLens<IN, List<OUT>?> optional(String name, {String? description}) {
    final getLens = (IN target) => _spec.get(name, target);
    final setLens =
        (String name, List<OUT> values, IN target) =>
            _spec.set(name, values, target);
    return BiDiLens(
      Meta(
        required: false,
        location: _spec.location,
        paramMeta: ArrayParam(_spec.paramMeta),
        name: name,
        description: description,
      ),
      (target) {
        final results = getLens(target);
        return results.isEmpty ? null : results;
      },
      (List<OUT>? values, IN target) => setLens(name, values ?? [], target),
    );
  }

  @override
  BiDiLens<IN, List<OUT>> required(String name, {String? description}) {
    final meta = Meta(
      required: true,
      location: _spec.location,
      paramMeta: ArrayParam(_spec.paramMeta),
      name: name,
      description: description,
    );
    final getLens = (IN target) => _spec.get(name, target);
    final setLens =
        (String name, List<OUT> values, IN target) =>
            _spec.set(name, values, target);
    return BiDiLens(meta, (target) {
      final results = getLens(target);
      if (results.isEmpty) {
        throw LensFailure.single(Missing(meta), target: target);
      }
      return results;
    }, (List<OUT> values, IN target) => setLens(name, values, target));
  }
}

/// Convenience extension methods for [BiDiLensSpec] that work with String values.
///
/// These extensions provide type conversion capabilities, transforming string-based
/// lens specs into lens specs for other types like int, double, bool, Uri, DateTime, etc.
/// This corresponds to the Kotlin extension functions in lensSpec.kt.
extension BiDiLensSpecExtensions<IN extends Object>
    on BiDiLensSpec<IN, String> {
  BiDiLensSpec<IN, String> string() => this;

  BiDiLensSpec<IN, String> nonEmptyString() =>
      mapWithMapping(StringBiDiMappings.nonEmpty());

  BiDiLensSpec<IN, String> nonBlankString() =>
      mapWithMapping(StringBiDiMappings.nonBlank());

  BiDiLensSpec<IN, int> integer() => mapWithNewMeta(
    StringBiDiMappings.integer().asOut,
    StringBiDiMappings.integer().asIn,
    const IntegerParam(),
  );

  BiDiLensSpec<IN, double> decimal() => mapWithNewMeta(
    StringBiDiMappings.float().asOut,
    StringBiDiMappings.float().asIn,
    const NumberParam(),
  );

  BiDiLensSpec<IN, bool> boolean() => mapWithNewMeta(
    StringBiDiMappings.boolean().asOut,
    StringBiDiMappings.boolean().asIn,
    const BooleanParam(),
  );

  BiDiLensSpec<IN, DateTime> dateTime() =>
      mapWithMapping(StringBiDiMappings.dateTime());

  BiDiLensSpec<IN, RegExp> regexObject() =>
      mapWithMapping(StringBiDiMappings.regexObject());

  BiDiLensSpec<IN, List<T>> csv<T>(
    String delimiter,
    BiDiMapping<String, T> mapElement,
  ) => mapWithMapping(StringBiDiMappings.csv(delimiter, mapElement));
}

extension BiDiLensSpecComposite<IN extends Object> on BiDiLensSpec<IN, String> {
  LensSpec<IN, T> composite<T extends Object>(
    T Function(BiDiLensSpec<IN, String>, IN) getFn,
  ) => LensSpec<IN, T>(
    T.toString(),
    const ObjectParam(),
    LensGet((_, target) => [getFn(this, target)]),
  );

  BiDiLensSpec<IN, T> compositeBiDi<T extends Object>(
    T Function(BiDiLensSpec<IN, String>, IN) getFn,
    IN Function(T, IN) setFn,
  ) => BiDiLensSpec(
    T.toString(),
    const ObjectParam(),
    LensGet((_, target) => [getFn(this, target)]),
    LensSet<IN, T>(
      (_, values, target) =>
          values.fold(target, (acc, value) => setFn(value, acc)),
    ),
  );
}

/// Extension methods for chaining lens injections.
///
/// This allows clean functional composition of lens modifications:
/// ```dart
/// // Single modifier
/// final result = uri.having(Query.required('search').of('dart'));
///
/// // Multiple modifiers
/// final result = uri.havingAll([
///   Query.required('search').of('dart'),
///   Query.integer().required('limit').of(50),
///   Query.boolean().required('debug').of(true),
/// ]);
/// ```
extension LensHavingModifiers<T> on T {
  /// Apply a single lens modifier function to this object.
  T having(T Function(T) modifier) => modifier(this);

  /// Apply multiple lens modifier functions to this object in sequence.
  T havingAll(List<T Function(T)> modifiers) =>
      modifiers.fold(this, (memo, next) => next(memo));
}
