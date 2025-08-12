import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

void main() {
  group('ErrorFallback', () {
    late ErrorInfo errorInfo;

    setUp(() {
      errorInfo = ErrorInfo(
        error: Exception('Test error message'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.high,
        type: ErrorType.runtime,
        errorSource: 'TestWidget',
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        context: {'screen': 'test'},
        userData: {'userId': '123'},
      );
    });

    testWidgets('should display error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(errorInfo: errorInfo),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(errorInfo: errorInfo),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should not show error details by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(errorInfo: errorInfo),
        ),
      );

      expect(find.text('Error Details:'), findsNothing);
      expect(find.text('Type: runtime'), findsNothing);
      expect(find.text('Severity: high'), findsNothing);
    });

    testWidgets('should show error details when showDetails is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(
            errorInfo: errorInfo,
            showDetails: true,
          ),
        ),
      );

      expect(find.text('Error Details:'), findsOneWidget);
      expect(find.text('Type: runtime'), findsOneWidget);
      expect(find.text('Severity: high'), findsOneWidget);
      expect(find.text('Source: TestWidget'), findsOneWidget);
      expect(find.text('Time: 2024-01-01 12:00:00.000'), findsOneWidget);
    });

    testWidgets('should show retry button when onRetry is provided',
        (tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(
            errorInfo: errorInfo,
            onRetry: () => retryCalled = true,
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryCalled, isTrue);
    });

    testWidgets('should not show retry button when onRetry is not provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(errorInfo: errorInfo),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('should show report button when onReport is provided',
        (tester) async {
      bool reportCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(
            errorInfo: errorInfo,
            onReport: () => reportCalled = true,
          ),
        ),
      );

      expect(find.text('Report'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);

      await tester.tap(find.text('Report'));
      expect(reportCalled, isTrue);
    });

    testWidgets('should not show report button when onReport is not provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(errorInfo: errorInfo),
        ),
      );

      expect(find.text('Report'), findsNothing);
    });

    testWidgets(
        'should show both retry and report buttons when both callbacks are provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(
            errorInfo: errorInfo,
            onRetry: () {},
            onReport: () {},
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('should handle null error source gracefully', (tester) async {
      final errorInfoWithoutSource = ErrorInfo(
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.medium,
        type: ErrorType.unknown,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(
            errorInfo: errorInfoWithoutSource,
            showDetails: true,
          ),
        ),
      );

      expect(find.text('Source: TestWidget'), findsNothing);
    });

    testWidgets('should handle null timestamp gracefully', (tester) async {
      final errorInfoWithoutTimestamp = ErrorInfo(
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.medium,
        type: ErrorType.unknown,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallback(
            errorInfo: errorInfoWithoutTimestamp,
            showDetails: true,
          ),
        ),
      );

      expect(find.text('Time:'), findsNothing);
    });
  });

  group('ErrorDisplay', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorDisplay(message: 'Test error message'),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('should display default error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorDisplay(message: 'Test error message'),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorDisplay(
            message: 'Test error message',
            icon: Icons.warning,
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should use default color when no color is specified',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorDisplay(message: 'Test error message'),
        ),
      );

      // The default color should be applied
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should use custom color when specified', (tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorDisplay(
            message: 'Test error message',
            color: customColor,
          ),
        ),
      );

      // The custom color should be applied
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should center content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorDisplay(message: 'Test error message'),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should arrange icon and text vertically', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorDisplay(message: 'Test error message'),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
    });
  });
}
