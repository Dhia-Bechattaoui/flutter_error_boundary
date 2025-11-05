/// Flutter Error Boundary Package
///
/// This package provides error boundary widgets that catch and handle errors
/// gracefully in Flutter applications, preventing crashes and providing
/// fallback UI when errors occur.
///
/// ## Features
///
/// - Error catching in widget trees
/// - Customizable fallback UI
/// - Error reporting to external services
/// - Cloud error reporting (Sentry, Firebase Crashlytics, HTTP)
/// - Error recovery mechanisms
/// - Platform-agnostic implementation
///
/// ## Usage
///
/// ```dart
/// import 'package:flutter_error_boundary/flutter_error_boundary.dart';
///
/// ErrorBoundary(
///   child: MyWidget(),
/// )
/// ```
// ignore: unnecessary_library_name
library flutter_error_boundary;

export 'src/cloud/cloud_error_reporters.dart';
export 'src/error_boundary.dart';
export 'src/error_boundary_builder.dart';
export 'src/error_boundary_controller.dart';
export 'src/error_handler.dart';
export 'src/error_reporter.dart';
export 'src/error_types.dart';
export 'src/widgets/error_display.dart';
export 'src/widgets/error_fallback.dart';
