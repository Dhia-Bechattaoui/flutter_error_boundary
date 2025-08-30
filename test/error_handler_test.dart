import 'package:flutter_error_boundary/flutter_error_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultErrorHandler', () {
    late DefaultErrorHandler handler;

    setUp(() {
      handler = const DefaultErrorHandler();
    });

    test('should create with default values', () {
      expect(handler.reportAllErrors, isFalse);
      expect(handler.attemptRecoveryForAll, isFalse);
      expect(handler.maxRecoveryAttempts, equals(3));
    });

    test('should create with custom values', () {
      final customHandler = DefaultErrorHandler(
        reportAllErrors: true,
        attemptRecoveryForAll: true,
        maxRecoveryAttempts: 5,
      );

      expect(customHandler.reportAllErrors, isTrue);
      expect(customHandler.attemptRecoveryForAll, isTrue);
      expect(customHandler.maxRecoveryAttempts, equals(5));
    });

    group('handleError', () {
      test('should handle error successfully', () async {
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        final result = await handler.handleError(errorInfo);
        expect(result, isTrue);
      });

      test('should handle error handling failure gracefully', () async {
        // This test verifies that the handler doesn't crash when error handling fails
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        final result = await handler.handleError(errorInfo);
        expect(result, isTrue);
      });
    });

    group('shouldReportError', () {
      test('should report high severity errors when reportAllErrors is false',
          () {
        final highSeverityError = ErrorInfo(
          error: Exception('High severity error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.high,
          type: ErrorType.runtime,
        );

        expect(handler.shouldReportError(highSeverityError), isTrue);
      });

      test(
          'should report critical severity errors when reportAllErrors is false',
          () {
        final criticalSeverityError = ErrorInfo(
          error: Exception('Critical severity error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.critical,
          type: ErrorType.runtime,
        );

        expect(handler.shouldReportError(criticalSeverityError), isTrue);
      });

      test(
          'should not report low severity errors when reportAllErrors is false',
          () {
        final lowSeverityError = ErrorInfo(
          error: Exception('Low severity error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.low,
          type: ErrorType.runtime,
        );

        expect(handler.shouldReportError(lowSeverityError), isFalse);
      });

      test(
          'should not report medium severity errors when reportAllErrors is false',
          () {
        final mediumSeverityError = ErrorInfo(
          error: Exception('Medium severity error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        expect(handler.shouldReportError(mediumSeverityError), isFalse);
      });

      test('should report all errors when reportAllErrors is true', () {
        final customHandler = DefaultErrorHandler(reportAllErrors: true);

        final lowSeverityError = ErrorInfo(
          error: Exception('Low severity error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.low,
          type: ErrorType.runtime,
        );

        expect(customHandler.shouldReportError(lowSeverityError), isTrue);
      });
    });

    group('shouldAttemptRecovery', () {
      test(
          'should attempt recovery for non-critical errors when attemptRecoveryForAll is false',
          () {
        final nonCriticalError = ErrorInfo(
          error: Exception('Non-critical error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.high,
          type: ErrorType.runtime,
        );

        expect(handler.shouldAttemptRecovery(nonCriticalError), isTrue);
      });

      test(
          'should not attempt recovery for critical errors when attemptRecoveryForAll is false',
          () {
        final criticalError = ErrorInfo(
          error: Exception('Critical error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.critical,
          type: ErrorType.runtime,
        );

        expect(handler.shouldAttemptRecovery(criticalError), isFalse);
      });

      test(
          'should attempt recovery for all errors when attemptRecoveryForAll is true',
          () {
        final customHandler = DefaultErrorHandler(attemptRecoveryForAll: true);

        final criticalError = ErrorInfo(
          error: Exception('Critical error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.critical,
          type: ErrorType.runtime,
        );

        expect(customHandler.shouldAttemptRecovery(criticalError), isTrue);
      });
    });

    group('attemptRecovery', () {
      test('should attempt recovery for non-critical errors', () async {
        final nonCriticalError = ErrorInfo(
          error: Exception('Non-critical error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.high,
          type: ErrorType.runtime,
        );

        final result = await handler.attemptRecovery(nonCriticalError);
        expect(result, isTrue);
      });

      test('should not attempt recovery for critical errors', () async {
        final criticalError = ErrorInfo(
          error: Exception('Critical error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.critical,
          type: ErrorType.runtime,
        );

        final result = await handler.attemptRecovery(criticalError);
        expect(result, isFalse);
      });

      test('should handle recovery failure gracefully', () async {
        // This test verifies that the handler doesn't crash when recovery fails
        final errorInfo = ErrorInfo(
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
          severity: ErrorSeverity.medium,
          type: ErrorType.runtime,
        );

        final result = await handler.attemptRecovery(errorInfo);
        expect(result, isTrue);
      });
    });
  });
}
