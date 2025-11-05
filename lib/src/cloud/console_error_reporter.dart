// Console error reporter implementation for the Flutter Error Boundary package.

import 'dart:developer' as developer;

import '../error_reporter.dart';
import '../error_types.dart';

/// Console-based error reporter that logs errors to the console.
///
/// This reporter is useful for development environments where you want
/// to see errors in the console/logs without sending them to external services.
class ConsoleErrorReporter implements ErrorReporter {
  /// Creates a new console error reporter.
  const ConsoleErrorReporter();

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    developer.log(
      'Error reported: ${errorInfo.error}',
      name: 'ErrorBoundary',
      error: errorInfo.error,
      stackTrace: errorInfo.stackTrace,
    );
    developer.log(
      '📊 Error Report:\n  Type: ${errorInfo.type.name}\n  Severity: ${errorInfo.severity.name}\n  Source: ${errorInfo.errorSource ?? "Unknown"}\n  Context: ${errorInfo.context}',
      name: 'ErrorReporter',
    );
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    final Map<String, dynamic> combinedContext = <String, dynamic>{
      ...?errorInfo.context,
      ...context,
    };
    developer.log(
      'Error reported with context: ${errorInfo.error}',
      name: 'ErrorBoundary',
      error: errorInfo.error,
      stackTrace: errorInfo.stackTrace,
    );
    developer.log(
      '📊 Error Report (with context):\n  Type: ${errorInfo.type.name}\n  Severity: ${errorInfo.severity.name}\n  Context: $combinedContext',
      name: 'ErrorReporter',
    );
  }

  @override
  void setUserIdentifier(String userId) {
    developer.log('👤 User ID set: $userId', name: 'ErrorReporter');
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    developer.log('👤 User properties set: $properties', name: 'ErrorReporter');
  }

  @override
  void clearUserData() {
    developer.log('👤 User data cleared', name: 'ErrorReporter');
  }
}

