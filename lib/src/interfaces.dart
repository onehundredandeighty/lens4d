/// Lens operation to extract a value from a target.
///
/// This provides the uni-directional extraction of an entity from a target.
/// Throws [LensFailure] if the value could not be retrieved from the target (missing/invalid etc).
abstract interface class LensExtractor<IN, OUT> {
  /// Lens operation to get the value from the target.
  ///
  /// Throws [LensFailure] if the value could not be retrieved from the target (missing/invalid etc).
  OUT call(IN target);

  /// Lens operation to get the value from the target. Synonym for call(IN).
  ///
  /// Throws [LensFailure] if the value could not be retrieved from the target (missing/invalid etc).
  OUT extract(IN target) => call(target);
}

/// Lens operation to inject a value into a target.
///
/// This provides the ability to set a value into the target and return a modified target.
abstract interface class LensInjector<IN, OUT> {
  /// Lens operation to set the value into the target.
  ///
  /// Returns a modified target of the same type with the value injected.
  R inject<R extends OUT>(IN value, R target);

  /// Bind this Lens to a value, so we can set it into a target.
  ///
  /// Returns a function that takes a target and returns the target with the bound value injected.
  R Function(R) of<R extends OUT>(IN value) => (it) => inject(value, it);
}

/// A combination of both extraction and injection capabilities.
///
/// This interface represents a bidirectional lens that can both extract values from
/// and inject values into a target.
abstract interface class LensInjectorExtractor<IN, OUT>
    implements LensExtractor<IN, OUT>, LensInjector<OUT, IN> {}
