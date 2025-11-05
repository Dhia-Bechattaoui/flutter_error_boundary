// Composite error reporter implementation for the Flutter Error Boundary package.

import '../error_reporter.dart';
import '../error_types.dart';

/// Composite error reporter that sends errors to multiple services simultaneously.
class CompositeErrorReporter implements ErrorReporter {
  /// Creates a new composite error reporter.
  CompositeErrorReporter({
    required List<ErrorReporter> reporters,
    this.continueOnFailure = true,
    this.parallelReporting = true,
  }) : _reporters = List<ErrorReporter>.unmodifiable(reporters);

  /// The list of error reporters to use.
  final List<ErrorReporter> _reporters;

  /// Whether to continue reporting to other services if one fails.
  final bool continueOnFailure;

  /// Whether to report to all services in parallel (true) or sequentially (false).
  final bool parallelReporting;

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    await _reportToAll(errorInfo, <String, dynamic>{});
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    await _reportToAll(errorInfo, context);
  }

  @override
  void setUserIdentifier(String userId) {
    for (final ErrorReporter reporter in _reporters) {
      try {
        reporter.setUserIdentifier(userId);
      } on Object {
        // Silently ignore errors from individual reporters
      }
    }
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    for (final ErrorReporter reporter in _reporters) {
      try {
        reporter.setUserProperties(properties);
      } on Object {
        // Silently ignore errors from individual reporters
      }
    }
  }

  @override
  void clearUserData() {
    for (final ErrorReporter reporter in _reporters) {
      try {
        reporter.clearUserData();
      } on Object {
        // Silently ignore errors from individual reporters
      }
    }
  }

  /// Reports an error to all configured reporters.
  Future<void> _reportToAll(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    if (_reporters.isEmpty) {
      return;
    }

    if (parallelReporting) {
      await _reportInParallel(errorInfo, context);
    } else {
      await _reportSequentially(errorInfo, context);
    }
  }

  /// Reports to all services in parallel.
  Future<void> _reportInParallel(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    final List<Future<void>> futures = <Future<void>>[];

    for (final ErrorReporter reporter in _reporters) {
      futures.add(_reportWithErrorHandling(reporter, errorInfo, context));
    }

    if (continueOnFailure) {
      // Wait for all to complete, but don't fail if some do
      await Future.wait(futures);
    } else {
      // Wait for all to complete and fail if any do
      await Future.wait(futures);
    }
  }

  /// Reports to all services sequentially.
  Future<void> _reportSequentially(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    for (final ErrorReporter reporter in _reporters) {
      try {
        await _reportWithErrorHandling(reporter, errorInfo, context);
      } on Object {
        if (!continueOnFailure) {
          rethrow;
        }
        // Continue to next reporter
      }
    }
  }

  /// Reports an error with error handling for individual reporters.
  Future<void> _reportWithErrorHandling(
    ErrorReporter reporter,
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    try {
      if (context.isEmpty) {
        await reporter.reportError(errorInfo);
      } else {
        await reporter.reportErrorWithContext(errorInfo, context);
      }
    } on Object {
      if (!continueOnFailure) {
        rethrow;
      }
    }
  }

  /// Gets the number of configured reporters.
  int get reporterCount => _reporters.length;

  /// Gets a copy of the configured reporters.
  List<ErrorReporter> get reporters =>
      List<ErrorReporter>.unmodifiable(_reporters);

  /// Adds a new reporter to the composite.
  CompositeErrorReporter addReporter(ErrorReporter reporter) {
    final List<ErrorReporter> newReporters = <ErrorReporter>[
      ..._reporters,
      reporter,
    ];
    return CompositeErrorReporter(
      reporters: newReporters,
      continueOnFailure: continueOnFailure,
      parallelReporting: parallelReporting,
    );
  }

  /// Removes a reporter from the composite.
  CompositeErrorReporter removeReporter(ErrorReporter reporter) {
    final List<ErrorReporter> newReporters = _reporters
        .where((ErrorReporter r) => r != reporter)
        .toList();
    return CompositeErrorReporter(
      reporters: newReporters,
      continueOnFailure: continueOnFailure,
      parallelReporting: parallelReporting,
    );
  }

  /// Creates a new composite with different settings.
  CompositeErrorReporter withSettings({
    bool? continueOnFailure,
    bool? parallelReporting,
  }) => CompositeErrorReporter(
    reporters: _reporters,
    continueOnFailure: continueOnFailure ?? this.continueOnFailure,
    parallelReporting: parallelReporting ?? this.parallelReporting,
  );
}
