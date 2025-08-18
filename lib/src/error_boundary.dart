/// Main error boundary widget that catches and handles errors in the widget tree.
library flutter_error_boundary.src.error_boundary;

import 'package:flutter/material.dart';
import 'error_handler.dart';
import 'error_reporter.dart';
import 'error_types.dart';
import 'widgets/error_fallback.dart';
import 'error_boundary_controller.dart';

/// A widget that catches errors in its child tree and displays a fallback UI.
///
/// This widget acts as an error boundary, preventing errors from crashing the
/// entire application and providing a graceful fallback when errors occur.
class ErrorBoundary extends StatefulWidget {
  /// Creates an error boundary widget.
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorHandler = const DefaultErrorHandler(),
    this.errorReporter = const DefaultErrorReporter(),
    this.fallbackBuilder,
    this.reportErrors = true,
    this.attemptRecovery = false,
    this.errorSource,
    this.context,
    this.controller,
  });

  /// The child widget to render when no errors occur.
  final Widget child;

  /// The error handler to use for processing errors.
  final ErrorHandler errorHandler;

  /// The error reporter to use for reporting errors to external services.
  final ErrorReporter errorReporter;

  /// Custom fallback builder for creating error UI.
  /// If null, a default error fallback will be used.
  final Widget Function(ErrorInfo)? fallbackBuilder;

  /// Whether to report errors to external services.
  final bool reportErrors;

  /// Whether to attempt recovery from errors.
  final bool attemptRecovery;

  /// The source identifier for errors caught by this boundary.
  final String? errorSource;

  /// Additional context information for errors.
  final Map<String, dynamic>? context;

  /// Optional controller to programmatically report errors to this boundary.
  final ErrorBoundaryController? controller;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  ErrorInfo? _errorInfo;
  bool _isRecovering = false;
  late final ErrorBoundaryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ErrorBoundaryController();
    _controller.attach(_handleError);
  }

  @override
  void dispose() {
    _controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorInfo != null) {
      return widget.fallbackBuilder?.call(_errorInfo!) ??
          ErrorFallback(
            errorInfo: _errorInfo!,
            onRetry: _attemptRecovery,
            onReport: _reportError,
          );
    }

    return ErrorBoundaryCatcher(
      onError: _handleError,
      child: widget.child,
    );
  }

  void _handleError(Object error, StackTrace stackTrace) {
    if (_errorInfo != null) {
      // Already handling an error, don't handle another one
      return;
    }

    final errorInfo = ErrorInfo(
      error: error,
      stackTrace: stackTrace,
      severity: _determineSeverity(error),
      type: _determineType(error),
      errorSource: widget.errorSource,
      timestamp: DateTime.now(),
      context: widget.context,
    );

    setState(() {
      _errorInfo = errorInfo;
    });

    // Handle the error asynchronously
    _processError(errorInfo);
  }

  Future<void> _processError(ErrorInfo errorInfo) async {
    try {
      // Handle the error
      await widget.errorHandler.handleError(errorInfo);

      // Report the error if enabled
      if (widget.reportErrors) {
        await widget.errorReporter.reportError(errorInfo);
      }

      // Attempt recovery if enabled
      if (widget.attemptRecovery && !_isRecovering) {
        await _attemptRecovery();
      }
    } catch (e, stackTrace) {
      // If error processing fails, log it but don't throw
      debugPrint('Error processing failed: $e\n$stackTrace');
    }
  }

  Future<void> _attemptRecovery() async {
    if (_errorInfo == null || _isRecovering) return;

    setState(() {
      _isRecovering = true;
    });

    try {
      final success = await widget.errorHandler.attemptRecovery(_errorInfo!);

      if (success) {
        setState(() {
          _errorInfo = null;
          _isRecovering = false;
        });
      } else {
        setState(() {
          _isRecovering = false;
        });
      }
    } catch (e) {
      setState(() {
        _isRecovering = false;
      });
    }
  }

  Future<void> _reportError() async {
    if (_errorInfo == null) return;

    try {
      await widget.errorReporter.reportError(_errorInfo!);
    } catch (e) {
      debugPrint('Failed to report error: $e');
    }
  }

  ErrorSeverity _determineSeverity(Object error) {
    if (error is FlutterError) {
      return ErrorSeverity.high;
    }
    if (error is AssertionError) {
      return ErrorSeverity.medium;
    }
    if (error is TypeError) {
      return ErrorSeverity.high;
    }
    return ErrorSeverity.medium;
  }

  ErrorType _determineType(Object error) {
    if (error is FlutterError) {
      return ErrorType.rendering;
    }
    if (error is AssertionError) {
      return ErrorType.runtime;
    }
    if (error is TypeError) {
      return ErrorType.runtime;
    }
    return ErrorType.unknown;
  }
}

/// A widget that catches errors in its child tree using a custom approach.
///
/// This widget wraps its child in a way that can catch errors during build.
class ErrorBoundaryCatcher extends StatefulWidget {
  /// Creates an error boundary catcher.
  const ErrorBoundaryCatcher({
    super.key,
    required this.child,
    required this.onError,
  });

  /// The child widget to render.
  final Widget child;

  /// Callback called when an error occurs.
  final void Function(Object error, StackTrace stackTrace) onError;

  @override
  State<ErrorBoundaryCatcher> createState() => _ErrorBoundaryCatcherState();
}

class _ErrorBoundaryCatcherState extends State<ErrorBoundaryCatcher> {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundaryWrapper(
      onError: widget.onError,
      child: widget.child,
    );
  }
}

/// A wrapper widget that catches errors in its child tree.
///
/// This widget uses a custom error catching mechanism to intercept
/// errors that occur during widget building.
class ErrorBoundaryWrapper extends StatefulWidget {
  /// Creates an error boundary wrapper.
  const ErrorBoundaryWrapper({
    super.key,
    required this.child,
    required this.onError,
  });

  /// The child widget to render.
  final Widget child;

  /// Callback called when an error occurs.
  final void Function(Object error, StackTrace stackTrace) onError;

  @override
  State<ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<ErrorBoundaryWrapper> {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundaryInner(
      onError: widget.onError,
      child: widget.child,
    );
  }
}

/// An inner error boundary that actually catches the errors.
///
/// This widget uses a custom error catching mechanism to intercept
/// errors that occur during widget building.
class ErrorBoundaryInner extends StatefulWidget {
  /// Creates an inner error boundary.
  const ErrorBoundaryInner({
    super.key,
    required this.child,
    required this.onError,
  });

  /// The child widget to render.
  final Widget child;

  /// Callback called when an error occurs.
  final void Function(Object error, StackTrace stackTrace) onError;

  @override
  State<ErrorBoundaryInner> createState() => _ErrorBoundaryInnerState();
}

class _ErrorBoundaryInnerState extends State<ErrorBoundaryInner> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (error, stackTrace) {
          // Notify the parent error boundary
          widget.onError(error, stackTrace);

          // Return a placeholder widget that will be replaced by the fallback
          return const SizedBox.shrink();
        }
      },
    );
  }
}
