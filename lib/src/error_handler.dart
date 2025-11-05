// Error handling interface and implementations for the Flutter Error Boundary package.

import 'error_types.dart';

/// Interface for handling errors that occur within error boundaries.
abstract class ErrorHandler {
  /// Creates a new error handler.
  const ErrorHandler();

  /// Handles an error that occurred within an error boundary.
  ///
  /// Returns true if the error was handled successfully, false otherwise.
  Future<bool> handleError(ErrorInfo errorInfo);

  /// Determines if an error should be reported to external services.
  bool shouldReportError(ErrorInfo errorInfo);

  /// Determines if an error should trigger a recovery attempt.
  bool shouldAttemptRecovery(ErrorInfo errorInfo);

  /// Attempts to recover from an error.
  ///
  /// Returns true if recovery was successful, false otherwise.
  Future<bool> attemptRecovery(ErrorInfo errorInfo);
}

/// Default implementation of the error handler.
class DefaultErrorHandler implements ErrorHandler {
  /// Creates a new default error handler.
  const DefaultErrorHandler({
    this.reportAllErrors = false,
    this.attemptRecoveryForAll = false,
    this.maxRecoveryAttempts = 3,
  });

  /// Whether to report all errors to external services.
  final bool reportAllErrors;

  /// Whether to attempt recovery for all errors.
  final bool attemptRecoveryForAll;

  /// Maximum number of recovery attempts for the same error.
  final int maxRecoveryAttempts;

  @override
  Future<bool> handleError(ErrorInfo errorInfo) async {
    try {
      // Determine if we should attempt recovery
      if (shouldAttemptRecovery(errorInfo)) {
        return await attemptRecovery(errorInfo);
      }

      return true;
    } on Object {
      return false;
    }
  }

  @override
  bool shouldReportError(ErrorInfo errorInfo) {
    if (reportAllErrors) {
      return true;
    }

    // Report high and critical severity errors
    return errorInfo.severity == ErrorSeverity.high ||
        errorInfo.severity == ErrorSeverity.critical;
  }

  @override
  bool shouldAttemptRecovery(ErrorInfo errorInfo) {
    if (attemptRecoveryForAll) {
      return true;
    }

    // Attempt recovery for non-critical errors
    return errorInfo.severity != ErrorSeverity.critical;
  }

  @override
  Future<bool> attemptRecovery(ErrorInfo errorInfo) async =>
      // For now, we'll consider recovery successful for non-critical errors
      errorInfo.severity != ErrorSeverity.critical;
}
