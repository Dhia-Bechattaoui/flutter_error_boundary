// Firebase Crashlytics error reporter implementation for the Flutter Error Boundary package.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error_reporter.dart';
import '../error_types.dart';

/// Firebase Crashlytics error reporter that sends errors to Firebase's crash reporting service.
class FirebaseCrashlyticsReporter implements ErrorReporter {
  /// Creates a new Firebase Crashlytics reporter.
  FirebaseCrashlyticsReporter({
    required this.projectId,
    required this.apiKey,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// The Firebase project ID.
  final String projectId;

  /// The Firebase API key.
  final String apiKey;

  /// HTTP client for making requests to Firebase.
  final http.Client _httpClient;

  /// User identifier for error reporting.
  String? _userId;

  /// User properties for error reporting.
  final Map<String, dynamic> _userProperties = <String, dynamic>{};

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    await _sendToFirebase(errorInfo, <String, dynamic>{});
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    await _sendToFirebase(errorInfo, context);
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

  /// Sends an error report to Firebase Crashlytics.
  Future<void> _sendToFirebase(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    try {
      final String url = _buildFirebaseUrl();
      final Map<String, String> headers = _buildHeaders();
      final String body = _buildEventPayload(errorInfo, context);

      final http.Response response = await _httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {}
    } on Object {
      // Silently ignore errors from Firebase API calls
    }
  }

  /// Builds the Firebase API URL.
  String _buildFirebaseUrl() =>
      'https://firebase.googleapis.com/v1/projects/$projectId/reports:create';

  /// Builds the request headers for Firebase.
  Map<String, String> _buildHeaders() => <String, String>{
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
    'User-Agent': 'flutter_error_boundary/1.0.0',
  };

  /// Builds the event payload for Firebase Crashlytics.
  String _buildEventPayload(ErrorInfo errorInfo, Map<String, dynamic> context) {
    final Map<String, Map<String, Object?>> event =
        <String, Map<String, Object?>>{
          'report': <String, Object?>{
            'eventTime': errorInfo.timestamp?.toUtc().toIso8601String(),
            'type': 'crash',
            'data': <String, Map<String, Object?>>{
              'crashReport': <String, Object?>{
                'exception': <String, String>{
                  'type': errorInfo.error.runtimeType.toString(),
                  'message': errorInfo.error.toString(),
                  'stackTrace': errorInfo.stackTrace.toString(),
                },
                'severity': _mapSeverityToFirebaseLevel(errorInfo.severity),
                'errorType': errorInfo.type.name,
                'errorSource': errorInfo.errorSource ?? 'unknown',
                'context': context,
                'errorContext': errorInfo.context,
                'userData': errorInfo.userData,
                'metadata': <String, Object?>{
                  'platform': 'flutter',
                  'package': 'flutter_error_boundary',
                  'timestamp': errorInfo.timestamp?.millisecondsSinceEpoch,
                },
              },
            },
          },
        };

    if (_userId != null) {
      (event['report']
              as Map<String, dynamic>)['data']['crashReport']['userId'] =
          _userId;
      if (_userProperties.isNotEmpty) {
        (event['report']
                as Map<
                  String,
                  dynamic
                >)['data']['crashReport']['userProperties'] =
            _userProperties;
      }
    }

    return json.encode(event);
  }

  /// Maps error severity to Firebase Crashlytics level.
  String _mapSeverityToFirebaseLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return 'INFO';
      case ErrorSeverity.medium:
        return 'WARNING';
      case ErrorSeverity.high:
        return 'ERROR';
      case ErrorSeverity.critical:
        return 'FATAL';
    }
  }

  /// Disposes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
