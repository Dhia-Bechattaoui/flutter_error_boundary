import 'cloud/cloud_error_reporter_config_test.dart'
    as cloud_error_reporter_config_test;
import 'cloud/composite_error_reporter_test.dart'
    as composite_error_reporter_test;
import 'cloud/sentry_error_reporter_test.dart' as sentry_error_reporter_test;
import 'error_boundary_builder_test.dart' as error_boundary_builder_test;
import 'error_handler_test.dart' as error_handler_test;
import 'error_types_test.dart' as error_types_test;
import 'performance/error_boundary_performance_test.dart'
    as error_boundary_performance_test;
import 'platform/platform_compatibility_test.dart'
    as platform_compatibility_test;
import 'widgets/error_fallback_test.dart' as error_fallback_test;

/// Test runner for all flutter_error_boundary tests.
///
/// This file imports and runs all test files to ensure comprehensive test coverage.
/// Run this file to execute all tests: `flutter test test/all_tests.dart`
void main() {
  // Run all test suites
  error_types_test.main();
  error_handler_test.main();
  error_boundary_builder_test.main();
  error_fallback_test.main();
  sentry_error_reporter_test.main();
  composite_error_reporter_test.main();
  cloud_error_reporter_config_test.main();
  error_boundary_performance_test.main();
  platform_compatibility_test.main();
}
