// Sentry error reporter implementation for the Flutter Error Boundary package.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error_reporter.dart';
import '../error_types.dart';

/// Sentry error reporter that sends errors to Sentry's error tracking service.
class SentryErrorReporter implements ErrorReporter {
  /// Creates a new Sentry error reporter.
  SentryErrorReporter({
    required this.dsn,
    required this.projectId,
    this.environment = 'production',
    this.release,
    this.serverName,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// The Sentry DSN (Data Source Name) for your project.
  final String dsn;

  /// The Sentry project ID.
  final String projectId;

  /// The environment name (e.g., 'production', 'staging', 'development').
  final String environment;

  /// The release version of your application.
  final String? release;

  /// The server name where the error occurred.
  final String? serverName;

  /// HTTP client for making requests to Sentry.
  final http.Client _httpClient;

  /// User identifier for error reporting.
  String? _userId;

  /// User properties for error reporting.
  Map<String, dynamic> _userProperties = {};

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    await _sendToSentry(errorInfo, {});
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    await _sendToSentry(errorInfo, context);
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

  /// Sends an error report to Sentry.
  Future<void> _sendToSentry(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    try {
      final url = _buildSentryUrl();
      final headers = _buildHeaders();
      final body = _buildEventPayload(errorInfo, context);

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        print(
            'Sentry error reporting failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Failed to send error to Sentry: $e');
    }
  }

  /// Builds the Sentry API URL.
  String _buildSentryUrl() {
    final uri = Uri.parse(dsn);
    return '${uri.scheme}://${uri.host}/api/${projectId}/store/';
  }

  /// Builds the request headers for Sentry.
  Map<String, String> _buildHeaders() {
    final uri = Uri.parse(dsn);

    return {
      'Content-Type': 'application/json',
      'X-Sentry-Auth': 'Sentry sentry_version=7,sentry_key=${uri.userInfo}',
      'User-Agent': 'flutter_error_boundary/1.0.0',
    };
  }

  /// Builds the event payload for Sentry.
  String _buildEventPayload(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) {
    final event = {
      'event_id': _generateEventId(),
      'timestamp': errorInfo.timestamp?.toUtc().toIso8601String(),
      'level': _mapSeverityToSentryLevel(errorInfo.severity),
      'logger': 'flutter_error_boundary',
      'platform': 'dart',
      'server_name': serverName,
      'release': release,
      'environment': environment,
      'exception': {
        'values': [
          {
            'type': errorInfo.error.runtimeType.toString(),
            'value': errorInfo.error.toString(),
            'stacktrace': {
              'frames': _parseStackTrace(errorInfo.stackTrace),
            },
          },
        ],
      },
      'tags': {
        'error_type': errorInfo.type.name,
        'error_source': errorInfo.errorSource ?? 'unknown',
      },
      'extra': {
        'context': context,
        'error_context': errorInfo.context,
        'user_data': errorInfo.userData,
      },
    };

    if (_userId != null) {
      event['user'] = {
        'id': _userId,
        ..._userProperties,
      };
    }

    return json.encode(event);
  }

  /// Generates a unique event ID.
  String _generateEventId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (DateTime.now().microsecond / 1000).round()).toString();
  }

  /// Maps error severity to Sentry level.
  String _mapSeverityToSentryLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return 'info';
      case ErrorSeverity.medium:
        return 'warning';
      case ErrorSeverity.high:
        return 'error';
      case ErrorSeverity.critical:
        return 'fatal';
    }
  }

  /// Parses stack trace into Sentry format.
  List<Map<String, dynamic>> _parseStackTrace(StackTrace stackTrace) {
    final frames = <Map<String, dynamic>>[];
    final lines = stackTrace.toString().split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      // Simple parsing - in a real implementation, you might want more sophisticated parsing
      frames.add({
        'filename': 'unknown',
        'function': line.trim(),
        'lineno': 0,
      });
    }

    return frames.reversed.toList(); // Sentry expects frames in reverse order
  }

  /// Disposes the HTTP client.
  void dispose() {
    _httpClient.close();
  }
}
