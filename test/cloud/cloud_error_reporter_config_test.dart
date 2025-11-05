import 'package:flutter_error_boundary/src/cloud/cloud_error_reporters.dart';
import 'package:flutter_error_boundary/src/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudErrorReporterConfig', () {
    test('should create Sentry reporter with correct configuration', () {
      final SentryErrorReporter reporter =
          CloudErrorReporterConfig.createSentryReporter(
            dsn: 'https://key:secret@sentry.io/project-id',
            projectId: 'test-project',
            environment: 'staging',
            release: '1.0.0',
            serverName: 'test-server',
          );

      expect(reporter, isA<SentryErrorReporter>());
      expect(reporter.dsn, 'https://key:secret@sentry.io/project-id');
      expect(reporter.projectId, 'test-project');
      expect(reporter.environment, 'staging');
      expect(reporter.release, '1.0.0');
      expect(reporter.serverName, 'test-server');
    });

    test('should create Firebase reporter with correct configuration', () {
      final FirebaseCrashlyticsReporter reporter =
          CloudErrorReporterConfig.createFirebaseReporter(
            projectId: 'test-firebase-project',
            apiKey: 'test-api-key',
          );

      expect(reporter, isA<FirebaseCrashlyticsReporter>());
      expect(reporter.projectId, 'test-firebase-project');
      expect(reporter.apiKey, 'test-api-key');
    });

    test('should create HTTP reporter with correct configuration', () {
      final HttpErrorReporter reporter =
          CloudErrorReporterConfig.createHttpReporter(
            endpoint: 'https://api.example.com/errors',
            method: 'PUT',
            headers: <String, String>{'Authorization': 'Bearer token'},
            timeout: const Duration(seconds: 60),
            retryAttempts: 5,
          );

      expect(reporter, isA<HttpErrorReporter>());
      expect(reporter.endpoint, 'https://api.example.com/errors');
      expect(reporter.method, 'PUT');
      expect(reporter.headers, <String, String>{
        'Authorization': 'Bearer token',
      });
      expect(reporter.timeout, const Duration(seconds: 60));
      expect(reporter.retryAttempts, 5);
    });

    test('should create production reporter with Sentry and Firebase', () {
      final CompositeErrorReporter reporter =
          CloudErrorReporterConfig.createProductionReporter(
            sentryDsn: 'https://key:secret@sentry.io/project-id',
            sentryProjectId: 'test-sentry-project',
            firebaseProjectId: 'test-firebase-project',
            firebaseApiKey: 'test-firebase-api-key',
            release: '2.0.0',
            continueOnFailure: false,
            parallelReporting: false,
          );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 2);
      expect(reporter.continueOnFailure, false);
      expect(reporter.parallelReporting, false);

      final List<ErrorReporter> reporters = reporter.reporters;
      expect(reporters[0], isA<SentryErrorReporter>());
      expect(reporters[1], isA<FirebaseCrashlyticsReporter>());
    });

    test('should create development reporter with console logging', () {
      final CompositeErrorReporter reporter =
          CloudErrorReporterConfig.createDevelopmentReporter();

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 1);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, false);
    });

    test('should create development reporter with HTTP endpoint', () {
      final CompositeErrorReporter reporter =
          CloudErrorReporterConfig.createDevelopmentReporter(
            httpEndpoint: 'http://localhost:3000/errors',
            httpHeaders: <String, String>{'X-Environment': 'development'},
          );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 2);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, false);
    });

    test('should create development reporter without console logging', () {
      final CompositeErrorReporter reporter =
          CloudErrorReporterConfig.createDevelopmentReporter(
            httpEndpoint: 'http://localhost:3000/errors',
            includeConsole: false,
          );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 1);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, false);
    });

    test('should create staging reporter with Sentry and HTTP', () {
      final CompositeErrorReporter reporter =
          CloudErrorReporterConfig.createStagingReporter(
            sentryDsn: 'https://key:secret@sentry.io/project-id',
            sentryProjectId: 'test-sentry-project',
            httpEndpoint: 'https://staging-api.example.com/errors',
            httpHeaders: <String, String>{'X-Environment': 'staging'},
            release: '1.0.0-beta',
          );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 2);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, true);

      final List<ErrorReporter> reporters = reporter.reporters;
      expect(reporters[0], isA<SentryErrorReporter>());
      expect(reporters[1], isA<HttpErrorReporter>());
    });

    test('should create staging reporter with only Sentry', () {
      final CompositeErrorReporter reporter =
          CloudErrorReporterConfig.createStagingReporter(
            sentryDsn: 'https://key:secret@sentry.io/project-id',
            sentryProjectId: 'test-sentry-project',
          );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 1);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, true);

      final List<ErrorReporter> reporters = reporter.reporters;
      expect(reporters[0], isA<SentryErrorReporter>());
    });

    test('should create custom reporter with specified reporters', () {
      final SentryErrorReporter sentryReporter =
          CloudErrorReporterConfig.createSentryReporter(
            dsn: 'https://key:secret@sentry.io/project-id',
            projectId: 'test-project',
          );

      final HttpErrorReporter httpReporter =
          CloudErrorReporterConfig.createHttpReporter(
            endpoint: 'https://api.example.com/errors',
          );

      final CompositeErrorReporter reporter =
          CloudErrorReporterConfig.createCustomReporter(
            reporters: <ErrorReporter>[sentryReporter, httpReporter],
            continueOnFailure: false,
            parallelReporting: false,
          );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 2);
      expect(reporter.continueOnFailure, false);
      expect(reporter.parallelReporting, false);

      final List<ErrorReporter> reporters = reporter.reporters;
      expect(reporters[0], isA<SentryErrorReporter>());
      expect(reporters[1], isA<HttpErrorReporter>());
    });

    test('should use default values for optional parameters', () {
      final SentryErrorReporter reporter =
          CloudErrorReporterConfig.createSentryReporter(
            dsn: 'https://key:secret@sentry.io/project-id',
            projectId: 'test-project',
          );

      expect(reporter.environment, 'production');
      expect(reporter.release, isNull);
      expect(reporter.serverName, isNull);
    });

    test('should use default values for HTTP reporter', () {
      final HttpErrorReporter reporter =
          CloudErrorReporterConfig.createHttpReporter(
            endpoint: 'https://api.example.com/errors',
          );

      expect(reporter.method, 'POST');
      expect(reporter.headers, isEmpty);
      expect(reporter.timeout, const Duration(seconds: 30));
      expect(reporter.retryAttempts, 3);
    });

    test('should use default values for production reporter', () {
      final CompositeErrorReporter reporter =
          CloudErrorReporterConfig.createProductionReporter(
            sentryDsn: 'https://key:secret@sentry.io/project-id',
            sentryProjectId: 'test-sentry-project',
            firebaseProjectId: 'test-firebase-project',
            firebaseApiKey: 'test-firebase-api-key',
          );

      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, true);
    });
  });
}
