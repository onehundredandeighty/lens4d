import '../lib/lens4d.dart';

/// example lens.
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
  // Example URI with query parameters
  final searchUri = Uri.parse(
    'https://api.example.com/search?q=dart&limit=10&page=1&debug=true',
  );
  print('Original URI: $searchUri');

  // Extract query parameters
  print('=== Extracting Query Parameters ===');

  // Basic string extraction
  final queryLens = Query.required('q');
  final searchTerm = queryLens(searchUri);
  print('Search term: $searchTerm');

  // Type conversions
  final limitLens = Query.integer().required('limit');
  final limit = limitLens(searchUri);
  print('Limit: $limit (type: ${limit.runtimeType})');

  final pageLens = Query.integer().optional('page');
  final page = pageLens(searchUri);
  print('Page: $page (type: ${page.runtimeType})');

  final debugLens = Query.boolean().required('debug');
  final debug = debugLens(searchUri);
  print('Debug: $debug (type: ${debug.runtimeType})');

  // Optional parameter (missing)
  final sortLens = Query.optional('sort');
  final sort = sortLens(searchUri);
  print('Sort: $sort');

  // Default value for missing parameter
  final orderLens = Query.defaulted('order', 'asc');
  final order = orderLens(searchUri);
  print('Order: $order');

  // Inject/modify query parameters
  print('=== Modifying Query Parameters ===');

  // Change search term
  final newSearchUri = Query.required('q').inject('flutter', searchUri);
  print('New search term: $newSearchUri');

  // Change limit
  final newLimitUri = Query.integer().required('limit').inject(20, searchUri);
  print('New limit: $newLimitUri');

  // Add new parameter
  final newCategoryUri = Query.required('category').inject('mobile', searchUri);
  print('Added category: $newCategoryUri');

  // Remove parameter
  final noDebugUri = Query.optional('debug').inject(null, searchUri);
  print('Removed debug: $noDebugUri');

  // Chaining operations
  print('=== Chaining Operations ===');
  final baseUri = Uri.parse('https://api.example.com/items');

  // Using inject() for step-by-step modifications
  final stepByStep = Query.required(
    'search',
  ).inject('dart programming', baseUri);
  print('Step-by-step: $stepByStep');

  // Using having() for single modification
  final singleModified = baseUri.having(Query.required('search').of('flutter'));
  print('Single modification: $singleModified');

  // Using havingAll() for multiple modifications
  final multipleModified = baseUri.havingAll([
    Query.required('search').of('dart programming'),
    Query.integer().required('limit').of(50),
    Query.required('sort').of('popularity'),
    Query.boolean().required('includeDetails').of(true),
  ]);
  print('Multiple modifications: $multipleModified');

  // Error handling
  print('=== Error Handling ===');
  final emptyUri = Uri.parse('https://api.example.com/search');

  try {
    final missingRequired = Query.required('missing')(emptyUri);
    print('This should not print: $missingRequired');
  } on LensFailure catch (e) {
    print(
      'Caught expected error for missing required parameter: ${e.failures.first}',
    );
  }

  // Optional returns null for missing
  final missingOptional = Query.optional('missing')(emptyUri);
  print('Missing optional parameter: $missingOptional');

  // Default provides fallback
  final missingWithDefault = Query.defaulted('missing', 'default-value')(
    emptyUri,
  );
  print('Missing with default: $missingWithDefault');
}
