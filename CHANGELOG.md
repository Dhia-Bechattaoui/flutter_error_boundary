# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2025-08-30

### Added
- **Cloud Error Reporting Integration**: Added comprehensive cloud error reporting capabilities
  - **Sentry Integration**: Full Sentry error reporting with DSN, project ID, environment, and release support
  - **Firebase Crashlytics**: Firebase Crashlytics integration for crash reporting and analytics
  - **Generic HTTP Reporter**: Configurable HTTP endpoint reporting with custom headers, methods, and retry logic
  - **Composite Reporter**: Multi-service error reporting with parallel/sequential execution options
- **Configuration Helpers**: Environment-specific configuration presets
  - Production configuration for Sentry + Firebase Crashlytics
  - Development configuration with console logging and optional HTTP endpoints
  - Staging configuration with Sentry and custom HTTP endpoints
- **Enhanced Error Context**: Improved error information with user data, environment details, and custom context
- **Retry Mechanisms**: Configurable retry logic for failed error reports
- **User Identification**: Support for user-specific error tracking and analytics
- **Performance Optimizations**: Parallel error reporting for better performance

### Enhanced
- **Code Quality**: Achieved perfect Pana score (160/160) for package quality
- **Documentation**: Comprehensive cloud error reporting documentation and examples
- **Testing**: Extended test coverage for all new cloud reporting features
- **Error Handling**: Improved error handling with better fallback mechanisms
- **Platform Support**: Enhanced cross-platform compatibility and testing

### Technical Improvements
- Added `http` package dependency for cloud reporting capabilities
- Improved error type definitions and severity handling
- Enhanced error boundary controller with better error propagation
- Optimized error reporting performance with parallel execution options
- Better error context preservation and user data handling

## [0.0.1] - 2024-12-19

### Added
- Initial release of flutter_error_boundary package
- Error boundary widget that catches and handles errors gracefully
- Support for custom error handlers and fallback UI
- Comprehensive error reporting and logging capabilities
- Integration with Flutter's error handling system
- Support for both synchronous and asynchronous error handling
- Customizable error boundaries for different widget trees
- Built-in error recovery mechanisms
- Support for error boundary nesting
- Comprehensive test coverage
- Full documentation with examples
- Support for Flutter 3.0+ and Dart 3.0+

### Technical Features
- Null safety support
- Platform-agnostic implementation
- Minimal performance overhead
- Memory leak prevention
- Proper error propagation
- Integration with Flutter DevTools
- Support for hot reload during development
