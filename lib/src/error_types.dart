// Core error types and interfaces for the Flutter Error Boundary package.

/// Represents an error that occurred within an error boundary.
class BoundaryError {
  /// Creates a new boundary error.
  const BoundaryError({
    required this.error,
    required this.stackTrace,
    this.errorSource,
    this.timestamp,
  });

  /// The actual error that occurred.
  final Object error;

  /// The stack trace associated with the error.
  final StackTrace stackTrace;

  /// Optional source identifier for the error.
  final String? errorSource;

  /// When the error occurred.
  final DateTime? timestamp;

  @override
  String toString() =>
      'BoundaryError(error: $error, source: $errorSource, timestamp: $timestamp)';
}

/// Represents the severity level of an error.
enum ErrorSeverity {
  /// Low severity - non-critical errors that don't affect functionality.
  low,

  /// Medium severity - errors that may affect some functionality.
  medium,

  /// High severity - errors that significantly impact functionality.
  high,

  /// Critical severity - errors that cause complete failure.
  critical,
}

/// Represents the type of error that occurred.
enum ErrorType {
  /// Build-time errors in widget construction.
  build,

  /// Runtime errors during widget lifecycle.
  runtime,

  /// Rendering errors in the widget tree.
  rendering,

  /// State management errors.
  state,

  /// Network or external service errors.
  external,

  /// Unknown or unclassified errors.
  unknown,
}

/// Information about an error for reporting and handling.
class ErrorInfo {
  /// Creates new error information.
  const ErrorInfo({
    required this.error,
    required this.stackTrace,
    required this.severity,
    required this.type,
    this.errorSource,
    this.timestamp,
    this.context,
    this.userData,
  });

  /// The actual error that occurred.
  final Object error;

  /// The stack trace associated with the error.
  final StackTrace stackTrace;

  /// The severity level of the error.
  final ErrorSeverity severity;

  /// The type of error that occurred.
  final ErrorType type;

  /// Optional source identifier for the error.
  final String? errorSource;

  /// When the error occurred.
  final DateTime? timestamp;

  /// Additional context about the error.
  final Map<String, dynamic>? context;

  /// User-provided data associated with the error.
  final Map<String, dynamic>? userData;

  @override
  String toString() =>
      'ErrorInfo(error: $error, severity: $severity, type: $type, source: $errorSource)';
}
