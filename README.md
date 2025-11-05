# Flutter Error Boundary

A Flutter package that provides error boundary widgets to catch and handle errors gracefully in Flutter applications, preventing crashes and providing fallback UI when errors occur.

<img src="assets/example.gif" width="300" alt="Example">

## Features

- 🛡️ **Error Catching**: Catches errors in the widget tree and prevents app crashes
- 🎨 **Customizable Fallback UI**: Display custom error messages and recovery options
- 📊 **Error Reporting**: Built-in error reporting to external services
- ☁️ **Cloud Error Reporting**: Support for Sentry, Firebase Crashlytics, and custom HTTP endpoints
- 🔄 **Error Recovery**: Automatic and manual error recovery mechanisms
- 🎯 **Flexible Configuration**: Customizable error handling and reporting behavior
- 🧪 **Comprehensive Testing**: Full test coverage for reliability with platform compatibility tests
- 📱 **Platform Agnostic**: Tested and verified on Android, iOS, Web, Windows, macOS, and Linux
- 🚀 **Performance Optimized**: Benchmarked and verified minimal performance overhead (<50μs average widget creation, <2μs error handling)

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_error_boundary: ^0.0.5
```

### Basic Usage

Wrap any widget with an error boundary to catch errors:

```dart
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: MyWidget(),
    );
  }
}
```

### Advanced Usage

Create error boundaries with custom configurations:

```dart
ErrorBoundary(
  errorHandler: CustomErrorHandler(),
  errorReporter: CustomErrorReporter(),
  fallbackBuilder: (errorInfo) => CustomErrorWidget(errorInfo),
  reportErrors: true,
  attemptRecovery: true,
  errorSource: 'MyWidget',
  child: MyWidget(),
)
```

### Cloud Error Reporting

The package supports reporting errors to various cloud services:

#### Sentry Integration

```dart
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

final sentryReporter = SentryErrorReporter(
  dsn: 'https://your-sentry-dsn@sentry.io/project-id',
  projectId: 'your-project-id',
  environment: 'production',
  release: '1.0.0',
);

ErrorBoundary(
  errorReporter: sentryReporter,
  child: MyApp(),
)
```

#### Firebase Crashlytics Integration

```dart
final firebaseReporter = FirebaseCrashlyticsReporter(
  projectId: 'your-firebase-project-id',
  apiKey: 'your-firebase-api-key',
);

ErrorBoundary(
  errorReporter: firebaseReporter,
  child: MyApp(),
)
```

#### Custom HTTP Endpoint

```dart
final httpReporter = HttpErrorReporter(
  endpoint: 'https://api.example.com/errors',
  method: 'POST',
  headers: {'Authorization': 'Bearer token'},
  retryAttempts: 3,
);

ErrorBoundary(
  errorReporter: httpReporter,
  child: MyApp(),
)
```

#### Composite Reporting

Send errors to multiple services simultaneously:

```dart
final compositeReporter = CompositeErrorReporter(
  reporters: [sentryReporter, firebaseReporter, httpReporter],
  continueOnFailure: true,
  parallelReporting: true,
);

ErrorBoundary(
  errorReporter: compositeReporter,
  child: MyApp(),
)
```

#### Configuration Helpers

Use the provided configuration helpers for common setups:

```dart
// Production environment
final productionReporter = CloudErrorReporterConfig.createProductionReporter(
  sentryDsn: 'https://your-sentry-dsn@sentry.io/project-id',
  sentryProjectId: 'your-sentry-project-id',
  firebaseProjectId: 'your-firebase-project-id',
  firebaseApiKey: 'your-firebase-api-key',
);

// Development environment
final devReporter = CloudErrorReporterConfig.createDevelopmentReporter(
  httpEndpoint: 'http://localhost:3000/errors',
  includeConsole: true,
);

// Staging environment
final stagingReporter = CloudErrorReporterConfig.createStagingReporter(
  sentryDsn: 'https://your-sentry-dsn@sentry.io/project-id',
  sentryProjectId: 'your-sentry-project-id',
  httpEndpoint: 'https://staging-api.example.com/errors',
);
```

For detailed cloud error reporting documentation, see [CLOUD_ERROR_REPORTING.md](doc/CLOUD_ERROR_REPORTING.md).

### Using the Builder

The `ErrorBoundaryBuilder` provides convenient methods for common use cases:

```dart
// Simple error boundary
MyWidget().withSimpleErrorBoundary()

// Full-featured error boundary
MyWidget().withFullErrorBoundary(
  errorSource: 'MyWidget',
  context: {'screen': 'home'},
)

