import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

void main() {
  group('ErrorTypes', () {
    test('BoundaryError should create with required parameters', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final boundaryError = BoundaryError(
        error: error,
        stackTrace: stackTrace,
        errorSource: 'TestWidget',
        timestamp: DateTime(2024, 1, 1),
      );

      expect(boundaryError.error, equals(error));
      expect(boundaryError.stackTrace, equals(stackTrace));
      expect(boundaryError.errorSource, equals('TestWidget'));
      expect(boundaryError.timestamp, equals(DateTime(2024, 1, 1)));
    });

    test('BoundaryError should have default values for optional parameters',
        () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final boundaryError = BoundaryError(
        error: error,
        stackTrace: stackTrace,
      );

      expect(boundaryError.errorSource, isNull);
      expect(boundaryError.timestamp, isNull);
    });

    test('BoundaryError toString should include error information', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final boundaryError = BoundaryError(
        error: error,
        stackTrace: stackTrace,
        errorSource: 'TestWidget',
        timestamp: DateTime(2024, 1, 1),
      );

      final string = boundaryError.toString();
      expect(string, contains('Test error'));
      expect(string, contains('TestWidget'));
      expect(string, contains('2024-01-01'));
    });
  });

  group('ErrorSeverity', () {
    test('should have correct enum values', () {
      expect(ErrorSeverity.values, hasLength(4));
      expect(ErrorSeverity.low.name, equals('low'));
      expect(ErrorSeverity.medium.name, equals('medium'));
      expect(ErrorSeverity.high.name, equals('high'));
      expect(ErrorSeverity.critical.name, equals('critical'));
    });
  });

  group('ErrorType', () {
    test('should have correct enum values', () {
      expect(ErrorType.values, hasLength(6));
      expect(ErrorType.build.name, equals('build'));
      expect(ErrorType.runtime.name, equals('runtime'));
      expect(ErrorType.rendering.name, equals('rendering'));
      expect(ErrorType.state.name, equals('state'));
      expect(ErrorType.external.name, equals('external'));
      expect(ErrorType.unknown.name, equals('unknown'));
    });
  });

  group('ErrorInfo', () {
    test('should create with required parameters', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final errorInfo = ErrorInfo(
        error: error,
        stackTrace: stackTrace,
        severity: ErrorSeverity.high,
        type: ErrorType.runtime,
        errorSource: 'TestWidget',
        timestamp: DateTime(2024, 1, 1),
        context: {'screen': 'test'},
        userData: {'userId': '123'},
      );

      expect(errorInfo.error, equals(error));
      expect(errorInfo.stackTrace, equals(stackTrace));
      expect(errorInfo.severity, equals(ErrorSeverity.high));
      expect(errorInfo.type, equals(ErrorType.runtime));
      expect(errorInfo.errorSource, equals('TestWidget'));
      expect(errorInfo.timestamp, equals(DateTime(2024, 1, 1)));
      expect(errorInfo.context, equals({'screen': 'test'}));
      expect(errorInfo.userData, equals({'userId': '123'}));
    });

    test('should have default values for optional parameters', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final errorInfo = ErrorInfo(
        error: error,
        stackTrace: stackTrace,
        severity: ErrorSeverity.medium,
        type: ErrorType.unknown,
      );

      expect(errorInfo.errorSource, isNull);
      expect(errorInfo.timestamp, isNull);
      expect(errorInfo.context, isNull);
      expect(errorInfo.userData, isNull);
    });

    test('toString should include error information', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final errorInfo = ErrorInfo(
        error: error,
        stackTrace: stackTrace,
        severity: ErrorSeverity.high,
        type: ErrorType.runtime,
        errorSource: 'TestWidget',
      );

      final string = errorInfo.toString();
      expect(string, contains('Test error'));
      expect(string, contains('high'));
      expect(string, contains('runtime'));
      expect(string, contains('TestWidget'));
    });
  });
}
