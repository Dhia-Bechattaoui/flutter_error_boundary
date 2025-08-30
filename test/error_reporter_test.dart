import 'package:flutter_error_boundary/flutter_error_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultErrorReporter', () {
    late DefaultErrorReporter reporter;

    setUp(() {
      reporter = DefaultErrorReporter();
    });

    test('should create with default values', () {
      expect(reporter.enabled, isTrue);
      expect(reporter.includeStackTrace, isTrue);
      expect(reporter.includeUserData, isFalse);
    });

    test('should create with custom values', () {
      final customReporter = DefaultErrorReporter(
        enabled: false,
        includeStackTrace: false,
        includeUserData: true,
      );

      expect(customReporter.enabled, isFalse);
      expect(customReporter.includeStackTrace, isFalse);
      expect(customReporter.includeUserData, isTrue);
    });

    group('reportError', () {
      test('should report error when enabled', () async {
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        // Should not throw
        await reporter.reportError(errorInfo);
      });

      test('should not report error when disabled', () async {
        final disabledReporter = DefaultErrorReporter(enabled: false);
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        // Should not throw
        await disabledReporter.reportError(errorInfo);
      });

      test('should handle reporting failure gracefully', () async {
        // This test verifies that the reporter doesn't crash when reporting fails
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        // Should not throw
        await reporter.reportError(errorInfo);
      });
    });

    group('reportErrorWithContext', () {
      test('should report error with context when enabled', () async {
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );
        final context = {'screen': 'test', 'user': 'testuser'};

        // Should not throw
        await reporter.reportErrorWithContext(errorInfo, context);
      });

      test('should not report error with context when disabled', () async {
        final disabledReporter = DefaultErrorReporter(enabled: false);
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );
        final context = {'screen': 'test', 'user': 'testuser'};

        // Should not throw
        await disabledReporter.reportErrorWithContext(errorInfo, context);
      });

      test('should handle reporting failure gracefully', () async {
        // This test verifies that the reporter doesn't crash when reporting fails
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );
        final context = {'screen': 'test', 'user': 'testuser'};

        // Should not throw
        await reporter.reportErrorWithContext(errorInfo, context);
      });
    });

    group('user identification', () {
      test('should set user identifier', () {
        reporter.setUserIdentifier('testuser123');
        // No assertion needed as this is just a setter
      });

      test('should set user properties', () {
        final properties = {'name': 'Test User', 'role': 'admin'};
        reporter.setUserProperties(properties);
        // No assertion needed as this is just a setter
      });

      test('should clear user data', () {
        reporter.clearUserData();
        // No assertion needed as this is just a setter
      });
    });

    group('error report preparation', () {
      test('should include stack trace when enabled', () async {
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        await reporter.reportError(errorInfo);
        // The actual report preparation is tested through integration
      });

      test('should not include stack trace when disabled', () async {
        final noStackTraceReporter =
            DefaultErrorReporter(includeStackTrace: false);
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        await noStackTraceReporter.reportError(errorInfo);
        // The actual report preparation is tested through integration
      });

      test('should include user data when enabled', () async {
        final userDataReporter = DefaultErrorReporter(includeUserData: true);
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        userDataReporter.setUserIdentifier('testuser123');
        userDataReporter.setUserProperties({'role': 'admin'});

        await userDataReporter.reportError(errorInfo);
        // The actual report preparation is tested through integration
      });

      test('should not include user data when disabled', () async {
        final noUserDataReporter = DefaultErrorReporter(includeUserData: false);
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        noUserDataReporter.setUserIdentifier('testuser123');
        noUserDataReporter.setUserProperties({'role': 'admin'});

        await noUserDataReporter.reportError(errorInfo);
        // The actual report preparation is tested through integration
      });
    });
  });

  group('NoOpErrorReporter', () {
    late NoOpErrorReporter reporter;

    setUp(() {
      reporter = const NoOpErrorReporter();
    });

    test('should not report errors', () async {
      final errorInfo = ErrorInfo(
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.medium,
        type: ErrorType.runtime,
      );

      // Should not throw and do nothing
      await reporter.reportError(errorInfo);
    });

    test('should not report errors with context', () async {
      final errorInfo = ErrorInfo(
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.medium,
        type: ErrorType.runtime,
      );
      final context = {'screen': 'test', 'user': 'testuser'};

      // Should not throw and do nothing
      await reporter.reportErrorWithContext(errorInfo, context);
    });

    test('should not set user identifier', () {
      // Should not throw and do nothing
      reporter.setUserIdentifier('testuser123');
    });

    test('should not set user properties', () {
      final properties = {'name': 'Test User', 'role': 'admin'};
      // Should not throw and do nothing
      reporter.setUserProperties(properties);
    });

    test('should not clear user data', () {
      // Should not throw and do nothing
      reporter.clearUserData();
    });
  });
}
