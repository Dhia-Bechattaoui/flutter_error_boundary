import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

void main() {
  group('ErrorBoundaryBuilder', () {
    late ErrorBoundaryBuilder builder;

    setUp(() {
      builder = const ErrorBoundaryBuilder();
    });

    group('wrap', () {
      test('should create error boundary with default values', () {
        final errorBoundary = builder.wrap(child: Text('Test'));

        expect(errorBoundary, isA<ErrorBoundary>());
        expect(errorBoundary.child, isA<Text>());
        expect(errorBoundary.reportErrors, isTrue);
        expect(errorBoundary.attemptRecovery, isTrue);
      });

      test('should create error boundary with custom values', () {
        final customHandler = _MockErrorHandler();
        final customReporter = _MockErrorReporter();
        final customFallback = (ErrorInfo errorInfo) => Text('Custom Error');

        final errorBoundary = builder.wrap(
          child: Text('Test'),
          errorHandler: customHandler,
          errorReporter: customReporter,
          fallbackBuilder: customFallback,
          reportErrors: false,
          attemptRecovery: false,
          errorSource: 'TestWidget',
          context: {'screen': 'test'},
        );

        expect(errorBoundary.errorHandler, equals(customHandler));
        expect(errorBoundary.errorReporter, equals(customReporter));
        expect(errorBoundary.fallbackBuilder, equals(customFallback));
        expect(errorBoundary.reportErrors, isFalse);
        expect(errorBoundary.attemptRecovery, isFalse);
        expect(errorBoundary.errorSource, equals('TestWidget'));
        expect(errorBoundary.context, equals({'screen': 'test'}));
      });
    });

    group('withHandler', () {
      test('should create error boundary with custom handler', () {
        final customHandler = _MockErrorHandler();

        final errorBoundary = builder.withHandler(
          child: Text('Test'),
          errorHandler: customHandler,
        );

        expect(errorBoundary.errorHandler, equals(customHandler));
        expect(errorBoundary.errorReporter, isA<DefaultErrorReporter>());
        expect(errorBoundary.reportErrors, isTrue);
        expect(errorBoundary.attemptRecovery, isTrue);
      });

      test('should create error boundary with custom handler and fallback', () {
        final customHandler = _MockErrorHandler();
        final customFallback = (ErrorInfo errorInfo) => Text('Custom Error');

        final errorBoundary = builder.withHandler(
          child: Text('Test'),
          errorHandler: customHandler,
          fallbackBuilder: customFallback,
        );

        expect(errorBoundary.errorHandler, equals(customHandler));
        expect(errorBoundary.fallbackBuilder, equals(customFallback));
      });
    });

    group('withReporter', () {
      test('should create error boundary with custom reporter', () {
        final customReporter = _MockErrorReporter();

        final errorBoundary = builder.withReporter(
          child: Text('Test'),
          errorReporter: customReporter,
        );

        expect(errorBoundary.errorReporter, equals(customReporter));
        expect(errorBoundary.errorHandler, isA<DefaultErrorHandler>());
        expect(errorBoundary.reportErrors, isTrue);
        expect(errorBoundary.attemptRecovery, isTrue);
      });

      test('should create error boundary with custom reporter and fallback',
          () {
        final customReporter = _MockErrorReporter();
        final customFallback = (ErrorInfo errorInfo) => Text('Custom Error');

        final errorBoundary = builder.withReporter(
          child: Text('Test'),
          errorReporter: customReporter,
          fallbackBuilder: customFallback,
        );

        expect(errorBoundary.errorReporter, equals(customReporter));
        expect(errorBoundary.fallbackBuilder, equals(customFallback));
      });
    });

    group('withFallback', () {
      test('should create error boundary with custom fallback', () {
        final customFallback = (ErrorInfo errorInfo) => Text('Custom Error');

        final errorBoundary = builder.withFallback(
          child: Text('Test'),
          fallbackBuilder: customFallback,
        );

        expect(errorBoundary.fallbackBuilder, equals(customFallback));
        expect(errorBoundary.errorHandler, isA<DefaultErrorHandler>());
        expect(errorBoundary.errorReporter, isA<DefaultErrorReporter>());
      });

      test('should create error boundary with custom fallback and handler', () {
        final customFallback = (ErrorInfo errorInfo) => Text('Custom Error');
        final customHandler = _MockErrorHandler();

        final errorBoundary = builder.withFallback(
          child: Text('Test'),
          fallbackBuilder: customFallback,
          errorHandler: customHandler,
        );

        expect(errorBoundary.fallbackBuilder, equals(customFallback));
        expect(errorBoundary.errorHandler, equals(customHandler));
      });
    });

    group('simple', () {
      test('should create simple error boundary', () {
        final errorBoundary = builder.simple(child: Text('Test'));

        expect(errorBoundary, isA<ErrorBoundary>());
        expect(errorBoundary.reportErrors, isFalse);
        expect(errorBoundary.attemptRecovery, isFalse);
      });

      test('should create simple error boundary with custom fallback', () {
        final customFallback = (ErrorInfo errorInfo) => Text('Custom Error');

        final errorBoundary = builder.simple(
          child: Text('Test'),
          fallbackBuilder: customFallback,
        );

        expect(errorBoundary.fallbackBuilder, equals(customFallback));
      });
    });

    group('full', () {
      test('should create full-featured error boundary', () {
        final errorBoundary = builder.full(child: Text('Test'));

        expect(errorBoundary, isA<ErrorBoundary>());
        expect(errorBoundary.reportErrors, isTrue);
        expect(errorBoundary.attemptRecovery, isTrue);
      });

      test('should create full-featured error boundary with custom values', () {
        final errorBoundary = builder.full(
          child: Text('Test'),
          errorSource: 'TestWidget',
          context: {'screen': 'test'},
        );

        expect(errorBoundary.errorSource, equals('TestWidget'));
        expect(errorBoundary.context, equals({'screen': 'test'}));
      });
    });
  });

  group('ErrorBoundaryExtension', () {
    test('withErrorBoundary should wrap widget with error boundary', () {
      final widget = Text('Test');
      final errorBoundary = widget.withErrorBoundary();

      expect(errorBoundary, isA<ErrorBoundary>());
      expect(errorBoundary.child, equals(widget));
      expect(errorBoundary.reportErrors, isTrue);
      expect(errorBoundary.attemptRecovery, isTrue);
    });

    test('withErrorBoundary should use custom values', () {
      final widget = Text('Test');
      final customHandler = _MockErrorHandler();
      final customReporter = _MockErrorReporter();

      final errorBoundary = widget.withErrorBoundary(
        errorHandler: customHandler,
        errorReporter: customReporter,
        reportErrors: false,
        attemptRecovery: false,
        errorSource: 'TestWidget',
        context: {'screen': 'test'},
      );

      expect(errorBoundary.errorHandler, equals(customHandler));
      expect(errorBoundary.errorReporter, equals(customReporter));
      expect(errorBoundary.reportErrors, isFalse);
      expect(errorBoundary.attemptRecovery, isFalse);
      expect(errorBoundary.errorSource, equals('TestWidget'));
      expect(errorBoundary.context, equals({'screen': 'test'}));
    });

    test(
        'withSimpleErrorBoundary should wrap widget with simple error boundary',
        () {
      final widget = Text('Test');
      final errorBoundary = widget.withSimpleErrorBoundary();

      expect(errorBoundary, isA<ErrorBoundary>());
      expect(errorBoundary.reportErrors, isFalse);
      expect(errorBoundary.attemptRecovery, isFalse);
    });

    test('withFullErrorBoundary should wrap widget with full error boundary',
        () {
      final widget = Text('Test');
      final errorBoundary = widget.withFullErrorBoundary(
        errorSource: 'TestWidget',
        context: {'screen': 'test'},
      );

      expect(errorBoundary, isA<ErrorBoundary>());
      expect(errorBoundary.reportErrors, isTrue);
      expect(errorBoundary.attemptRecovery, isTrue);
      expect(errorBoundary.errorSource, equals('TestWidget'));
      expect(errorBoundary.context, equals({'screen': 'test'}));
    });
  });
}

class _MockErrorHandler implements ErrorHandler {
  @override
  Future<bool> handleError(ErrorInfo errorInfo) async => true;

  @override
  bool shouldReportError(ErrorInfo errorInfo) => true;

  @override
  bool shouldAttemptRecovery(ErrorInfo errorInfo) => true;

  @override
  Future<bool> attemptRecovery(ErrorInfo errorInfo) async => true;
}

class _MockErrorReporter implements ErrorReporter {
  @override
  Future<void> reportError(ErrorInfo errorInfo) async {}

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {}

  @override
  void setUserIdentifier(String userId) {}

  @override
  void setUserProperties(Map<String, dynamic> properties) {}

  @override
  void clearUserData() {}
}
