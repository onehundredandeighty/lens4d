import 'lens_failure.dart';
import 'interfaces.dart';
import 'meta.dart';

/// A Lens provides the uni-directional extraction of an entity from a target.
///
/// A lens represents a functional way to focus on a particular part of a data structure,
/// allowing you to extract values and handle failures in a consistent manner.
class Lens<IN extends Object, FINAL> implements LensExtractor<IN, FINAL> {
  /// The metadata describing this lens (name, location, type information, etc.)
  final Meta meta;
  final FINAL Function(IN) _lensGet;

  /// Create a new Lens with the given metadata and extraction function.
  Lens(this.meta, this._lensGet);

  @override
  FINAL call(IN target) {
    try {
      return _lensGet(target);
    } on LensFailure {
      rethrow;
    } catch (e) {
      throw LensFailure.single(
        Invalid(meta),
        cause: e is Exception ? e : Exception(e.toString()),
        target: target,
      );
    }
  }

  @override
  FINAL extract(IN target) => call(target);

  @override
  String toString() =>
      "${meta.required ? "Required" : "Optional"} ${meta.location} '${meta.name}'";

  /// Returns a list containing the metadata for this lens.
  List<Meta> get metaList => [meta];
}

/// Abstract builder interface for creating lens instances.
///
/// Provides factory methods for creating lenses with different requirement levels
/// (required, optional, defaulted) and behaviors.
abstract class LensBuilder<IN extends Object, OUT> {
  /// Create an optional lens that returns null when the target value is missing.
  Lens<IN, OUT?> optional(String name, {String? description});

  /// Create a required lens that throws a [LensFailure] when the target value is missing.
  Lens<IN, OUT> required(String name, {String? description});

  /// Create a lens that returns a default value when the target value is missing.
  Lens<IN, OUT> defaulted(String name, OUT defaultValue, {String? description});

  /// Create a lens that delegates to another lens when the target value is missing.
  Lens<IN, OUT> defaultedTo(
    String name,
    LensExtractor<IN, OUT> defaultLens, {
    String? description,
  });
}