// Custom error boundary
ErrorBoundaryBuilder().wrap(
  child: MyWidget(),
  errorHandler: CustomErrorHandler(),
  fallbackBuilder: (errorInfo) => CustomErrorWidget(errorInfo),
)
```

## API Reference

### ErrorBoundary

The main widget that catches errors in its child widget tree.

#### Properties

- `child`: The widget below this widget in the tree
- `errorHandler`: The error handler to use when errors occur
- `errorReporter`: The error reporter to use for reporting errors
- `fallbackBuilder`: Builder function for creating the fallback UI
- `reportErrors`: Whether to report errors to external services
- `attemptRecovery`: Whether to attempt recovery from errors
- `errorSource`: Optional source identifier for the error boundary
- `context`: Additional context to include with error reports

### ErrorHandler

Interface for handling errors that occur within error boundaries.

#### Methods

- `handleError(ErrorInfo errorInfo)`: Handles an error
- `shouldReportError(ErrorInfo errorInfo)`: Determines if an error should be reported
- `shouldAttemptRecovery(ErrorInfo errorInfo)`: Determines if recovery should be attempted
- `attemptRecovery(ErrorInfo errorInfo)`: Attempts to recover from an error

### ErrorReporter

Interface for reporting errors to external services.

#### Methods

- `reportError(ErrorInfo errorInfo)`: Reports an error
- `reportErrorWithContext(ErrorInfo errorInfo, Map<String, dynamic> context)`: Reports an error with context
- `setUserIdentifier(String userId)`: Sets user identification
- `setUserProperties(Map<String, dynamic> properties)`: Sets user properties
- `clearUserData()`: Clears user data

### ErrorInfo

Information about an error for reporting and handling.

#### Properties

- `error`: The actual error that occurred
- `stackTrace`: The stack trace associated with the error
- `severity`: The severity level of the error
- `type`: The type of error that occurred
- `errorSource`: Optional source identifier
- `timestamp`: When the error occurred
- `context`: Additional context about the error
- `userData`: User-provided data associated with the error

## Error Types

The package defines several error types and severity levels:

### Error Types

- `build`: Build-time errors in widget construction
- `runtime`: Runtime errors during widget lifecycle
- `rendering`: Rendering errors in the widget tree
- `state`: State management errors
- `external`: Network or external service errors
- `unknown`: Unknown or unclassified errors

### Error Severity

- `low`: Non-critical errors that don't affect functionality
- `medium`: Errors that may affect some functionality
- `high`: Errors that significantly impact functionality
- `critical`: Errors that cause complete failure

## Examples

### Basic Error Boundary

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: Container(
        child: Text('This widget is protected by an error boundary'),
      ),
    );
  }
}
```

### Custom Fallback UI

```dart
ErrorBoundary(
  fallbackBuilder: (errorInfo) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red),
          Text('An error occurred: ${errorInfo.error}'),
          ElevatedButton(
            onPressed: () {
              // Handle retry logic
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  },
  child: MyWidget(),
)
```

### Custom Error Handler

```dart
class CustomErrorHandler implements ErrorHandler {
  @override
  Future<bool> handleError(ErrorInfo errorInfo) async {
    // Custom error handling logic
    print('Custom error handling: ${errorInfo.error}');
    return true;
  }

  @override
  bool shouldReportError(ErrorInfo errorInfo) {
    return errorInfo.severity == ErrorSeverity.high;
  }

  @override
  bool shouldAttemptRecovery(ErrorInfo errorInfo) {
    return errorInfo.type != ErrorType.critical;
  }

  @override
  Future<bool> attemptRecovery(ErrorInfo errorInfo) async {
    // Custom recovery logic
    return true;
  }
}
```

### Custom Error Reporter

```dart
class CustomErrorReporter implements ErrorReporter {
  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    // Send error to your analytics service
    await AnalyticsService.trackError(errorInfo);
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    await AnalyticsService.trackErrorWithContext(errorInfo, context);
  }

  @override
  void setUserIdentifier(String userId) {
    AnalyticsService.setUserId(userId);
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    AnalyticsService.setUserProperties(properties);
  }

  @override
  void clearUserData() {
    AnalyticsService.clearUserData();
  }
}
```

## Testing

The package includes comprehensive tests to ensure reliability:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run performance benchmarks
flutter test test/performance/error_boundary_performance_test.dart

# Run platform compatibility tests
flutter test test/platform/platform_compatibility_test.dart

# Run specific test files
flutter test test/error_boundary_test.dart
```

### Performance Benchmarks

The package includes performance benchmarks that verify minimal overhead:
- **Widget Creation**: <50μs average (1000 iterations, first iteration may have initialization overhead)
- **Error Handling**: <2μs average for error reporting
- **Memory Overhead**: <2μs per boundary instance (1000 boundaries created in ~1ms)

See `test/performance/error_boundary_performance_test.dart` for detailed benchmarks.

### Platform Compatibility

The package is tested and verified to work on all Flutter-supported platforms:
- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

See `test/platform/platform_compatibility_test.dart` for platform-specific tests.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please file an issue on the GitHub repository.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.
