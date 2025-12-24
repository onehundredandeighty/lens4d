import 'lens_failure.dart';
import 'interfaces.dart';
import 'lens.dart';
import 'lens_get_set.dart';
import 'meta.dart';

/// Represents a uni-directional extraction of an entity from a target.
///
/// A LensSpec defines how to extract values from a target object at a specific location,
/// with a particular parameter type. It serves as a factory for creating concrete [Lens] instances.
class LensSpec<IN extends Object, OUT> implements LensBuilder<IN, OUT> {
  /// The location where this lens operates (e.g., 'header', 'query', 'body').
  final String location;

  /// Metadata describing the expected parameter type.
  final ParamMeta paramMeta;

  /// The extraction function that retrieves values from the target.
  final LensGet<IN, OUT> get;

  /// Create a new LensSpec with the specified location, parameter metadata, and extraction function.
  LensSpec(this.location, this.paramMeta, this.get);

  /// Create another LensSpec which applies the uni-directional transformation to the result.
  ///
  /// Any resultant Lens can only be used to extract the final type from a target.
  LensSpec<IN, NEXT> map<NEXT>(NEXT Function(OUT) nextIn) =>
      LensSpec(location, paramMeta, get.map(nextIn));

  @override
  Lens<IN, OUT> defaulted(
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
  Lens<IN, OUT> defaultedTo(
    String name,
    LensExtractor<IN, OUT> defaultLens, {
    String? description,
  }) {
    final getLens = (IN target) => get(name, target);
    return Lens(
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
    );
  }

  @override
  Lens<IN, OUT?> optional(String name, {String? description}) {
    final getLens = (IN target) => get(name, target);
    return Lens(
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
    );
  }

  @override
  Lens<IN, OUT> required(String name, {String? description}) {
    final meta = Meta(
      required: true,
      location: location,
      paramMeta: paramMeta,
      name: name,
      description: description,
    );
    final getLens = (IN target) => get(name, target);
    return Lens(meta, (target) {
      final results = getLens(target);
      if (results.isEmpty) {
        throw LensFailure.single(Missing(meta), target: target);
      }
      return results.first;
    });
  }

  LensBuilder<IN, List<OUT>> get multi => _MultiLensBuilder(this);
}

class _MultiLensBuilder<IN extends Object, OUT>
    implements LensBuilder<IN, List<OUT>> {
  final LensSpec<IN, OUT> _spec;

  _MultiLensBuilder(this._spec);

  @override
  Lens<IN, List<OUT>> defaulted(
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
  Lens<IN, List<OUT>> defaultedTo(
    String name,
    LensExtractor<IN, List<OUT>> defaultLens, {
    String? description,
  }) {
    final getLens = (IN target) => _spec.get(name, target);
    return Lens(
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
    );
  }

  @override
  Lens<IN, List<OUT>?> optional(String name, {String? description}) {
    final getLens = (IN target) => _spec.get(name, target);
    return Lens(
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
    );
  }

  @override
  Lens<IN, List<OUT>> required(String name, {String? description}) {
    final meta = Meta(
      required: true,
      location: _spec.location,
      paramMeta: ArrayParam(_spec.paramMeta),
      name: name,
      description: description,
    );
    final getLens = (IN target) => _spec.get(name, target);
    return Lens(meta, (target) {
      final results = getLens(target);
      if (results.isEmpty) {
        throw LensFailure.single(Missing(meta), target: target);
      }
      return results;
    });
  }
}
