import 'package:flutter_error_boundary/src/cloud/sentry_error_reporter.dart';
import 'package:flutter_error_boundary/src/error_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sentry_error_reporter_test.mocks.dart';

@GenerateMocks([http.Client, http.Response])
void main() {
  group('SentryErrorReporter', () {
    late MockClient mockHttpClient;
    late MockResponse mockResponse;
    late SentryErrorReporter reporter;

    setUp(() {
      mockHttpClient = MockClient();
      mockResponse = MockResponse();
      reporter = SentryErrorReporter(
        dsn: 'https://key:secret@sentry.io/project-id',
        projectId: 'project-id',
        httpClient: mockHttpClient,
      );
    });

    tearDown(() {
      reporter.dispose();
    });

    test('should create with correct configuration', () {
      expect(reporter.dsn, 'https://key:secret@sentry.io/project-id');
      expect(reporter.projectId, 'project-id');
      expect(reporter.environment, 'production');
      expect(reporter.release, isNull);
      expect(reporter.serverName, isNull);
    });

    test('should create with custom configuration', () {
      final customReporter = SentryErrorReporter(
        dsn: 'https://key:secret@sentry.io/project-id',
        projectId: 'project-id',
        environment: 'staging',
        release: '1.0.0',
        serverName: 'test-server',
      );

      expect(customReporter.environment, 'staging');
      expect(customReporter.release, '1.0.0');
      expect(customReporter.serverName, 'test-server');
    });

    test('should report error successfully', () async {
      when(mockResponse.statusCode).thenReturn(200);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      final errorInfo = ErrorInfo(
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.high,
        type: ErrorType.runtime,
        timestamp: DateTime(2024, 1, 1),
        errorSource: 'test',
      );

      await reporter.reportError(errorInfo);

      verify(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);
    });

    test('should report error with context', () async {
      when(mockResponse.statusCode).thenReturn(200);
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      final errorInfo = ErrorInfo(
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.high,
        type: ErrorType.runtime,
        timestamp: DateTime(2024, 1, 1),
        errorSource: 'test',
      );

      final context = {'screen': 'TestScreen', 'action': 'test'};

      await reporter.reportErrorWithContext(errorInfo, context);

      verify(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);
    });

    test('should handle HTTP error responses', () async {
      when(mockResponse.statusCode).thenReturn(500);
      when(mockResponse.body).thenReturn('Internal Server Error');
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => mockResponse);

      final errorInfo = ErrorInfo(
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.high,
        type: ErrorType.runtime,
      );

      // Should not throw
      await reporter.reportError(errorInfo);

      verify(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);
    });

    test('should handle HTTP client errors gracefully', () async {
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('Network error'));

      final errorInfo = ErrorInfo(
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.high,
        type: ErrorType.runtime,
      );

      // Should not throw
      await reporter.reportError(errorInfo);

      verify(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);
    });

    test('should set and clear user data', () {
      reporter.setUserIdentifier('user-123');
      reporter.setUserProperties({'email': 'test@example.com'});

      // Clear user data
      reporter.clearUserData();

      // Should not throw
      expect(() => reporter.setUserIdentifier('new-user'), returnsNormally);
    });

    test('should handle user data operations', () {
      reporter.setUserIdentifier('user-123');
      reporter.setUserProperties({'email': 'test@example.com'});

      // Clear user data
      reporter.clearUserData();

      // Should not throw
      expect(() => reporter.setUserIdentifier('new-user'), returnsNormally);
    });
  });
}
