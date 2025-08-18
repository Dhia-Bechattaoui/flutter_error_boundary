/// Error handling interface and implementations for the Flutter Error Boundary package.
library flutter_error_boundary.src.error_handler;

import 'error_types.dart';

/// Interface for handling errors that occur within error boundaries.
abstract class ErrorHandler {
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
      // Log the error
      _logError(errorInfo);

      // Determine if we should report the error
      if (shouldReportError(errorInfo)) {
        await _reportError(errorInfo);
      }

      // Determine if we should attempt recovery
      if (shouldAttemptRecovery(errorInfo)) {
        return await attemptRecovery(errorInfo);
      }

      return true;
    } catch (e, stackTrace) {
      // If error handling itself fails, log it but don't throw
      _logError(ErrorInfo(
        error: e,
        stackTrace: stackTrace,
        severity: ErrorSeverity.high,
        type: ErrorType.unknown,
        errorSource: 'ErrorHandler.handleError',
        timestamp: DateTime.now(),
      ));
      return false;
    }
  }

  @override
  bool shouldReportError(ErrorInfo errorInfo) {
    if (reportAllErrors) return true;

    // Report high and critical severity errors
    return errorInfo.severity == ErrorSeverity.high ||
        errorInfo.severity == ErrorSeverity.critical;
  }

  @override
  bool shouldAttemptRecovery(ErrorInfo errorInfo) {
    if (attemptRecoveryForAll) return true;

    // Attempt recovery for non-critical errors
    return errorInfo.severity != ErrorSeverity.critical;
  }

  @override
  Future<bool> attemptRecovery(ErrorInfo errorInfo) async {
    // For now, we'll consider recovery successful for non-critical errors
    return errorInfo.severity != ErrorSeverity.critical;
  }

  void _logError(ErrorInfo errorInfo) {
    // In a real implementation, this would use a proper logging framework
    // For now, we'll use print for demonstration
    print('Error Boundary Error: ${errorInfo.toString()}');
  }

  Future<void> _reportError(ErrorInfo errorInfo) async {
    // In a real implementation, this would send the error to external services
    // For now, we'll just log it
    print('Reporting error to external service: ${errorInfo.toString()}');
  }
}
