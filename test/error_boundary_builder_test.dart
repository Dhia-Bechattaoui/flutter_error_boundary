import 'package:flutter/material.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorBoundaryBuilder', () {
    late ErrorBoundaryBuilder builder;

    setUp(() {
      builder = const ErrorBoundaryBuilder();
    });

    group('wrap', () {
      test('should create error boundary with default values', () {
        final ErrorBoundary errorBoundary = builder.wrap(
          child: const Text('Test'),
        );

        expect(errorBoundary, isA<ErrorBoundary>());
        expect(errorBoundary.child, isA<Text>());
        expect(errorBoundary.reportErrors, isTrue);
        expect(errorBoundary.attemptRecovery, isTrue);
      });

      test('should create error boundary with custom values', () {
        final _MockErrorHandler customHandler = _MockErrorHandler();
        final _MockErrorReporter customReporter = _MockErrorReporter();
        Text customFallback(ErrorInfo errorInfo) => const Text('Custom Error');

        final ErrorBoundary errorBoundary = builder.wrap(
          child: const Text('Test'),
          errorHandler: customHandler,
          errorReporter: customReporter,
          fallbackBuilder: customFallback,
          reportErrors: false,
          attemptRecovery: false,
          errorSource: 'TestWidget',
          context: <String, dynamic>{'screen': 'test'},
        );

        expect(errorBoundary.errorHandler, equals(customHandler));
        expect(errorBoundary.fallbackBuilder, equals(customFallback));
        expect(errorBoundary.reportErrors, isFalse);
        expect(errorBoundary.attemptRecovery, isFalse);
        expect(errorBoundary.errorSource, equals('TestWidget'));
        expect(
          errorBoundary.context,
          equals(<String, String>{'screen': 'test'}),
        );
      });
    });

    group('withHandler', () {
      test('should create error boundary with custom handler', () {
        final _MockErrorHandler customHandler = _MockErrorHandler();

        final ErrorBoundary errorBoundary = builder.withHandler(
          child: const Text('Test'),
          errorHandler: customHandler,
        );

        expect(errorBoundary.errorHandler, equals(customHandler));
        expect(errorBoundary.reportErrors, isTrue);
        expect(errorBoundary.attemptRecovery, isTrue);
      });

      test('should create error boundary with custom handler and fallback', () {
        final _MockErrorHandler customHandler = _MockErrorHandler();
        Text customFallback(ErrorInfo errorInfo) => const Text('Custom Error');

        final ErrorBoundary errorBoundary = builder.withHandler(
          child: const Text('Test'),
          errorHandler: customHandler,
          fallbackBuilder: customFallback,
        );

        expect(errorBoundary.errorHandler, equals(customHandler));
        expect(errorBoundary.fallbackBuilder, equals(customFallback));
      });
    });

    group('withReporter', () {
      test('should create error boundary with custom reporter', () {
        final _MockErrorReporter customReporter = _MockErrorReporter();

        final ErrorBoundary errorBoundary = builder.withReporter(
          child: const Text('Test'),
          errorReporter: customReporter,
        );

        expect(errorBoundary.errorHandler, isA<DefaultErrorHandler>());
        expect(errorBoundary.reportErrors, isTrue);
        expect(errorBoundary.attemptRecovery, isTrue);
      });

      test(
        'should create error boundary with custom reporter and fallback',
        () {
          final _MockErrorReporter customReporter = _MockErrorReporter();
          Text customFallback(ErrorInfo errorInfo) =>
              const Text('Custom Error');

          final ErrorBoundary errorBoundary = builder.withReporter(
            child: const Text('Test'),
            errorReporter: customReporter,
            fallbackBuilder: customFallback,
          );

          expect(errorBoundary.fallbackBuilder, equals(customFallback));
        },
      );
    });

    group('withFallback', () {
      test('should create error boundary with custom fallback', () {
        Text customFallback(ErrorInfo errorInfo) => const Text('Custom Error');

        final ErrorBoundary errorBoundary = builder.withFallback(
          child: const Text('Test'),
          fallbackBuilder: customFallback,
        );

        expect(errorBoundary.fallbackBuilder, equals(customFallback));
        expect(errorBoundary.errorHandler, isA<DefaultErrorHandler>());
      });

      test('should create error boundary with custom fallback and handler', () {
        Text customFallback(ErrorInfo errorInfo) => const Text('Custom Error');
        final _MockErrorHandler customHandler = _MockErrorHandler();

        final ErrorBoundary errorBoundary = builder.withFallback(
          child: const Text('Test'),
          fallbackBuilder: customFallback,
          errorHandler: customHandler,
        );

        expect(errorBoundary.fallbackBuilder, equals(customFallback));
        expect(errorBoundary.errorHandler, equals(customHandler));
      });
    });

    group('simple', () {
      test('should create simple error boundary', () {
        final ErrorBoundary errorBoundary = builder.simple(
          child: const Text('Test'),
        );

        expect(errorBoundary, isA<ErrorBoundary>());
        expect(errorBoundary.reportErrors, isFalse);
        expect(errorBoundary.attemptRecovery, isFalse);
      });

      test('should create simple error boundary with custom fallback', () {
        Text customFallback(ErrorInfo errorInfo) => const Text('Custom Error');

        final ErrorBoundary errorBoundary = builder.simple(
          child: const Text('Test'),
          fallbackBuilder: customFallback,
        );

        expect(errorBoundary.fallbackBuilder, equals(customFallback));
      });
    });

    group('full', () {
      test('should create full-featured error boundary', () {
        final ErrorBoundary errorBoundary = builder.full(
          child: const Text('Test'),
        );

        expect(errorBoundary, isA<ErrorBoundary>());
        expect(errorBoundary.reportErrors, isTrue);
        expect(errorBoundary.attemptRecovery, isTrue);
      });

      test('should create full-featured error boundary with custom values', () {
        final ErrorBoundary errorBoundary = builder.full(
          child: const Text('Test'),
          errorSource: 'TestWidget',
          context: <String, dynamic>{'screen': 'test'},
        );

        expect(errorBoundary.errorSource, equals('TestWidget'));
        expect(
          errorBoundary.context,
          equals(<String, String>{'screen': 'test'}),
        );
      });
    });
  });

  group('ErrorBoundaryExtension', () {
    test('withErrorBoundary should wrap widget with error boundary', () {
      const Text widget = Text('Test');
      final ErrorBoundary errorBoundary = widget.withErrorBoundary();

      expect(errorBoundary, isA<ErrorBoundary>());
      expect(errorBoundary.child, equals(widget));
      expect(errorBoundary.reportErrors, isTrue);
      expect(errorBoundary.attemptRecovery, isTrue);
    });

    test('withErrorBoundary should use custom values', () {
      const Text widget = Text('Test');
      final _MockErrorHandler customHandler = _MockErrorHandler();
      final _MockErrorReporter customReporter = _MockErrorReporter();

      final ErrorBoundary errorBoundary = widget.withErrorBoundary(
        errorHandler: customHandler,
        errorReporter: customReporter,
        reportErrors: false,
        attemptRecovery: false,
        errorSource: 'TestWidget',
        context: <String, dynamic>{'screen': 'test'},
      );

      expect(errorBoundary.errorHandler, equals(customHandler));
      expect(errorBoundary.reportErrors, isFalse);
      expect(errorBoundary.attemptRecovery, isFalse);
      expect(errorBoundary.errorSource, equals('TestWidget'));
      expect(errorBoundary.context, equals(<String, String>{'screen': 'test'}));
    });

    test(
      'withSimpleErrorBoundary should wrap widget with simple error boundary',
      () {
        const Text widget = Text('Test');
        final ErrorBoundary errorBoundary = widget.withSimpleErrorBoundary();

        expect(errorBoundary, isA<ErrorBoundary>());
        expect(errorBoundary.reportErrors, isFalse);
        expect(errorBoundary.attemptRecovery, isFalse);
      },
    );

    test(
      'withFullErrorBoundary should wrap widget with full error boundary',
      () {
        const Text widget = Text('Test');
        final ErrorBoundary errorBoundary = widget.withFullErrorBoundary(
          errorSource: 'TestWidget',
          context: <String, dynamic>{'screen': 'test'},
        );

        expect(errorBoundary, isA<ErrorBoundary>());
        expect(errorBoundary.reportErrors, isTrue);
        expect(errorBoundary.attemptRecovery, isTrue);
        expect(errorBoundary.errorSource, equals('TestWidget'));
        expect(
          errorBoundary.context,
          equals(<String, String>{'screen': 'test'}),
        );
      },
    );
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
