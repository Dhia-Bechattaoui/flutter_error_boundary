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
  Map<String, dynamic> _userProperties = {};

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    await _sendToFirebase(errorInfo, {});
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
      final url = _buildFirebaseUrl();
      final headers = _buildHeaders();
      final body = _buildEventPayload(errorInfo, context);

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        print(
            'Firebase Crashlytics error reporting failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Failed to send error to Firebase Crashlytics: $e');
    }
  }

  /// Builds the Firebase API URL.
  String _buildFirebaseUrl() {
    return 'https://firebase.googleapis.com/v1/projects/$projectId/reports:create';
  }

  /// Builds the request headers for Firebase.
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'User-Agent': 'flutter_error_boundary/1.0.0',
    };
  }

  /// Builds the event payload for Firebase Crashlytics.
  String _buildEventPayload(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) {
    final event = {
      'report': {
        'eventTime': errorInfo.timestamp?.toUtc().toIso8601String(),
        'type': 'crash',
        'data': {
          'crashReport': {
            'exception': {
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
            'metadata': {
              'platform': 'flutter',
              'package': 'flutter_error_boundary',
              'timestamp': errorInfo.timestamp?.millisecondsSinceEpoch,
            },
          },
        },
      },
    };

    if (_userId != null) {
      (event['report'] as Map<String, dynamic>)['data']['crashReport']
          ['userId'] = _userId;
      if (_userProperties.isNotEmpty) {
        (event['report'] as Map<String, dynamic>)['data']['crashReport']
            ['userProperties'] = _userProperties;
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
