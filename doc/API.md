# Flutter Error Boundary API Documentation

## Overview

The `flutter_error_boundary` package provides a comprehensive error handling system for Flutter applications. It includes error boundary widgets, error handlers, error reporters, and utility classes to catch and handle errors gracefully.

## Core Classes

### ErrorBoundary

The main widget that catches errors in its child widget tree and displays a fallback UI.

#### Constructor

```dart
const ErrorBoundary({
  super.key,
  required Widget child,
  ErrorHandler? errorHandler,
  ErrorReporter? errorReporter,
  Widget Function(ErrorInfo)? fallbackBuilder,
  bool reportErrors = true,
  bool attemptRecovery = true,
  String? errorSource,
  Map<String, dynamic>? context,
})
```

#### Properties

- `child`: The widget below this widget in the tree
- `errorHandler`: The error handler to use when errors occur (defaults to `DefaultErrorHandler`)
- `errorReporter`: The error reporter to use for reporting errors (defaults to `DefaultErrorReporter`)
- `fallbackBuilder`: Builder function for creating the fallback UI when an error occurs
- `reportErrors`: Whether to report errors to external services (defaults to `true`)
- `attemptRecovery`: Whether to attempt recovery from errors (defaults to `true`)
- `errorSource`: Optional source identifier for the error boundary
- `context`: Additional context to include with error reports

#### Usage

```dart
ErrorBoundary(
  errorSource: 'MyWidget',
  context: {'screen': 'home'},
  child: MyWidget(),
)
```

### ErrorBoundaryBuilder

A builder class that provides convenient methods for creating error boundaries with common configurations.

#### Methods

##### wrap()

Creates an error boundary with custom configuration.

```dart
ErrorBoundaryBuilder().wrap(
  child: MyWidget(),
  errorHandler: CustomErrorHandler(),
  errorReporter: CustomErrorReporter(),
  fallbackBuilder: (errorInfo) => CustomErrorWidget(errorInfo),
  reportErrors: true,
  attemptRecovery: true,
  errorSource: 'MyWidget',
  context: {'screen': 'home'},
)
```

##### withHandler()

Creates an error boundary with a custom error handler.

```dart
ErrorBoundaryBuilder().withHandler(
  child: MyWidget(),
  errorHandler: CustomErrorHandler(),
)
```

##### withReporter()

Creates an error boundary with a custom error reporter.

```dart
ErrorBoundaryBuilder().withReporter(
  child: MyWidget(),
  errorReporter: CustomErrorReporter(),
)
```

##### withFallback()

Creates an error boundary with a custom fallback builder.

```dart
ErrorBoundaryBuilder().withFallback(
  child: MyWidget(),
  fallbackBuilder: (errorInfo) => CustomErrorWidget(errorInfo),
)
```

##### simple()

Creates a simple error boundary with minimal configuration.

```dart
ErrorBoundaryBuilder().simple(child: MyWidget())
```

##### full()

Creates a full-featured error boundary with all error handling and reporting enabled.

```dart
ErrorBoundaryBuilder().full(
  child: MyWidget(),
  errorSource: 'MyWidget',
  context: {'screen': 'home'},
)
```

### Extension Methods

The package provides extension methods on `Widget` for easier error boundary creation.

#### withErrorBoundary()

Wraps a widget with an error boundary.

```dart
MyWidget().withErrorBoundary(
  errorHandler: CustomErrorHandler(),
  errorReporter: CustomErrorReporter(),
  reportErrors: true,
  attemptRecovery: true,
  errorSource: 'MyWidget',
  context: {'screen': 'home'},
)
```

#### withSimpleErrorBoundary()

Wraps a widget with a simple error boundary.

```dart
MyWidget().withSimpleErrorBoundary()
```

#### withFullErrorBoundary()

Wraps a widget with a full-featured error boundary.

```dart
MyWidget().withFullErrorBoundary(
  errorSource: 'MyWidget',
  context: {'screen': 'home'},
)
```

## Error Handling

### ErrorHandler Interface

Interface for handling errors that occur within error boundaries.

#### Methods

