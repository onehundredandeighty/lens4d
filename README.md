# lens4d

A functional lens library for Dart, enabling type-safe, composable data access and modification.

## Overview

Lenses are a functional programming pattern that provide a clean, type-safe way to focus on, extract from, and modify deeply nested data structures. Originally from Haskell and popularized in languages like Scala and Kotlin, lenses solve the problem of working with immutable data in an elegant, composable way.

This library is inspired by and adapted from the lens system in [http4k](https://http4k.org) Kotlin library, bringing the power of functional lenses to Dart.

### Why Lenses?

Working with immutable data often leads to verbose, error-prone code:

```dart
// Without lenses - verbose and fragile
final newUri = uri.replace(
  queryParameters: {
    ...uri.queryParameters,
    'search': 'flutter',
    'limit': '20',
  }
);
```

With lenses, the same operation becomes clean and composable:

```dart
// With lenses - clean and type-safe
final newUri = uri.havingAll([
  Query.required('search').of('flutter'),
  Query.integer().required('limit').of(20),
]);
```

## Features

- ✅ **Type-safe data access** - Extract and modify values with compile-time type safety
- ✅ **Functional composition** - Chain operations with `having()` and `havingAll()`
- ✅ **Bidirectional lenses** - Both read from and write to data structures
- ✅ **Type conversions** - Built-in conversions for integers, booleans, dates, and more
- ✅ **Error handling** - Comprehensive failure handling with detailed error information
- ✅ **Zero dependencies** - Pure Dart implementation

## Quick Start

### Installation

Add lens4d to your `pubspec.yaml`:

```yaml
dependencies:
  lens4d: ^1.0.0
```

### Basic Usage

Here's a practical example working with URI query parameters:

```dart
import 'package:lens4d/lens4d.dart';

/// Define a Query lens for Uri objects
final Query = BiDiLensSpec<Uri, String>(
  'query',
  const StringParam(),
  LensGet<Uri, String>((name, uri) {
    final value = uri.queryParameters[name];
    return value != null ? [value] : [];
  }),
  LensSet<Uri, String>((name, values, uri) {
    final newParams = Map<String, String>.from(uri.queryParameters);
    if (values.isEmpty) {
      newParams.remove(name);
    } else {
      newParams[name] = values.first;
    }
    return uri.replace(queryParameters: newParams);
  }),
);

void main() {
  final uri = Uri.parse('https://api.example.com/search?q=dart&limit=10');
  
  // Extract values with type safety
  final searchTerm = Query.required('q')(uri);           // 'dart'
  final limit = Query.integer().required('limit')(uri);  // 10 (as int)
  final page = Query.integer().optional('page')(uri);    // null
  
  // Single modification
  final newUri = uri.having(Query.required('q').of('flutter'));
  
  // Multiple modifications
  final complexUri = uri.havingAll([
    Query.required('search').of('dart programming'),
    Query.integer().required('limit').of(50),
    Query.boolean().required('debug').of(true),
  ]);
  
  // Error handling
  try {
    Query.required('missing')(uri);
  } on LensFailure catch (e) {
    print('Parameter not found: ${e.failures.first}');
  }
}
```

### Type Conversions

Lenses support automatic type conversions:

```dart
// String conversions
Query.required('name')                    // String (default)
Query.string().required('name')           // String (explicit)
Query.nonEmptyString().required('title')  // Non-empty string

// Numeric conversions  
Query.integer().required('count')         // int
Query.decimal().required('price')         // double

// Other conversions
Query.boolean().required('enabled')       // bool
Query.dateTime().required('created')      // DateTime
Query.uri().required('callback')          // Uri
```

### Functional Composition

The `having()` and `havingAll()` extension methods enable clean functional composition:

```dart
// Chain single modifications
final result = data
  .having(someLens.of(value1))
  .having(anotherLens.of(value2));

// Apply multiple modifications at once
final result = data.havingAll([
  lens1.of(value1),
  lens2.of(value2), 
  lens3.of(value3),
]);
```

## API Overview

- **`BiDiLensSpec<IN, OUT>`** - Bidirectional lens specification for extraction and injection
- **`LensSpec<IN, OUT>`** - Unidirectional lens for extraction only
- **`BiDiLens<IN, OUT>`** - Concrete bidirectional lens instance
- **`Lens<IN, OUT>`** - Concrete unidirectional lens instance

### Core Methods

- `required(name)` - Extract required value, throw on missing
- `optional(name)` - Extract optional value, return null if missing  
- `defaulted(name, defaultValue)` - Extract with fallback value
- `inject(value, target)` - Inject value into target
- `of(value)` - Create injection function for use with `having()`

### Extension Methods

- `having(modifier)` - Apply single lens modifier
- `havingAll(modifiers)` - Apply multiple lens modifiers
- Type conversions: `integer()`, `boolean()`, `dateTime()`, etc.

## Contributing

Contributions are welcome! Please feel free to submit a PR.

## License

This project is licensed under the Apache2 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the [http4k](https://http4k.org) Kotlin library
- Based on functional programming patterns from Haskell and other FP languages
- Thanks to the Dart community for feedback and contributions
