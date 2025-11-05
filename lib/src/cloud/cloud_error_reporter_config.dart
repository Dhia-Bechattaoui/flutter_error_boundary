// Configuration helper for cloud error reporters in the Flutter Error Boundary package.

import '../error_reporter.dart';
import 'cloud_error_reporters.dart';
import 'console_error_reporter.dart';

/// Configuration helper for setting up cloud error reporters.
class CloudErrorReporterConfig {
  /// Creates a new configuration helper.
  const CloudErrorReporterConfig._();

  /// Creates a Sentry error reporter with common configuration.
  static SentryErrorReporter createSentryReporter({
    required String dsn,
    required String projectId,
    String environment = 'production',
    String? release,
    String? serverName,
  }) => SentryErrorReporter(
    dsn: dsn,
    projectId: projectId,
    environment: environment,
    release: release,
    serverName: serverName,
  );

  /// Creates a Firebase Crashlytics reporter with common configuration.
  static FirebaseCrashlyticsReporter createFirebaseReporter({
    required String projectId,
    required String apiKey,
  }) => FirebaseCrashlyticsReporter(projectId: projectId, apiKey: apiKey);

  /// Creates an HTTP error reporter with common configuration.
  static HttpErrorReporter createHttpReporter({
    required String endpoint,
    String method = 'POST',
    Map<String, String> headers = const <String, String>{},
    Duration timeout = const Duration(seconds: 30),
    int retryAttempts = 3,
  }) => HttpErrorReporter(
    endpoint: endpoint,
    method: method,
    headers: headers,
    timeout: timeout,
    retryAttempts: retryAttempts,
  );

  /// Creates a composite reporter with Sentry and Firebase.
  static CompositeErrorReporter createProductionReporter({
    required String sentryDsn,
    required String sentryProjectId,
    required String firebaseProjectId,
    required String firebaseApiKey,
    String environment = 'production',
    String? release,
    bool continueOnFailure = true,
    bool parallelReporting = true,
  }) {
    final SentryErrorReporter sentryReporter = createSentryReporter(
      dsn: sentryDsn,
      projectId: sentryProjectId,
      environment: environment,
      release: release,
    );

    final FirebaseCrashlyticsReporter firebaseReporter = createFirebaseReporter(
      projectId: firebaseProjectId,
      apiKey: firebaseApiKey,
    );

    return CompositeErrorReporter(
      reporters: <ErrorReporter>[sentryReporter, firebaseReporter],
      continueOnFailure: continueOnFailure,
      parallelReporting: parallelReporting,
    );
  }

  /// Creates a development reporter with console logging and optional HTTP endpoint.
  static CompositeErrorReporter createDevelopmentReporter({
    String? httpEndpoint,
    Map<String, String> httpHeaders = const <String, String>{},
    bool includeConsole = true,
  }) {
    final List<ErrorReporter> reporters = <ErrorReporter>[];

    if (includeConsole) {
      reporters.add(const ConsoleErrorReporter());
    }

    if (httpEndpoint != null) {
      final HttpErrorReporter httpReporter = createHttpReporter(
        endpoint: httpEndpoint,
        headers: httpHeaders,
        retryAttempts: 1, // Fewer retries in development
      );
      reporters.add(httpReporter);
    }

    return CompositeErrorReporter(
      reporters: reporters,
      parallelReporting:
          false, // Sequential in development for easier debugging
    );
  }

  /// Creates a staging reporter with Sentry and HTTP endpoint.
  static CompositeErrorReporter createStagingReporter({
    required String sentryDsn,
    required String sentryProjectId,
    String? httpEndpoint,
    Map<String, String> httpHeaders = const <String, String>{},
    String environment = 'staging',
    String? release,
  }) {
    final List<ErrorReporter> reporters = <ErrorReporter>[];

    final SentryErrorReporter sentryReporter = createSentryReporter(
      dsn: sentryDsn,
      projectId: sentryProjectId,
      environment: environment,
      release: release,
    );
    reporters.add(sentryReporter);

    if (httpEndpoint != null) {
      final HttpErrorReporter httpReporter = createHttpReporter(
        endpoint: httpEndpoint,
        headers: httpHeaders,
        retryAttempts: 2,
      );
      reporters.add(httpReporter);
    }

    return CompositeErrorReporter(reporters: reporters);
  }

  /// Creates a custom composite reporter with specified reporters.
  static CompositeErrorReporter createCustomReporter({
    required List<ErrorReporter> reporters,
    bool continueOnFailure = true,
    bool parallelReporting = true,
  }) => CompositeErrorReporter(
    reporters: reporters,
    continueOnFailure: continueOnFailure,
    parallelReporting: parallelReporting,
  );
}
