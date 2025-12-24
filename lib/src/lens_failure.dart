import 'meta.dart';

/// Types of lens operation failures.
enum FailureType { invalid, missing, unsupported }

/// Base class for all lens operation failures.
///
/// Each failure contains the type of failure and the metadata of the lens that failed.
sealed class LensFailureReason {
  final FailureType type;
  final Meta meta;

  const LensFailureReason(this.type, this.meta);

  @override
  String toString();
}

/// Represents a failure where a required value was missing from the target.
class Missing extends LensFailureReason {
  const Missing(Meta meta) : super(FailureType.missing, meta);

  @override
  String toString() => "${meta.location} '${meta.name}' is required";
}

/// Represents a failure where a value was present but could not be converted to the expected type.
class Invalid extends LensFailureReason {
  const Invalid(Meta meta) : super(FailureType.invalid, meta);

  @override
  String toString() =>
      "${meta.location} '${meta.name}' must be ${meta.paramMeta.description}";
}

/// Represents a failure where a value was present but is not acceptable for the lens operation.
class Unsupported extends LensFailureReason {
  const Unsupported(Meta meta) : super(FailureType.unsupported, meta);

  @override
  String toString() => "${meta.location} '${meta.name}' is not acceptable";
}

/// Exception thrown when lens operations fail.
///
/// Contains a list of individual failures, an optional cause exception,
/// the target object that was being processed, and a descriptive message.
class LensFailure implements Exception {
  /// The individual failures that caused this exception.
  final List<LensFailureReason> failures;

  /// The underlying exception that caused this failure, if any.
  final Exception? cause;

  /// The target object that was being processed when the failure occurred.
  final Object? target;

  /// A descriptive message about the failure.
  final String message;

  /// Create a LensFailure from a list of individual failures.
  LensFailure(this.failures, {this.cause, this.target, String? message})
    : message = message ?? failures.map((f) => f.toString()).join(', ');

  /// Create a LensFailure from a single failure.
  LensFailure.single(
    LensFailureReason failure, {
    Exception? cause,
    Object? target,
    String? message,
  }) : this([failure], cause: cause, target: target, message: message);

  /// Determine the overall failure type based on the contained failures.
  ///
  /// Priority order: Unsupported > Invalid > Missing
  FailureType overall() {
    final types = failures.map((f) => f.type).toList();
    if (types.contains(FailureType.unsupported)) return FailureType.unsupported;
    return types.isEmpty || types.contains(FailureType.invalid)
        ? FailureType.invalid
        : FailureType.missing;
  }

  @override
  String toString() => message;
}
