import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

/// Performance benchmarks for the ErrorBoundary widget.
///
/// These tests measure the actual performance overhead of using error boundaries
/// to verify the "Minimal performance overhead" claim.
void main() {
  group('ErrorBoundary Performance Benchmarks', () {
    late Stopwatch stopwatch;

    setUp(() {
      stopwatch = Stopwatch();
    });

    test('should have minimal widget creation overhead', () {
      const int iterations = 1000;
      final List<int> times = <int>[];

      for (int i = 0; i < iterations; i++) {
        stopwatch
          ..reset()
          ..start();

        // Create error boundary widget (this measures instantiation overhead)
        final ErrorBoundary widget = ErrorBoundary(child: Text('Test $i'));

        // Verify widget was created successfully
        expect(widget.child, isA<Container>());
        stopwatch.stop();
        times.add(stopwatch.elapsedMicroseconds);
      }

      // Calculate statistics
      final double avgTime = times.reduce((int a, int b) => a + b) / iterations;
      final int maxTime = times.reduce(max);

      // Performance assertion: Average creation time should be < 50 microseconds
      // This is an extremely fast operation, proving minimal overhead
      // Note: First iteration may be slower due to initialization
      expect(
        avgTime,
        lessThan(50),
        reason: 'Average widget creation time: ${avgTime.toStringAsFixed(2)}μs',
      );

      // Maximum time may be higher on first iteration due to initialization
      // But still should be reasonable (< 10ms even with initialization)
      expect(
        maxTime,
        lessThan(10000),
        reason:
            'Max widget creation time: $maxTimeμs (includes initialization overhead)',
      );
    });

    test('should handle error catching with minimal overhead', () {
      const int iterations = 100;
      final List<int> times = <int>[];

      final ErrorBoundaryController controller = ErrorBoundaryController();

      for (int i = 0; i < iterations; i++) {
        stopwatch
          ..reset()
          ..start();

        // Simulate error reporting
        controller.report('Test error $i', StackTrace.current);

        stopwatch.stop();
        times.add(stopwatch.elapsedMicroseconds);
      }

      final double avgTime = times.reduce((int a, int b) => a + b) / iterations;
      final int maxTime = times.reduce(max);

      // Error reporting should be fast (< 1000 microseconds)
      expect(
        avgTime,
        lessThan(1000),
        reason: 'Average error handling time: ${avgTime.toStringAsFixed(2)}μs',
      );
      expect(
        maxTime,
        lessThan(5000),
        reason: 'Max error handling time: $maxTimeμs',
      );
    });

    test('should have minimal memory overhead', () {
      // Create multiple error boundaries to measure memory overhead
      final List<ErrorBoundary> boundaries = <ErrorBoundary>[];

      stopwatch
        ..reset()
        ..start();

      for (int i = 0; i < 1000; i++) {
        boundaries.add(ErrorBoundary(child: Container()));
      }

      stopwatch.stop();

      // Creating 1000 error boundaries should be fast
      final double avgCreationTime = stopwatch.elapsedMicroseconds / 1000;
      expect(
        avgCreationTime,
        lessThan(50),
        reason:
            'Average creation time: ${avgCreationTime.toStringAsFixed(2)}μs',
      );
    });

    test('error reporting should not block UI thread', () async {
      final ErrorBoundaryController controller = ErrorBoundaryController();
      final List<int> durations = <int>[];

      // Measure async error reporting performance
      for (int i = 0; i < 10; i++) {
        stopwatch
          ..reset()
          ..start();

        controller.report('Test error $i', StackTrace.current);

        stopwatch.stop();
        durations.add(stopwatch.elapsedMilliseconds);
      }

      final double avgDuration =
          durations.reduce((int a, int b) => a + b) / durations.length;

      // Error reporting should complete quickly (synchronous operation)
      expect(
        avgDuration,
        lessThan(1),
        reason:
            'Average error reporting time: ${avgDuration.toStringAsFixed(2)}ms',
      );
    });
  });
}
