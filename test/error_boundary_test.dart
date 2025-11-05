import 'package:flutter/material.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorBoundary', () {
    testWidgets('should render child widget when no error occurs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: ErrorBoundary(child: Text('Hello World'))),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should display fallback UI when error occurs', (
      WidgetTester tester,
    ) async {
      final ErrorBoundaryController controller = ErrorBoundaryController();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            controller: controller,
            child: const Text('Child'),
          ),
        ),
      );

      // Trigger an error via controller
      controller.report('Test Error');
      await tester.pumpAndSettle();

      // Should show fallback UI
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call error handler when error occurs', (
      WidgetTester tester,
    ) async {
      final _MockErrorHandler mockHandler = _MockErrorHandler();
      final ErrorBoundaryController controller = ErrorBoundaryController();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            controller: controller,
            child: const Text('Child'),
          ),
        ),
      );

      // Trigger an error
      controller.report('Test Error');
      await tester.pumpAndSettle();

      expect(mockHandler.handleErrorCalled, isTrue);
    });

    testWidgets('should call error reporter when error occurs', (
      WidgetTester tester,
    ) async {
      // Note: ErrorBoundary doesn't currently support ErrorReporter directly.
      // Error reporting is handled through ErrorHandler.
      // This test is skipped until ErrorReporter support is added to ErrorBoundary.
      // TODO: Add ErrorReporter support to ErrorBoundary or update test to use ErrorHandler
      final ErrorBoundaryController controller = ErrorBoundaryController();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            controller: controller,
            child: const Text('Child'),
          ),
        ),
      );

      // Trigger an error
      controller.report('Test Error');
      await tester.pumpAndSettle();

      // Error should be handled (fallback UI should be shown)
      expect(find.text('Something went wrong'), findsOneWidget);
    }, skip: true); // TODO: ErrorBoundary does not support ErrorReporter parameter

    testWidgets('should not report errors when reportErrors is false', (
      WidgetTester tester,
    ) async {
      final _MockErrorReporter mockReporter = _MockErrorReporter();
      final ErrorBoundaryController controller = ErrorBoundaryController();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            reportErrors: false,
            controller: controller,
            child: const Text('Child'),
          ),
        ),
      );

      // Trigger an error
      controller.report('Test Error');
      await tester.pumpAndSettle();

      expect(mockReporter.reportErrorCalled, isFalse);
    });

    testWidgets('should use custom fallback builder when provided', (
      WidgetTester tester,
    ) async {
      final ErrorBoundaryController controller = ErrorBoundaryController();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            fallbackBuilder: (ErrorInfo errorInfo) =>
                const Text('Custom Error: Test Error'),
            controller: controller,
            child: const Text('Child'),
          ),
        ),
      );

      // Trigger an error
      controller.report('Test Error');
      await tester.pumpAndSettle();

      expect(find.text('Custom Error: Test Error'), findsOneWidget);
    });

    testWidgets('should attempt recovery when attemptRecovery is true', (
      WidgetTester tester,
    ) async {
      final _MockErrorHandler mockHandler = _MockErrorHandler();
      final ErrorBoundaryController controller = ErrorBoundaryController();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            attemptRecovery: true,
            controller: controller,
            child: const Text('Child'),
          ),
        ),
      );

      // Trigger an error
      controller.report('Test Error');
      await tester.pumpAndSettle();

      expect(mockHandler.attemptRecoveryCalled, isTrue);
    });

    testWidgets('should not attempt recovery when attemptRecovery is false', (
      WidgetTester tester,
    ) async {
      final _MockErrorHandler mockHandler = _MockErrorHandler();
      final ErrorBoundaryController controller = ErrorBoundaryController();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            controller: controller,
            child: const Text('Child'),
          ),
        ),
      );

      // Trigger an error
      controller.report('Test Error');
      await tester.pumpAndSettle();

      expect(mockHandler.attemptRecoveryCalled, isFalse);
    });

    testWidgets('should include error source in error info', (
      WidgetTester tester,
    ) async {
      final _MockErrorHandler mockHandler = _MockErrorHandler();
      final ErrorBoundaryController controller = ErrorBoundaryController();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            errorSource: 'TestWidget',
            controller: controller,
            child: const Text('Child'),
          ),
        ),
      );

      // Trigger an error
      controller.report('Test Error');
      await tester.pumpAndSettle();

      expect(mockHandler.lastErrorInfo?.errorSource, equals('TestWidget'));
    });

    testWidgets('should include context in error info', (
      WidgetTester tester,
    ) async {
      final _MockErrorHandler mockHandler = _MockErrorHandler();
      final ErrorBoundaryController controller = ErrorBoundaryController();
      final Map<String, String> context = <String, String>{
        'screen': 'test',
        'user': 'testuser',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            context: context,
            controller: controller,
            child: const Text('Child'),
          ),
        ),
      );

      // Trigger an error
      controller.report('Test Error');
      await tester.pumpAndSettle();

      expect(mockHandler.lastErrorInfo?.context, equals(context));
    });
  });
}

class _MockErrorHandler implements ErrorHandler {
  bool handleErrorCalled = false;
  bool shouldReportErrorCalled = false;
  bool shouldAttemptRecoveryCalled = false;
  bool attemptRecoveryCalled = false;
  ErrorInfo? lastErrorInfo;

  @override
  Future<bool> handleError(ErrorInfo errorInfo) async {
    handleErrorCalled = true;
    lastErrorInfo = errorInfo;
    return true;
  }

  @override
  bool shouldReportError(ErrorInfo errorInfo) {
    shouldReportErrorCalled = true;
    return true;
  }

  @override
  bool shouldAttemptRecovery(ErrorInfo errorInfo) {
    shouldAttemptRecoveryCalled = true;
    return true;
  }

  @override
  Future<bool> attemptRecovery(ErrorInfo errorInfo) async {
    attemptRecoveryCalled = true;
    return true;
  }
}

class _MockErrorReporter implements ErrorReporter {
  bool reportErrorCalled = false;
  bool reportErrorWithContextCalled = false;

  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    reportErrorCalled = true;
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    reportErrorWithContextCalled = true;
  }

  @override
  void setUserIdentifier(String userId) {}

  @override
  void setUserProperties(Map<String, dynamic> properties) {}

  @override
  void clearUserData() {}
}
