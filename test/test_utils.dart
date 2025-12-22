import '../lib/lens4d.dart';

class MockRequest {
  final Map<String, String> headers;
  final Map<String, List<String>> queryParams;
  final String body;

  const MockRequest({this.headers = const {}, this.queryParams = const {}, this.body = ''});

  MockRequest copyWith({Map<String, String>? headers, Map<String, List<String>>? queryParams, String? body}) {
    return MockRequest(
      headers: headers ?? this.headers,
      queryParams: queryParams ?? this.queryParams,
      body: body ?? this.body,
    );
  }
}

final Header = BiDiLensSpec<MockRequest, String>(
  'header',
  const StringParam(),
  LensGet<MockRequest, String>((name, request) {
    final value = request.headers[name];
    return value != null ? [value] : [];
  }),
  LensSet<MockRequest, String>((name, values, request) {
    final newHeaders = Map<String, String>.from(request.headers);
    if (values.isEmpty) {
      newHeaders.remove(name);
    } else {
      newHeaders[name] = values.first;
    }
    return request.copyWith(headers: newHeaders);
  }),
);

final Query = BiDiLensSpec<MockRequest, String>(
  'query',
  const StringParam(),
  LensGet<MockRequest, String>((name, request) => request.queryParams[name] ?? []),
  LensSet<MockRequest, String>((name, values, request) {
    final newQueryParams = Map<String, List<String>>.from(request.queryParams);
    if (values.isEmpty) {
      newQueryParams.remove(name);
    } else {
      newQueryParams[name] = values;
    }
    return request.copyWith(queryParams: newQueryParams);
  }),
);
