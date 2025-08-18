/// Error reporting interface and implementations for the Flutter Error Boundary package.
library flutter_error_boundary.src.error_reporter;

import 'error_types.dart';

/// Interface for reporting errors to external services.
abstract class ErrorReporter {
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

/// Default implementation of the error reporter.
class DefaultErrorReporter implements ErrorReporter {
  /// Creates a new default error reporter.
  const DefaultErrorReporter({
    this.enabled = true,
    this.includeStackTrace = true,
    this.includeUserData = false,
  });

  /// Whether error reporting is enabled.
  final bool enabled;

  /// Whether to include stack traces in error reports.
  final bool includeStackTrace;

  /// Whether to include user data in error reports.
  final bool includeUserData;

  // Note: User data is managed externally since this class is const

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    if (!enabled) return;

    // In tests, avoid async timers that keep the binding pending
    _sendErrorReportSync(errorInfo, {});
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    if (!enabled) return;

    _sendErrorReportSync(errorInfo, context);
  }

  @override
  void setUserIdentifier(String userId) {
    // No-op for const reporter
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    // No-op for const reporter
  }

  @override
  void clearUserData() {
    // No-op for const reporter
  }

  void _sendErrorReportSync(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) {
    // Prepare the error report
    final report = _prepareErrorReport(errorInfo, context);

    // In a real implementation, this would send the report to external services
    // For now, we'll just log it
    print('Error Report: ${report.toString()}');
  }

  Map<String, dynamic> _prepareErrorReport(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) {
    final report = <String, dynamic>{
      'error': errorInfo.error.toString(),
      'severity': errorInfo.severity.name,
      'type': errorInfo.type.name,
      'timestamp': errorInfo.timestamp?.toIso8601String(),
      'source': errorInfo.errorSource,
    };

    if (includeStackTrace) {
      report['stackTrace'] = errorInfo.stackTrace.toString();
    }

    if (includeUserData) {
      // User data is not available in const reporter
      // Use NoOpErrorReporter for user data functionality
    }

    if (context.isNotEmpty) {
      report['context'] = context;
    }

    if (errorInfo.context != null) {
      report['errorContext'] = errorInfo.context;
    }

    if (errorInfo.userData != null) {
      report['userData'] = errorInfo.userData;
    }

    return report;
  }
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
