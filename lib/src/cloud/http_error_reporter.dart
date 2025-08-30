// Generic HTTP error reporter implementation for the Flutter Error Boundary package.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error_reporter.dart';
import '../error_types.dart';

/// Generic HTTP error reporter that sends errors to any HTTP endpoint.
class HttpErrorReporter implements ErrorReporter {
  /// Creates a new HTTP error reporter.
  HttpErrorReporter({
    required this.endpoint,
    this.method = 'POST',
    this.headers = const {},
    this.timeout = const Duration(seconds: 30),
    this.retryAttempts = 3,
    this.retryDelay = const Duration(seconds: 1),
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// The HTTP endpoint URL to send error reports to.
  final String endpoint;

  /// The HTTP method to use (GET, POST, PUT, etc.).
  final String method;

  /// Additional headers to include in the request.
  final Map<String, String> headers;

  /// Request timeout duration.
  final Duration timeout;

  /// Number of retry attempts if the request fails.
  final int retryAttempts;

  /// Delay between retry attempts.
  final Duration retryDelay;

  /// HTTP client for making requests.
  final http.Client _httpClient;

  /// User identifier for error reporting.
  String? _userId;

  /// User properties for error reporting.
  Map<String, dynamic> _userProperties = {};

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    await _sendHttpRequest(errorInfo, {});
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    await _sendHttpRequest(errorInfo, context);
  }

  @override
  void setUserIdentifier(String userId) {
    _userId = userId;
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    _userProperties.addAll(properties);
  }

  @override
  void clearUserData() {
    _userId = null;
    _userProperties.clear();
  }

  /// Sends an error report via HTTP request with retry logic.
  Future<void> _sendHttpRequest(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    int attempts = 0;

    while (attempts < retryAttempts) {
      try {
        final response = await _makeHttpRequest(errorInfo, context);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success
          return;
        } else {
          print(
              'HTTP error reporting failed: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        attempts++;
        if (attempts >= retryAttempts) {
          print(
              'Failed to send error via HTTP after $retryAttempts attempts: $e');
          return;
        }

        // Wait before retrying
        await Future.delayed(retryDelay);
      }
    }
  }

  /// Makes the actual HTTP request.
  Future<http.Response> _makeHttpRequest(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    final uri = Uri.parse(endpoint);
    final requestHeaders = _buildHeaders();
    final body = _buildRequestBody(errorInfo, context);

    switch (method.toUpperCase()) {
      case 'GET':
        final queryParams = _buildQueryParams(errorInfo, context);
        final getUri = uri.replace(queryParameters: queryParams);
        return await _httpClient
            .get(
              getUri,
              headers: requestHeaders,
            )
            .timeout(timeout);

      case 'POST':
        return await _httpClient
            .post(
              uri,
              headers: requestHeaders,
              body: body,
            )
            .timeout(timeout);

      case 'PUT':
        return await _httpClient
            .put(
              uri,
              headers: requestHeaders,
              body: body,
            )
            .timeout(timeout);

      case 'PATCH':
        return await _httpClient
            .patch(
              uri,
              headers: requestHeaders,
              body: body,
            )
            .timeout(timeout);

      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  /// Builds the request headers.
  Map<String, String> _buildHeaders() {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'User-Agent': 'flutter_error_boundary/1.0.0',
    };

    return {...defaultHeaders, ...headers};
  }

  /// Builds the request body for POST/PUT/PATCH requests.
  String _buildRequestBody(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) {
    final payload = {
      'error': {
        'type': errorInfo.error.runtimeType.toString(),
        'message': errorInfo.error.toString(),
        'stackTrace': errorInfo.stackTrace.toString(),
        'severity': errorInfo.severity.name,
        'errorType': errorInfo.type.name,
        'errorSource': errorInfo.errorSource,
        'timestamp': errorInfo.timestamp?.toIso8601String(),
      },
      'context': context,
      'errorContext': errorInfo.context,
      'userData': errorInfo.userData,
      'metadata': {
        'platform': 'flutter',
        'package': 'flutter_error_boundary',
        'version': '1.0.0',
      },
    };

    if (_userId != null) {
      payload['user'] = {
        'id': _userId,
        'properties': _userProperties,
      };
    }

    return json.encode(payload);
  }

  /// Builds query parameters for GET requests.
  Map<String, String> _buildQueryParams(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) {
    final params = <String, String>{
      'error_type': errorInfo.error.runtimeType.toString(),
      'error_message': errorInfo.error.toString(),
      'severity': errorInfo.severity.name,
      'error_type_category': errorInfo.type.name,
      'timestamp': errorInfo.timestamp?.millisecondsSinceEpoch.toString() ?? '',
    };

    if (_userId != null) {
      params['user_id'] = _userId!;
    }

    // Add context as query parameters (limited to simple string values)
    context.forEach((key, value) {
      if (value is String || value is num || value is bool) {
        params['ctx_$key'] = value.toString();
      }
    });

    return params;
  }

  /// Disposes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
