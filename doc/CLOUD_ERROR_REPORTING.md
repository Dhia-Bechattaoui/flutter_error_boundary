# Cloud Error Reporting

The Flutter Error Boundary package now supports reporting errors to various cloud services, making it easy to monitor and track errors in production applications.

## Supported Services

- **Sentry** - Error tracking and performance monitoring
- **Firebase Crashlytics** - Crash reporting and analytics
- **Custom HTTP Endpoints** - Send errors to any HTTP service
- **Composite Reporting** - Send to multiple services simultaneously

## Quick Start

### 1. Add Dependencies

Make sure you have the HTTP package in your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
```

### 2. Basic Setup

```dart
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

// Create a Sentry reporter
final sentryReporter = SentryErrorReporter(
  dsn: 'https://your-sentry-dsn@sentry.io/project-id',
  projectId: 'your-project-id',
  environment: 'production',
);

// Use it with your error boundary
ErrorBoundary(
  errorReporter: sentryReporter,
  child: YourApp(),
)
```

## Configuration Helpers

The package provides convenient configuration helpers for common setups:

### Production Environment

```dart
final productionReporter = CloudErrorReporterConfig.createProductionReporter(
  sentryDsn: 'https://your-sentry-dsn@sentry.io/project-id',
  sentryProjectId: 'your-sentry-project-id',
  firebaseProjectId: 'your-firebase-project-id',
  firebaseApiKey: 'your-firebase-api-key',
  environment: 'production',
  release: '1.0.0',
);
```

### Development Environment

```dart
final devReporter = CloudErrorReporterConfig.createDevelopmentReporter(
  httpEndpoint: 'http://localhost:3000/errors',
  includeConsole: true,
);
```

### Staging Environment

```dart
final stagingReporter = CloudErrorReporterConfig.createStagingReporter(
  sentryDsn: 'https://your-sentry-dsn@sentry.io/project-id',
  sentryProjectId: 'your-sentry-project-id',
  httpEndpoint: 'https://staging-api.example.com/errors',
  environment: 'staging',
);
```

## Individual Reporters

### Sentry Reporter

```dart
final sentryReporter = SentryErrorReporter(
  dsn: 'https://your-sentry-dsn@sentry.io/project-id',
  projectId: 'your-project-id',
  environment: 'production',
  release: '1.0.0',
  serverName: 'production-server',
);

// Set user information
sentryReporter.setUserIdentifier('user-123');
sentryReporter.setUserProperties({
  'email': 'user@example.com',
  'plan': 'premium',
});
```

### Firebase Crashlytics Reporter

```dart
final firebaseReporter = FirebaseCrashlyticsReporter(
  projectId: 'your-firebase-project-id',
  apiKey: 'your-firebase-api-key',
);

// Set user information
firebaseReporter.setUserIdentifier('user-123');
firebaseReporter.setUserProperties({
  'email': 'user@example.com',
  'plan': 'premium',
});
```

### HTTP Reporter

```dart
final httpReporter = HttpErrorReporter(
  endpoint: 'https://api.example.com/errors',
  method: 'POST',
  headers: {
    'Authorization': 'Bearer your-api-token',
    'X-API-Version': '1.0',
  },
  timeout: Duration(seconds: 30),
  retryAttempts: 3,
  retryDelay: Duration(seconds: 1),
);
```

## Composite Reporting

Send errors to multiple services simultaneously:

```dart
final compositeReporter = CompositeErrorReporter(
  reporters: [
    sentryReporter,
    firebaseReporter,
    httpReporter,
  ],
  continueOnFailure: true,  // Continue if one service fails
  parallelReporting: true,   // Send to all services in parallel
);

// Add or remove reporters dynamically
final newComposite = compositeReporter
  .addReporter(anotherReporter)
  .removeReporter(httpReporter);
```

## User Context

All reporters support user identification and properties:

```dart
// Set user identifier
errorReporter.setUserIdentifier('user-123');

// Set user properties
errorReporter.setUserProperties({
  'email': 'user@example.com',
  'plan': 'premium',
  'lastLogin': DateTime.now().toIso8601String(),
});