- `handleError(ErrorInfo errorInfo)`: Handles an error and returns success status
- `shouldReportError(ErrorInfo errorInfo)`: Determines if an error should be reported
- `shouldAttemptRecovery(ErrorInfo errorInfo)`: Determines if recovery should be attempted
- `attemptRecovery(ErrorInfo errorInfo)`: Attempts to recover from an error

### DefaultErrorHandler

Default implementation of the error handler with configurable behavior.

#### Constructor

```dart
const DefaultErrorHandler({
  this.reportAllErrors = false,
  this.attemptRecoveryForAll = false,
  this.maxRecoveryAttempts = 3,
})
```

#### Properties

- `reportAllErrors`: Whether to report all errors to external services
- `attemptRecoveryForAll`: Whether to attempt recovery for all errors
- `maxRecoveryAttempts`: Maximum number of recovery attempts for the same error

#### Custom Implementation

```dart
class CustomErrorHandler implements ErrorHandler {
  @override
  Future<bool> handleError(ErrorInfo errorInfo) async {
    // Custom error handling logic
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

## Error Reporting

### ErrorReporter Interface

Interface for reporting errors to external services.

#### Methods

- `reportError(ErrorInfo errorInfo)`: Reports an error
- `reportErrorWithContext(ErrorInfo errorInfo, Map<String, dynamic> context)`: Reports an error with context
- `setUserIdentifier(String userId)`: Sets user identification
- `setUserProperties(Map<String, dynamic> properties)`: Sets user properties
- `clearUserData()`: Clears user data

### DefaultErrorReporter

Default implementation of the error reporter with configurable options.

#### Constructor

```dart
DefaultErrorReporter({
  this.enabled = true,
  this.includeStackTrace = true,
  this.includeUserData = false,
})
```

#### Properties

- `enabled`: Whether error reporting is enabled
- `includeStackTrace`: Whether to include stack traces in error reports
- `includeUserData`: Whether to include user data in error reports

#### Custom Implementation

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

### NoOpErrorReporter

No-operation implementation for testing or when reporting is disabled.

```dart
const NoOpErrorReporter()
```

## Error Types

### ErrorInfo

Information about an error for reporting and handling.

#### Properties

- `error`: The actual error that occurred
- `stackTrace`: The stack trace associated with the error
- `severity`: The severity level of the error
- `type`: The type of error that occurred
- `errorSource`: Optional source identifier for the error
- `timestamp`: When the error occurred
- `context`: Additional context about the error
- `userData`: User-provided data associated with the error

### ErrorSeverity

Enum representing the severity level of an error.

- `low`: Non-critical errors that don't affect functionality
- `medium`: Errors that may affect some functionality
- `high`: Errors that significantly impact functionality
- `critical`: Errors that cause complete failure

### ErrorType

Enum representing the type of error that occurred.

- `build`: Build-time errors in widget construction
- `runtime`: Runtime errors during widget lifecycle
- `rendering`: Rendering errors in the widget tree
- `state`: State management errors
- `external`: Network or external service errors
- `unknown`: Unknown or unclassified errors

### BoundaryError

Represents an error that occurred within an error boundary.

#### Properties

- `error`: The actual error that occurred
- `stackTrace`: The stack trace associated with the error
- `errorSource`: Optional source identifier for the error
- `timestamp`: When the error occurred

## Fallback UI

### ErrorFallback

Default fallback widget that displays error information and provides recovery options.

#### Constructor

```dart
const ErrorFallback({
  super.key,
  required this.errorInfo,
  this.onRetry,
  this.onReport,
  this.showDetails = false,
})
```

#### Properties

- `errorInfo`: Information about the error that occurred
- `onRetry`: Callback function called when the user wants to retry
- `onReport`: Callback function called when the user wants to report the error
- `showDetails`: Whether to show detailed error information

### ErrorDisplay

Simple error display widget for basic error information.

#### Constructor

```dart
const ErrorDisplay({
  super.key,
  required this.message,
  this.icon = Icons.error_outline,
  this.color,
})
```

#### Properties

- `message`: The error message to display
- `icon`: The icon to display with the error
- `color`: The color for the icon and text

### Custom Fallback UI

You can create custom fallback UI using the `fallbackBuilder` parameter:

```dart
ErrorBoundary(
  fallbackBuilder: (errorInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
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

## Best Practices

### 1. Error Boundary Placement

Place error boundaries strategically in your widget tree:

```dart
// Wrap entire screens or major sections
ErrorBoundary(
  errorSource: 'HomeScreen',
  child: HomeScreen(),
)

// Wrap individual widgets that might fail
ErrorBoundary(
  errorSource: 'UserProfileWidget',
  child: UserProfileWidget(),
)
```

### 2. Error Source Identification

Always provide meaningful error sources for easier debugging:

```dart
ErrorBoundary(
  errorSource: 'UserProfileWidget',
  context: {
    'screen': 'profile',
    'userId': currentUser.id,
  },
  child: UserProfileWidget(),
)
```

### 3. Custom Error Handling

Implement custom error handlers for specific use cases:

```dart
class UserProfileErrorHandler implements ErrorHandler {
  @override
  Future<bool> handleError(ErrorInfo errorInfo) async {
    // Log user profile specific errors
    await UserProfileLogger.logError(errorInfo);
    
    // Attempt to reload user data
    return await UserProfileService.reloadData();
  }
  
  // ... other methods
}
```

### 4. Error Recovery

Implement meaningful recovery strategies:

```dart
class NetworkErrorHandler implements ErrorHandler {
  @override
  Future<bool> attemptRecovery(ErrorInfo errorInfo) async {
    if (errorInfo.type == ErrorType.external) {
      // Wait and retry network requests
      await Future.delayed(Duration(seconds: 2));
      return await NetworkService.retryRequest();
    }
    return false;
  }
}
```

### 5. Testing

Test your error boundaries thoroughly:

```dart
testWidgets('should display fallback UI when error occurs', (tester) async {
  final errorWidget = _ErrorThrowingWidget();
  
  await tester.pumpWidget(
    MaterialApp(
      home: ErrorBoundary(child: errorWidget),
    ),
  );

  // Trigger an error
  errorWidget.triggerError();
  await tester.pumpAndSettle();

  // Verify fallback UI is displayed
  expect(find.text('Something went wrong'), findsOneWidget);
});
```

## Performance Considerations

- Error boundaries have minimal performance overhead
- Error handling is asynchronous to avoid blocking the UI
- Error reporting can be disabled for production builds if needed
- Recovery attempts are limited to prevent infinite loops

## Security Considerations

- Error information may contain sensitive data
- Use `includeUserData: false` when user privacy is a concern
- Sanitize error context before reporting
- Consider implementing error data encryption for sensitive applications

## Migration Guide

### From Manual Error Handling

If you're currently using try-catch blocks throughout your app:

```dart
// Before
try {
  return MyWidget();
} catch (e, stackTrace) {
  return ErrorWidget(e.toString());
}

// After
ErrorBoundary(
  fallbackBuilder: (errorInfo) => ErrorWidget(errorInfo.error.toString()),
  child: MyWidget(),
)
```

### From Other Error Boundary Packages

The API is designed to be familiar and easy to migrate to:

```dart
// Most error boundary packages use similar patterns
ErrorBoundary(
  child: MyWidget(),
  onError: (error, stackTrace) {
    // Handle error
  },
)
```

## Troubleshooting

### Common Issues

1. **Error boundaries not catching errors**: Ensure the error occurs in the widget tree below the error boundary
2. **Fallback UI not displaying**: Check that the `fallbackBuilder` is properly implemented
3. **Recovery not working**: Verify that `attemptRecovery` is enabled and the error handler implements recovery logic
4. **Performance issues**: Disable error reporting for non-critical errors

### Debug Mode

Enable debug logging to troubleshoot issues:

```dart
// Set up debug error reporter
final debugReporter = DefaultErrorReporter(
  enabled: true,
  includeStackTrace: true,
  includeUserData: false,
);

ErrorBoundary(
  errorReporter: debugReporter,
  child: MyWidget(),
)
```

## Support

For issues, questions, or contributions:

- GitHub Issues: [Repository Issues](https://github.com/Dhia-Bechattaoui/flutter_error_boundary/issues)
- Documentation: [Package Documentation](https://pub.dev/packages/flutter_error_boundary)
- Examples: [Example App](example/)
- Tests: [Test Suite](test/)
