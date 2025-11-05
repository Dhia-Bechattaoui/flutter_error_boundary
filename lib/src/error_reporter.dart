// Error reporting interface and implementations for the Flutter Error Boundary package.

import 'error_types.dart';

/// Interface for reporting errors to external services.
abstract class ErrorReporter {
  /// Creates a new error reporter.
  const ErrorReporter();

  /// Reports an error to external services.
  Future<void> reportError(ErrorInfo errorInfo);

  /// Reports an error with additional context.
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  );

  /// Sets user identification for error reporting.
  void setUserIdentifier(String userId);

  /// Sets additional user properties for error reporting.
  void setUserProperties(Map<String, dynamic> properties);

  /// Clears user identification and properties.
  void clearUserData();
}

/// No-op implementation of the error reporter for testing or when reporting is disabled.
class NoOpErrorReporter implements ErrorReporter {
  const NoOpErrorReporter();

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    // Do nothing
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    // Do nothing
  }

  @override
  void setUserIdentifier(String userId) {
    // Do nothing
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    // Do nothing
  }

  @override
  void clearUserData() {
    // Do nothing
  }
}
