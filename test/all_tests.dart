import 'error_types_test.dart' as error_types_test;
import 'error_handler_test.dart' as error_handler_test;
import 'error_reporter_test.dart' as error_reporter_test;
import 'error_boundary_builder_test.dart' as error_boundary_builder_test;
import 'widgets/error_fallback_test.dart' as error_fallback_test;

/// Test runner for all flutter_error_boundary tests.
///
/// This file imports and runs all test files to ensure comprehensive test coverage.
/// Run this file to execute all tests: `flutter test test/all_tests.dart`
void main() {
  // Run all test suites
  error_types_test.main();
  error_handler_test.main();
  error_reporter_test.main();
  error_boundary_builder_test.main();
  error_fallback_test.main();
}
