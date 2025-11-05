// Controller to programmatically notify an `ErrorBoundary` about errors.

import 'package:flutter/foundation.dart';
import 'error_types.dart';

/// Signature for error listeners used by `ErrorBoundaryController`.
typedef ErrorBoundaryErrorListener =
    void Function(Object error, StackTrace stackTrace);

/// A controller that allows reporting errors to the nearest `ErrorBoundary`.
///
/// This is useful in tests and in situations where you catch an exception
/// but still want the boundary to display its fallback UI.
class ErrorBoundaryController {
  /// Creates a new error boundary controller.
  ErrorBoundaryController();

  ErrorBoundaryErrorListener? _listener;

  /// Reports an error to the attached `ErrorBoundary`.
  ///
  /// If no boundary is attached yet, the call is ignored.
  void report(Object error, [StackTrace? stackTrace]) {
    final StackTrace effective = stackTrace ?? StackTrace.current;
    if (_listener == null) {
      debugPrint(
        'ErrorBoundaryController: No listener attached, ignoring report',
      );
      return;
    }
    debugPrint('ErrorBoundaryController: Calling listener with error: $error');
    _listener!.call(error, effective);
  }

  /// Convenience method to report using an existing `ErrorInfo`.
  void reportErrorInfo(ErrorInfo info) {
    _listener?.call(info.error, info.stackTrace);
  }

  /// Attaches a boundary listener.
  void attach(ErrorBoundaryErrorListener listener) {
    _listener = listener;
    debugPrint('ErrorBoundaryController: Listener attached');
  }

  /// Detaches the boundary listener, if any.
  void detach() {
    _listener = null;
  }
}
