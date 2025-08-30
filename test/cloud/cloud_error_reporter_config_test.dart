import 'package:flutter_error_boundary/src/cloud/cloud_error_reporters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudErrorReporterConfig', () {
    test('should create Sentry reporter with correct configuration', () {
      final reporter = CloudErrorReporterConfig.createSentryReporter(
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
      final reporter = CloudErrorReporterConfig.createFirebaseReporter(
        projectId: 'test-firebase-project',
        apiKey: 'test-api-key',
      );

      expect(reporter, isA<FirebaseCrashlyticsReporter>());
      expect(reporter.projectId, 'test-firebase-project');
      expect(reporter.apiKey, 'test-api-key');
    });

    test('should create HTTP reporter with correct configuration', () {
      final reporter = CloudErrorReporterConfig.createHttpReporter(
        endpoint: 'https://api.example.com/errors',
        method: 'PUT',
        headers: {'Authorization': 'Bearer token'},
        timeout: Duration(seconds: 60),
        retryAttempts: 5,
      );

      expect(reporter, isA<HttpErrorReporter>());
      expect(reporter.endpoint, 'https://api.example.com/errors');
      expect(reporter.method, 'PUT');
      expect(reporter.headers, {'Authorization': 'Bearer token'});
      expect(reporter.timeout, Duration(seconds: 60));
      expect(reporter.retryAttempts, 5);
    });

    test('should create production reporter with Sentry and Firebase', () {
      final reporter = CloudErrorReporterConfig.createProductionReporter(
        sentryDsn: 'https://key:secret@sentry.io/project-id',
        sentryProjectId: 'test-sentry-project',
        firebaseProjectId: 'test-firebase-project',
        firebaseApiKey: 'test-firebase-api-key',
        environment: 'production',
        release: '2.0.0',
        continueOnFailure: false,
        parallelReporting: false,
      );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 2);
      expect(reporter.continueOnFailure, false);
      expect(reporter.parallelReporting, false);

      final reporters = reporter.reporters;
      expect(reporters[0], isA<SentryErrorReporter>());
      expect(reporters[1], isA<FirebaseCrashlyticsReporter>());
    });

    test('should create development reporter with console logging', () {
      final reporter = CloudErrorReporterConfig.createDevelopmentReporter(
        includeConsole: true,
      );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 1);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, false);
    });

    test('should create development reporter with HTTP endpoint', () {
      final reporter = CloudErrorReporterConfig.createDevelopmentReporter(
        httpEndpoint: 'http://localhost:3000/errors',
        httpHeaders: {'X-Environment': 'development'},
        includeConsole: true,
      );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 2);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, false);
    });

    test('should create development reporter without console logging', () {
      final reporter = CloudErrorReporterConfig.createDevelopmentReporter(
        httpEndpoint: 'http://localhost:3000/errors',
        includeConsole: false,
      );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 1);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, false);
    });

    test('should create staging reporter with Sentry and HTTP', () {
      final reporter = CloudErrorReporterConfig.createStagingReporter(
        sentryDsn: 'https://key:secret@sentry.io/project-id',
        sentryProjectId: 'test-sentry-project',
        httpEndpoint: 'https://staging-api.example.com/errors',
        httpHeaders: {'X-Environment': 'staging'},
        environment: 'staging',
        release: '1.0.0-beta',
      );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 2);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, true);

      final reporters = reporter.reporters;
      expect(reporters[0], isA<SentryErrorReporter>());
      expect(reporters[1], isA<HttpErrorReporter>());
    });

    test('should create staging reporter with only Sentry', () {
      final reporter = CloudErrorReporterConfig.createStagingReporter(
        sentryDsn: 'https://key:secret@sentry.io/project-id',
        sentryProjectId: 'test-sentry-project',
        environment: 'staging',
      );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 1);
      expect(reporter.continueOnFailure, true);
      expect(reporter.parallelReporting, true);

      final reporters = reporter.reporters;
      expect(reporters[0], isA<SentryErrorReporter>());
    });

    test('should create custom reporter with specified reporters', () {
      final sentryReporter = CloudErrorReporterConfig.createSentryReporter(
        dsn: 'https://key:secret@sentry.io/project-id',
        projectId: 'test-project',
      );

      final httpReporter = CloudErrorReporterConfig.createHttpReporter(
        endpoint: 'https://api.example.com/errors',
      );

      final reporter = CloudErrorReporterConfig.createCustomReporter(
        reporters: [sentryReporter, httpReporter],
        continueOnFailure: false,
        parallelReporting: false,
      );

      expect(reporter, isA<CompositeErrorReporter>());
      expect(reporter.reporterCount, 2);
      expect(reporter.continueOnFailure, false);
      expect(reporter.parallelReporting, false);

      final reporters = reporter.reporters;
      expect(reporters[0], isA<SentryErrorReporter>());
      expect(reporters[1], isA<HttpErrorReporter>());
    });

    test('should use default values for optional parameters', () {
      final reporter = CloudErrorReporterConfig.createSentryReporter(
        dsn: 'https://key:secret@sentry.io/project-id',
        projectId: 'test-project',
      );

      expect(reporter.environment, 'production');
      expect(reporter.release, isNull);
      expect(reporter.serverName, isNull);
    });

    test('should use default values for HTTP reporter', () {
      final reporter = CloudErrorReporterConfig.createHttpReporter(
        endpoint: 'https://api.example.com/errors',
      );

      expect(reporter.method, 'POST');
      expect(reporter.headers, isEmpty);
      expect(reporter.timeout, Duration(seconds: 30));
      expect(reporter.retryAttempts, 3);
    });

    test('should use default values for production reporter', () {
      final reporter = CloudErrorReporterConfig.createProductionReporter(
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
