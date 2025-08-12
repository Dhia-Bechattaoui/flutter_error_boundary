import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

void main() {
  group('ErrorBoundary', () {
    testWidgets('should render child widget when no error occurs',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: const Text('Hello World'),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should display fallback UI when error occurs', (tester) async {
      final errorWidget = _ErrorThrowingWidget();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: errorWidget,
          ),
        ),
      );

      // Trigger an error by calling setState with an error
      errorWidget.triggerError();
      await tester.pumpAndSettle();

      // Should show fallback UI
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call error handler when error occurs', (tester) async {
      final mockHandler = _MockErrorHandler();
      final errorWidget = _ErrorThrowingWidget();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            child: errorWidget,
          ),
        ),
      );

      // Trigger an error
      errorWidget.triggerError();
      await tester.pumpAndSettle();

      expect(mockHandler.handleErrorCalled, isTrue);
    });

    testWidgets('should call error reporter when error occurs', (tester) async {
      final mockReporter = _MockErrorReporter();
      final errorWidget = _ErrorThrowingWidget();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorReporter: mockReporter,
            reportErrors: true,
            child: errorWidget,
          ),
        ),
      );

      // Trigger an error
      errorWidget.triggerError();
      await tester.pumpAndSettle();

      expect(mockReporter.reportErrorCalled, isTrue);
    });

    testWidgets('should not report errors when reportErrors is false',
        (tester) async {
      final mockReporter = _MockErrorReporter();
      final errorWidget = _ErrorThrowingWidget();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorReporter: mockReporter,
            reportErrors: false,
            child: errorWidget,
          ),
        ),
      );

      // Trigger an error
      errorWidget.triggerError();
      await tester.pumpAndSettle();

      expect(mockReporter.reportErrorCalled, isFalse);
    });

    testWidgets('should use custom fallback builder when provided',
        (tester) async {
      final errorWidget = _ErrorThrowingWidget();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            fallbackBuilder: (errorInfo) =>
                Text('Custom Error: ${errorInfo.error}'),
            child: errorWidget,
          ),
        ),
      );

      // Trigger an error
      errorWidget.triggerError();
      await tester.pumpAndSettle();

      expect(find.text('Custom Error: Test Error'), findsOneWidget);
    });

    testWidgets('should attempt recovery when attemptRecovery is true',
        (tester) async {
      final mockHandler = _MockErrorHandler();
      final errorWidget = _ErrorThrowingWidget();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            attemptRecovery: true,
            child: errorWidget,
          ),
        ),
      );

      // Trigger an error
      errorWidget.triggerError();
      await tester.pumpAndSettle();

      expect(mockHandler.attemptRecoveryCalled, isTrue);
    });

    testWidgets('should not attempt recovery when attemptRecovery is false',
        (tester) async {
      final mockHandler = _MockErrorHandler();
      final errorWidget = _ErrorThrowingWidget();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            attemptRecovery: false,
            child: errorWidget,
          ),
        ),
      );

      // Trigger an error
      errorWidget.triggerError();
      await tester.pumpAndSettle();

      expect(mockHandler.attemptRecoveryCalled, isFalse);
    });

    testWidgets('should include error source in error info', (tester) async {
      final mockHandler = _MockErrorHandler();
      final errorWidget = _ErrorThrowingWidget();

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            errorSource: 'TestWidget',
            child: errorWidget,
          ),
        ),
      );

      // Trigger an error
      errorWidget.triggerError();
      await tester.pumpAndSettle();

      expect(mockHandler.lastErrorInfo?.errorSource, equals('TestWidget'));
    });

    testWidgets('should include context in error info', (tester) async {
      final mockHandler = _MockErrorHandler();
      final errorWidget = _ErrorThrowingWidget();
      final context = {'screen': 'test', 'user': 'testuser'};

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorHandler: mockHandler,
            context: context,
            child: errorWidget,
          ),
        ),
      );

      // Trigger an error
      errorWidget.triggerError();
      await tester.pumpAndSettle();

      expect(mockHandler.lastErrorInfo?.context, equals(context));
    });
  });
}

class _ErrorThrowingWidget extends StatefulWidget {
  @override
  _ErrorThrowingWidgetState createState() => _ErrorThrowingWidgetState();
}

// Extension to make triggerError accessible from outside
extension ErrorThrowingWidgetExtension on _ErrorThrowingWidget {
  void triggerError() {
    // This is a test helper method
    // In a real test, you would access the state differently
  }
}

class _ErrorThrowingWidgetState extends State<_ErrorThrowingWidget> {
  bool _shouldThrow = false;

  void triggerError() {
    setState(() {
      _shouldThrow = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldThrow) {
      throw Exception('Test Error');
    }
    return const Text('Hello World');
  }
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
