import 'interfaces.dart';
import 'lens.dart';
import 'meta.dart';

/// A BiDiLens provides the bi-directional extraction of an entity from a target,
/// or the insertion of an entity into a target.
///
/// This extends a regular [Lens] with injection capabilities, allowing both
/// reading from and writing to the focused part of a data structure.
class BiDiLens<IN extends Object, FINAL> extends Lens<IN, FINAL>
    implements LensInjectorExtractor<IN, FINAL> {
  final IN Function(FINAL, IN) _lensSet;

  /// Create a new BiDiLens with the given metadata, extraction function, and injection function.
  BiDiLens(Meta meta, FINAL Function(IN) get, this._lensSet) : super(meta, get);

  @override
  R inject<R extends IN>(FINAL value, R target) => _lensSet(value, target) as R;

  @override
  R Function(R) of<R extends IN>(FINAL value) => (it) => inject(value, it);
}

/// Abstract builder interface for creating bidirectional lens instances.
///
/// Extends [LensBuilder] to provide factory methods that create [BiDiLens] instances
/// instead of regular [Lens] instances, enabling both extraction and injection capabilities.
abstract class BiDiLensBuilder<IN extends Object, OUT>
    extends LensBuilder<IN, OUT> {
  @override
  BiDiLens<IN, OUT?> optional(String name, {String? description});

  @override
  BiDiLens<IN, OUT> required(String name, {String? description});

  @override
  BiDiLens<IN, OUT> defaulted(
    String name,
    OUT defaultValue, {
    String? description,
  });

  @override
  BiDiLens<IN, OUT> defaultedTo(
    String name,
    LensExtractor<IN, OUT> defaultLens, {
    String? description,
  });
}
