import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

/// Test configuration and utilities for the flutter_error_boundary package.
class TestConfig {
  /// Default timeout for async operations in tests.
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Default pump duration for widget tests.
  static const Duration defaultPumpDuration = Duration(milliseconds: 100);

  /// Creates a test error info with default values.
  static ErrorInfo createTestErrorInfo({
    Object? error,
    StackTrace? stackTrace,
    ErrorSeverity? severity,
    ErrorType? type,
    String? errorSource,
    DateTime? timestamp,
    Map<String, dynamic>? context,
    Map<String, dynamic>? userData,
  }) {
    return ErrorInfo(
      error: error ?? Exception('Test error'),
      stackTrace: stackTrace ?? StackTrace.current,
      severity: severity ?? ErrorSeverity.medium,
      type: type ?? ErrorType.unknown,
      errorSource: errorSource ?? 'TestWidget',
      timestamp: timestamp ?? DateTime.now(),
      context: context ?? {'test': true},
      userData: userData ?? {'testUser': true},
    );
  }

  /// Creates a test boundary error with default values.
  static BoundaryError createTestBoundaryError({
    Object? error,
    StackTrace? stackTrace,
    String? errorSource,
    DateTime? timestamp,
  }) {
    return BoundaryError(
      error: error ?? Exception('Test error'),
      stackTrace: stackTrace ?? StackTrace.current,
      errorSource: errorSource ?? 'TestWidget',
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Waits for the specified duration and pumps the widget.
  static Future<void> pumpAndWait(
    WidgetTester tester, {
    Duration? duration,
  }) async {
    await tester.pump(duration ?? defaultPumpDuration);
    await tester.pumpAndSettle();
  }

  /// Creates a mock error handler for testing.
  static MockErrorHandler createMockErrorHandler() {
    return MockErrorHandler();
  }

  /// Creates a mock error reporter for testing.
  static MockErrorReporter createMockErrorReporter() {
    return MockErrorReporter();
  }
}

/// Mock error handler for testing.
class MockErrorHandler implements ErrorHandler {
  bool _handleErrorCalled = false;
  bool _shouldReportErrorCalled = false;
  bool _shouldAttemptRecoveryCalled = false;
  bool _attemptRecoveryCalled = false;
  ErrorInfo? _lastErrorInfo;

  bool get handleErrorCalled => _handleErrorCalled;
  bool get shouldReportErrorCalled => _shouldReportErrorCalled;
  bool get shouldAttemptRecoveryCalled => _shouldAttemptRecoveryCalled;
  bool get attemptRecoveryCalled => _attemptRecoveryCalled;
  ErrorInfo? get lastErrorInfo => _lastErrorInfo;

  @override
  Future<bool> handleError(ErrorInfo errorInfo) async {
    _handleErrorCalled = true;
    _lastErrorInfo = errorInfo;
    return true;
  }

  @override
  bool shouldReportError(ErrorInfo errorInfo) {
    _shouldReportErrorCalled = true;
    return true;
  }

  @override
  bool shouldAttemptRecovery(ErrorInfo errorInfo) {
    _shouldAttemptRecoveryCalled = true;
    return true;
  }

  @override
  Future<bool> attemptRecovery(ErrorInfo errorInfo) async {
    _attemptRecoveryCalled = true;
    return true;
  }

  void reset() {
    _handleErrorCalled = false;
    _shouldReportErrorCalled = false;
    _shouldAttemptRecoveryCalled = false;
    _attemptRecoveryCalled = false;
    _lastErrorInfo = null;
  }
}

/// Mock error reporter for testing.
class MockErrorReporter implements ErrorReporter {
  bool _reportErrorCalled = false;
  bool _reportErrorWithContextCalled = false;
  String? _lastUserId;
  Map<String, dynamic>? _lastUserProperties;

  bool get reportErrorCalled => _reportErrorCalled;
  bool get reportErrorWithContextCalled => _reportErrorWithContextCalled;
  String? get lastUserId => _lastUserId;
  Map<String, dynamic>? get lastUserProperties => _lastUserProperties;

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    _reportErrorCalled = true;
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    _reportErrorWithContextCalled = true;
  }

  @override
  void setUserIdentifier(String userId) {
    _lastUserId = userId;
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    _lastUserProperties = properties;
  }

  @override
  void clearUserData() {
    _lastUserId = null;
    _lastUserProperties = null;
  }

  void reset() {
    _reportErrorCalled = false;
    _reportErrorWithContextCalled = false;
    _lastUserId = null;
    _lastUserProperties = null;
  }
}
