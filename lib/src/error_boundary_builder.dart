// Builder class for creating error boundaries with custom configurations.

import 'package:flutter/material.dart';
import 'error_boundary.dart';
import 'error_handler.dart';
import 'error_reporter.dart';
import 'error_types.dart';
import 'widgets/error_fallback.dart';

/// Builder class for creating error boundaries with custom configurations.
///
/// This class provides convenient methods for creating error boundaries
/// with different configurations, from simple error catching to full-featured
/// error handling with reporting and recovery.
///
/// Example:
/// ```dart
/// ErrorBoundaryBuilder().wrap(
///   child: MyWidget(),
///   errorHandler: CustomErrorHandler(),
/// )
/// ```
class ErrorBoundaryBuilder {
  /// Creates a new error boundary builder.
  const ErrorBoundaryBuilder();

  /// Creates an error boundary that wraps the given child widget.
  ErrorBoundary wrap({
    required Widget child,
    ErrorHandler? errorHandler,
    ErrorReporter? errorReporter,
    Widget Function(ErrorInfo)? fallbackBuilder,
    bool reportErrors = true,
    bool attemptRecovery = true,
    String? errorSource,
    Map<String, dynamic>? context,
  }) => ErrorBoundary(
    errorHandler: errorHandler ?? const DefaultErrorHandler(),
    fallbackBuilder: fallbackBuilder ?? _defaultFallbackBuilder,
    reportErrors: reportErrors,
    attemptRecovery: attemptRecovery,
    errorSource: errorSource,
    context: context,
    child: child,
  );

  /// Creates an error boundary with a custom error handler.
  ErrorBoundary withHandler({
    required Widget child,
    required ErrorHandler errorHandler,
    Widget Function(ErrorInfo)? fallbackBuilder,
    bool reportErrors = true,
    bool attemptRecovery = true,
    String? errorSource,
    Map<String, dynamic>? context,
  }) => ErrorBoundary(
    errorHandler: errorHandler,
    fallbackBuilder: fallbackBuilder ?? _defaultFallbackBuilder,
    reportErrors: reportErrors,
    attemptRecovery: attemptRecovery,
    errorSource: errorSource,
    context: context,
    child: child,
  );

  /// Creates an error boundary with a custom error reporter.
  ErrorBoundary withReporter({
    required Widget child,
    required ErrorReporter errorReporter,
    Widget Function(ErrorInfo)? fallbackBuilder,
    bool reportErrors = true,
    bool attemptRecovery = true,
    String? errorSource,
    Map<String, dynamic>? context,
  }) => ErrorBoundary(
    fallbackBuilder: fallbackBuilder ?? _defaultFallbackBuilder,
    reportErrors: reportErrors,
    attemptRecovery: attemptRecovery,
    errorSource: errorSource,
    context: context,
    child: child,
  );

  /// Creates an error boundary with a custom fallback builder.
  ErrorBoundary withFallback({
    required Widget child,
    required Widget Function(ErrorInfo) fallbackBuilder,
    ErrorHandler? errorHandler,
    ErrorReporter? errorReporter,
    bool reportErrors = true,
    bool attemptRecovery = true,
    String? errorSource,
    Map<String, dynamic>? context,
  }) => ErrorBoundary(
    errorHandler: errorHandler ?? const DefaultErrorHandler(),
    fallbackBuilder: fallbackBuilder,
    reportErrors: reportErrors,
    attemptRecovery: attemptRecovery,
    errorSource: errorSource,
    context: context,
    child: child,
  );

  /// Creates an error boundary with minimal configuration.
  ErrorBoundary simple({
    required Widget child,
    Widget Function(ErrorInfo)? fallbackBuilder,
  }) => ErrorBoundary(
    fallbackBuilder: fallbackBuilder ?? _defaultFallbackBuilder,
    reportErrors: false,
    child: child,
  );

  /// Creates an error boundary with full error handling and reporting.
  ErrorBoundary full({
    required Widget child,
    Widget Function(ErrorInfo)? fallbackBuilder,
    String? errorSource,
    Map<String, dynamic>? context,
  }) => ErrorBoundary(
    errorHandler: const DefaultErrorHandler(
      reportAllErrors: true,
      attemptRecoveryForAll: true,
    ),
    fallbackBuilder: fallbackBuilder ?? _defaultFallbackBuilder,
    attemptRecovery: true,
    errorSource: errorSource,
    context: context,
    child: child,
  );

  /// Default fallback builder that creates a simple error display.
  Widget _defaultFallbackBuilder(ErrorInfo errorInfo) =>
      ErrorFallback(errorInfo: errorInfo);
}

/// Extension methods for easier error boundary creation.
extension ErrorBoundaryExtension on Widget {
  /// Wraps this widget with an error boundary.
  ErrorBoundary withErrorBoundary({
    ErrorHandler? errorHandler,
    ErrorReporter? errorReporter,
    Widget Function(ErrorInfo)? fallbackBuilder,
    bool reportErrors = true,
    bool attemptRecovery = true,
    String? errorSource,
    Map<String, dynamic>? context,
  }) => const ErrorBoundaryBuilder().wrap(
    child: this,
    errorHandler: errorHandler,
    errorReporter: errorReporter,
    fallbackBuilder: fallbackBuilder,
    reportErrors: reportErrors,
    attemptRecovery: attemptRecovery,
    errorSource: errorSource,
    context: context,
  );

  /// Wraps this widget with a simple error boundary.
  ErrorBoundary withSimpleErrorBoundary({
    Widget Function(ErrorInfo)? fallbackBuilder,
  }) => const ErrorBoundaryBuilder().simple(
    child: this,
    fallbackBuilder: fallbackBuilder,
  );

  /// Wraps this widget with a full-featured error boundary.
  ErrorBoundary withFullErrorBoundary({
    Widget Function(ErrorInfo)? fallbackBuilder,
    String? errorSource,
    Map<String, dynamic>? context,
  }) => const ErrorBoundaryBuilder().full(
    child: this,
    fallbackBuilder: fallbackBuilder,
    errorSource: errorSource,
    context: context,
  );
}
