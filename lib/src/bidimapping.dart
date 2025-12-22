/// A BiDiMapping defines a reusable bidirectional transformation between an input and output type.
/// 
/// This allows for converting values in both directions: from IN to OUT and from OUT to IN.
/// This is particularly useful for lenses that need to both extract and inject values
/// with type conversion.
class BiDiMapping<IN, OUT> {
  /// The runtime type of the output type.
  final Type outType;
  
  /// Function to convert from input type to output type.
  final OUT Function(IN) asOut;
  
  /// Function to convert from output type back to input type.
  final IN Function(OUT) asIn;

  /// Create a new BiDiMapping with the specified type and conversion functions.
  const BiDiMapping(this.outType, this.asOut, this.asIn);

  /// Create a new BiDiMapping by composing this mapping with additional transformations.
  /// 
  /// This allows chaining transformations: IN -> OUT -> NEXT and NEXT -> OUT -> IN
  BiDiMapping<IN, NEXT> map<NEXT>(
    NEXT Function(OUT) nextOut,
    OUT Function(NEXT) nextIn,
  ) => BiDiMapping<IN, NEXT>(
    NEXT,
    (IN input) => nextOut(asOut(input)),
    (NEXT next) => asIn(nextIn(next)),
  );

  /// Convert from output type back to input type.
  IN fromOut(OUT out) => asIn(out);

  /// Convert from input type to output type.
  OUT fromIn(IN input) => asOut(input);

  /// Convert from input type to output type (synonym for fromIn).
  OUT call(IN input) => asOut(input);
}