// Clear user data
errorReporter.clearUserData();
```

## Error Context

Add additional context when reporting errors:

```dart
// Report with additional context
await errorReporter.reportErrorWithContext(
  errorInfo,
  {
    'screen': 'UserProfile',
    'action': 'save_profile',
    'userId': 'user-123',
    'formData': {'name': 'John Doe'},
  },
);
```

## Custom Error Payloads

The HTTP reporter allows you to customize the error payload format:

```dart
final customHttpReporter = HttpErrorReporter(
  endpoint: 'https://api.example.com/errors',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your-token',
  },
);
```

The reporter will send a JSON payload with this structure:

```json
{
  "error": {
    "type": "Exception",
    "message": "Error message",
    "stackTrace": "Stack trace...",
    "severity": "high",
    "errorType": "runtime",
    "errorSource": "UserProfile",
    "timestamp": "2024-01-01T12:00:00Z"
  },
  "context": {
    "screen": "UserProfile",
    "action": "save_profile"
  },
  "user": {
    "id": "user-123",
    "properties": {
      "email": "user@example.com",
      "plan": "premium"
    }
  },
  "metadata": {
    "platform": "flutter",
    "package": "flutter_error_boundary",
    "version": "1.0.0"
  }
}
```

## Error Handling and Retries

The HTTP reporter includes built-in retry logic:

```dart
final resilientReporter = HttpErrorReporter(
  endpoint: 'https://api.example.com/errors',
  retryAttempts: 5,
  retryDelay: Duration(seconds: 2),
  timeout: Duration(seconds: 60),
);
```

## Environment-Specific Configuration

```dart
class ErrorReportingConfig {
  static ErrorReporter getReporter() {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    
    switch (environment) {
      case 'production':
        return CloudErrorReporterConfig.createProductionReporter(
          sentryDsn: 'https://prod-sentry-dsn@sentry.io/project-id',
          sentryProjectId: 'prod-project-id',
          firebaseProjectId: 'prod-firebase-project-id',
          firebaseApiKey: 'prod-firebase-api-key',
        );
        
      case 'staging':
        return CloudErrorReporterConfig.createStagingReporter(
          sentryDsn: 'https://staging-sentry-dsn@sentry.io/project-id',
          sentryProjectId: 'staging-project-id',
          httpEndpoint: 'https://staging-api.example.com/errors',
        );
        
      default:
        return CloudErrorReporterConfig.createDevelopmentReporter(
          httpEndpoint: 'http://localhost:3000/errors',
        );
    }
  }
}

// Usage
ErrorBoundary(
  errorReporter: ErrorReportingConfig.getReporter(),
  child: YourApp(),
)
```

## Best Practices

1. **Environment Variables**: Store sensitive configuration in environment variables
2. **User Privacy**: Be careful with user data in error reports
3. **Rate Limiting**: Consider implementing rate limiting for error reporting
4. **Error Filtering**: Filter out sensitive or non-actionable errors
5. **Monitoring**: Monitor your error reporting services for failures
6. **Testing**: Test error reporting in development environments

## Troubleshooting

### Common Issues

1. **HTTP 401/403**: Check API keys and authentication
2. **HTTP 429**: Implement rate limiting or reduce error frequency
3. **Network Timeouts**: Increase timeout values for slow networks
4. **Large Payloads**: Consider truncating stack traces for very large errors

### Debug Mode

Enable debug logging in development:

```dart
final debugReporter = HttpErrorReporter(
  endpoint: 'https://api.example.com/errors',
  headers: {
    'X-Debug': 'true',
    'X-Environment': 'development',
  },
);
```

## Migration from Default Reporter

If you're currently using the default reporter:

```dart
// Before
ErrorBoundary(
  errorReporter: const DefaultErrorReporter(),
  child: YourApp(),
)

// After - Add cloud reporting while keeping console logging
final compositeReporter = CompositeErrorReporter(
  reporters: [
    const DefaultErrorReporter(),  // Keep console logging
    sentryReporter,               // Add Sentry
  ],
);

ErrorBoundary(
  errorReporter: compositeReporter,
  child: YourApp(),
)
```

This approach ensures you maintain existing functionality while adding cloud error reporting capabilities.
