// Main error boundary widget that catches and handles errors in the widget tree.

import 'package:flutter/material.dart';

import 'error_boundary_controller.dart';
import 'error_handler.dart';
import 'error_types.dart';
import 'widgets/error_fallback.dart';

/// A widget that catches errors in its child tree and displays a fallback UI.
///
/// This widget acts as an error boundary, preventing errors from crashing the
/// entire application and providing a graceful fallback when errors occur.
class ErrorBoundary extends StatefulWidget {
  /// Creates an error boundary widget.
  const ErrorBoundary({
    required this.child,
    super.key,
    this.errorHandler = const DefaultErrorHandler(),
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
    debugPrint('ErrorBoundary: Controller attached in initState');
  }

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the controller changed, update the attachment
    if (oldWidget.controller != widget.controller) {
      _controller.detach();
      _controller = widget.controller ?? ErrorBoundaryController();
      _controller.attach(_handleError);
      debugPrint('ErrorBoundary: Controller updated in didUpdateWidget');
    }
  }

  @override
  void dispose() {
    _controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ErrorBoundary.build called, _errorInfo is: $_errorInfo');
    if (_errorInfo != null) {
      debugPrint('ErrorBoundary: Returning ErrorFallback widget');
      return widget.fallbackBuilder?.call(_errorInfo!) ??
          ErrorFallback(errorInfo: _errorInfo!, onRetry: _attemptRecovery);
    }

    debugPrint('ErrorBoundary: Returning ErrorBoundaryCatcher (no error)');
    return ErrorBoundaryCatcher(onError: _handleError, child: widget.child);
  }

  void _handleError(Object error, StackTrace stackTrace) {
    debugPrint('ErrorBoundary._handleError called: $error');

    if (_errorInfo != null) {
      // Already handling an error, don't handle another one
      debugPrint('ErrorBoundary: Already handling an error, ignoring new one');
      return;
    }

    final ErrorInfo errorInfo = ErrorInfo(
      error: error,
      stackTrace: stackTrace,
      severity: _determineSeverity(error),
      type: _determineType(error),
      errorSource: widget.errorSource,
      timestamp: DateTime.now(),
      context: widget.context,
    );

    debugPrint('ErrorBoundary: Setting error info and calling setState');
    // Use WidgetsBinding to ensure setState is called in the right frame
    if (mounted) {
      setState(() {
        _errorInfo = errorInfo;
      });
      debugPrint(
        'ErrorBoundary: setState called, _errorInfo is now: $_errorInfo',
      );
    } else {
      debugPrint('ErrorBoundary: Widget not mounted, cannot setState');
    }

    // Handle the error asynchronously
    _processError(errorInfo);
  }

  Future<void> _processError(ErrorInfo errorInfo) async {
    try {
      // Handle the error
      await widget.errorHandler.handleError(errorInfo);

      // Attempt recovery if enabled
      if (widget.attemptRecovery && !_isRecovering) {
        debugPrint('ErrorBoundary: Attempting recovery...');
        await _attemptRecovery();
        debugPrint('ErrorBoundary: Recovery attempt completed');
      }
    } on Object catch (e, stackTrace) {
      // If error processing fails, log it but don't throw
      debugPrint('Error processing failed: $e\n$stackTrace');
    }
  }

  Future<void> _attemptRecovery() async {
    debugPrint(
      'ErrorBoundary._attemptRecovery called, _errorInfo: $_errorInfo, _isRecovering: $_isRecovering',
    );
    if (_errorInfo == null || _isRecovering) {
      debugPrint(
        'ErrorBoundary._attemptRecovery: Skipping - no error or already recovering',
      );
      return;
    }

    setState(() {
      _isRecovering = true;
    });

    try {
      final bool success = await widget.errorHandler.attemptRecovery(
        _errorInfo!,
      );
      debugPrint('ErrorBoundary._attemptRecovery: Recovery result: $success');

      if (success) {
        debugPrint(
          'ErrorBoundary._attemptRecovery: Recovery successful, clearing error',
        );
        setState(() {
          _errorInfo = null;
          _isRecovering = false;
        });
      } else {
        debugPrint(
          'ErrorBoundary._attemptRecovery: Recovery failed, keeping error',
        );
        setState(() {
          _isRecovering = false;
        });
      }
    } on Object catch (e) {
      debugPrint(
        'ErrorBoundary._attemptRecovery: Exception during recovery: $e',
      );
      setState(() {
        _isRecovering = false;
      });
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
    required this.child,
    required this.onError,
    super.key,
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
  Widget build(BuildContext context) =>
      ErrorBoundaryWrapper(onError: widget.onError, child: widget.child);
}

/// A wrapper widget that catches errors in its child tree.
///
/// This widget uses a custom error catching mechanism to intercept
/// errors that occur during widget building.
class ErrorBoundaryWrapper extends StatefulWidget {
  /// Creates an error boundary wrapper.
  const ErrorBoundaryWrapper({
    required this.child,
    required this.onError,
    super.key,
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
  Widget build(BuildContext context) =>
      ErrorBoundaryInner(onError: widget.onError, child: widget.child);
}

/// An inner error boundary that actually catches the errors.
///
/// This widget uses a custom error catching mechanism to intercept
/// errors that occur during widget building.
class ErrorBoundaryInner extends StatefulWidget {
  /// Creates an inner error boundary.
  const ErrorBoundaryInner({
    required this.child,
    required this.onError,
    super.key,
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
  Widget build(BuildContext context) => Builder(
    builder: (BuildContext context) {
      try {
        return widget.child;
      } on Object catch (error, stackTrace) {
        // Notify the parent error boundary
        widget.onError(error, stackTrace);

        // Return a placeholder widget that will be replaced by the fallback
        return const SizedBox.shrink();
      }
    },
  );
}
