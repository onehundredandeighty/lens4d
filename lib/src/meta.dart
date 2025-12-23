/// Base class for parameter metadata that describes the expected type and format of lens values.
sealed class ParamMeta {
  /// A human-readable description of the parameter type.
  final String description;

  const ParamMeta(this.description);
}

/// Metadata for string parameters.
class StringParam extends ParamMeta {
  const StringParam() : super('string');
}

/// Metadata for object parameters.
class ObjectParam extends ParamMeta {
  const ObjectParam() : super('object');
}

/// Metadata for boolean parameters.
class BooleanParam extends ParamMeta {
  const BooleanParam() : super('boolean');
}

/// Metadata for integer parameters.
class IntegerParam extends ParamMeta {
  const IntegerParam() : super('integer');
}

/// Metadata for file parameters.
class FileParam extends ParamMeta {
  const FileParam() : super('file');
}

/// Metadata for numeric parameters (including decimals).
class NumberParam extends ParamMeta {
  const NumberParam() : super('number');
}

/// Metadata for null parameters.
class NullParam extends ParamMeta {
  const NullParam() : super('null');
}

/// Metadata for array parameters, including the type of items in the array.
class ArrayParam extends ParamMeta {
  /// The metadata for individual items in the array.
  final ParamMeta itemType;

  const ArrayParam(this.itemType) : super('array');

  /// Returns the metadata for the item type.
  ParamMeta getItemType() => itemType;
}

/// Metadata for enum parameters.
class EnumParam<T extends Enum> extends ParamMeta {
  /// The runtime type of the enum.
  final Type enumType;

  const EnumParam(this.enumType) : super('string');
}

/// Metadata that describes a lens, including its name, location, type information,
/// and whether it's required.
///
/// This corresponds to the Kotlin Meta data class but without the metadata map
/// that was removed from the Dart implementation.
class Meta {
  /// Whether this lens represents a required field.
  final bool required;

  /// The location where this lens operates (e.g., 'header', 'query', 'body').
  final String location;

  /// Metadata describing the expected parameter type.
  final ParamMeta paramMeta;

  /// The name of the parameter this lens extracts/injects.
  final String name;

  /// An optional human-readable description of this lens.
  final String? description;

  const Meta({
    required this.required,
    required this.location,
    required this.paramMeta,
    required this.name,
    this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Meta &&
        other.required == required &&
        other.location == location &&
        other.paramMeta == paramMeta &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode =>
      Object.hash(required, location, paramMeta, name, description);
}
