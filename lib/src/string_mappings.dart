import 'bidimapping.dart';

/// A set of standardized String <-> Type conversions which are used throughout lens4d.
/// 
/// These mappings provide safe, reusable conversions between string representations
/// and their corresponding Dart types, with proper error handling for invalid formats.
class StringBiDiMappings {
  /// Bidirectional mapping between String and int.
  static BiDiMapping<String, int> integer() =>
      BiDiMapping<String, int>(int, int.parse, (i) => i.toString());

  /// Bidirectional mapping between String and double.
  static BiDiMapping<String, double> float() =>
      BiDiMapping<String, double>(double, double.parse, (i) => i.toString());

  /// Bidirectional mapping between String and bool.
  /// 
  /// Accepts 'true'/'false' in any case and throws ArgumentError for other values.
  static BiDiMapping<String, bool> boolean() =>
      BiDiMapping<String, bool>(bool, _asSafeBoolean, (i) => i.toString());

  /// Bidirectional mapping for non-empty strings.
  /// 
  /// Throws ArgumentError if the string is empty during conversion.
  static BiDiMapping<String, String> nonEmpty() =>
      BiDiMapping<String, String>(String, (s) {
        if (s.isEmpty) throw ArgumentError('String cannot be empty');
        return s;
      }, (s) => s);

  /// Bidirectional mapping for non-blank strings.
  /// 
  /// Throws ArgumentError if the string is blank (empty or only whitespace) during conversion.
  static BiDiMapping<String, String> nonBlank() =>
      BiDiMapping<String, String>(String, (s) {
        if (s.trim().isEmpty) throw ArgumentError('String cannot be blank');
        return s;
      }, (s) => s);

  /// Bidirectional mapping between String and RegExp.
  /// 
  /// Converts strings to RegExp objects and back to their pattern strings.
  static BiDiMapping<String, RegExp> regexObject() =>
      BiDiMapping<String, RegExp>(RegExp, (s) => RegExp(s), (r) => r.pattern);

  /// Bidirectional mapping between String and Uri.
  /// 
  /// Uses Uri.parse for string-to-Uri conversion and toString for Uri-to-string.
  static BiDiMapping<String, Uri> uri() =>
      BiDiMapping<String, Uri>(Uri, (s) => Uri.parse(s), (u) => u.toString());

  /// Bidirectional mapping between String and DateTime.
  /// 
  /// Uses DateTime.parse for string-to-DateTime conversion and toIso8601String 
  /// for DateTime-to-string conversion.
  static BiDiMapping<String, DateTime> dateTime() =>
      BiDiMapping<String, DateTime>(
        DateTime,
        (s) => DateTime.parse(s),
        (d) => d.toIso8601String(),
      );

  /// Bidirectional mapping between String and List<T> using CSV format.
  /// 
  /// Splits strings by the specified delimiter and converts each element using
  /// the provided element mapping. Empty strings produce empty lists.
  static BiDiMapping<String, List<T>> csv<T>(
    String delimiter,
    BiDiMapping<String, T> mapElement,
  ) => BiDiMapping<String, List<T>>(
    List<T>,
    (s) => s.isEmpty
        ? <T>[]
        : s.split(delimiter).map((e) => mapElement.asOut(e)).toList(),
    (list) => list.map((e) => mapElement.asIn(e)).join(delimiter),
  );

  /// Safe boolean parsing that accepts 'true'/'false' in any case.
  /// 
  /// Throws ArgumentError for any other values.
  static bool _asSafeBoolean(String s) {
    final upper = s.toUpperCase();
    if (upper == 'TRUE') return true;
    if (upper == 'FALSE') return false;
    throw ArgumentError('illegal boolean: $s');
  }
}