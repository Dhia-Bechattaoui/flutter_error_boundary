import 'package:flutter_error_boundary/src/cloud/composite_error_reporter.dart';
import 'package:flutter_error_boundary/src/error_reporter.dart';
import 'package:flutter_error_boundary/src/error_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'composite_error_reporter_test.mocks.dart';

@GenerateMocks(<Type>[ErrorReporter])
void main() {
  group('CompositeErrorReporter', () {
    late MockErrorReporter mockReporter1;
    late MockErrorReporter mockReporter2;
    late MockErrorReporter mockReporter3;
    late CompositeErrorReporter compositeReporter;
    late ErrorInfo testErrorInfo;

    setUp(() {
      mockReporter1 = MockErrorReporter();
      mockReporter2 = MockErrorReporter();
      mockReporter3 = MockErrorReporter();

      compositeReporter = CompositeErrorReporter(
        reporters: <ErrorReporter>[mockReporter1, mockReporter2],
      );

      testErrorInfo = ErrorInfo(
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.high,
        type: ErrorType.runtime,
      );
    });

    test('should create with correct configuration', () {
      expect(compositeReporter.reporterCount, 2);
      expect(compositeReporter.reporters, <MockErrorReporter>[
        mockReporter1,
        mockReporter2,
      ]);
    });

    test('should report error to all reporters', () async {
      when(mockReporter1.reportError(any)).thenAnswer((_) async {});
      when(mockReporter2.reportError(any)).thenAnswer((_) async {});

      await compositeReporter.reportError(testErrorInfo);

      verify(mockReporter1.reportError(testErrorInfo)).called(1);
      verify(mockReporter2.reportError(testErrorInfo)).called(1);
    });

    test('should report error with context to all reporters', () async {
      when(
        mockReporter1.reportErrorWithContext(any, any),
      ).thenAnswer((_) async {});
      when(
        mockReporter2.reportErrorWithContext(any, any),
      ).thenAnswer((_) async {});

      final Map<String, String> context = <String, String>{
        'screen': 'TestScreen',
      };
      await compositeReporter.reportErrorWithContext(testErrorInfo, context);

      verify(
        mockReporter1.reportErrorWithContext(testErrorInfo, context),
      ).called(1);
      verify(
        mockReporter2.reportErrorWithContext(testErrorInfo, context),
      ).called(1);
    });

    test('should set user identifier on all reporters', () {
      compositeReporter.setUserIdentifier('user-123');

      verify(mockReporter1.setUserIdentifier('user-123')).called(1);
      verify(mockReporter2.setUserIdentifier('user-123')).called(1);
    });

    test('should set user properties on all reporters', () {
      final Map<String, String> properties = <String, String>{
        'email': 'test@example.com',
      };
      compositeReporter.setUserProperties(properties);

      verify(mockReporter1.setUserProperties(properties)).called(1);
      verify(mockReporter2.setUserProperties(properties)).called(1);
    });

    test('should clear user data on all reporters', () {
      compositeReporter.clearUserData();

      verify(mockReporter1.clearUserData()).called(1);
      verify(mockReporter2.clearUserData()).called(1);
    });

    test(
      'should handle reporter failures gracefully when continueOnFailure is true',
      () async {
        when(
          mockReporter1.reportError(any),
        ).thenThrow(Exception('Reporter 1 failed'));
        when(mockReporter2.reportError(any)).thenAnswer((_) async {});

        // Should not throw
        await compositeReporter.reportError(testErrorInfo);

        verify(mockReporter1.reportError(testErrorInfo)).called(1);
        verify(mockReporter2.reportError(testErrorInfo)).called(1);
      },
    );

    test(
      'should throw when continueOnFailure is false and a reporter fails',
      () async {
        final CompositeErrorReporter strictReporter = CompositeErrorReporter(
          reporters: <ErrorReporter>[mockReporter1, mockReporter2],
          continueOnFailure: false,
        );

        when(
          mockReporter1.reportError(any),
        ).thenThrow(Exception('Reporter 1 failed'));
        when(mockReporter2.reportError(any)).thenAnswer((_) async {});

        expect(
          () => strictReporter.reportError(testErrorInfo),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('should work with empty reporters list', () async {
      final CompositeErrorReporter emptyReporter = CompositeErrorReporter(
        reporters: <ErrorReporter>[],
      );

      // Should not throw
      await emptyReporter.reportError(testErrorInfo);
      emptyReporter
        ..setUserIdentifier('user-123')
        ..setUserProperties(<String, dynamic>{'test': 'value'})
        ..clearUserData();
    });

    test('should add reporter', () {
      final CompositeErrorReporter newComposite = compositeReporter.addReporter(
        mockReporter3,
      );

      expect(newComposite.reporterCount, 3);
      expect(newComposite.reporters, <MockErrorReporter>[
        mockReporter1,
        mockReporter2,
        mockReporter3,
      ]);
      expect(compositeReporter.reporterCount, 2); // Original unchanged
    });

    test('should remove reporter', () {
      final CompositeErrorReporter newComposite = compositeReporter
          .removeReporter(mockReporter1);

      expect(newComposite.reporterCount, 1);
      expect(newComposite.reporters, <MockErrorReporter>[mockReporter2]);
      expect(compositeReporter.reporterCount, 2); // Original unchanged
    });

    test('should create with different settings', () {
      final CompositeErrorReporter newComposite = compositeReporter
          .withSettings(continueOnFailure: false, parallelReporting: false);

      expect(newComposite.continueOnFailure, false);
      expect(newComposite.parallelReporting, false);
      expect(newComposite.reporters, <MockErrorReporter>[
        mockReporter1,
        mockReporter2,
      ]);
    });

    test('should handle individual reporter failures gracefully', () {
      when(mockReporter1.setUserIdentifier(any)).thenThrow(Exception('Failed'));
      when(mockReporter2.setUserIdentifier(any)).thenAnswer((_) {});

      // Should not throw
      compositeReporter.setUserIdentifier('user-123');

      verify(mockReporter1.setUserIdentifier('user-123')).called(1);
      verify(mockReporter2.setUserIdentifier('user-123')).called(1);
    });

    test('should work with single reporter', () async {
      final CompositeErrorReporter singleReporter = CompositeErrorReporter(
        reporters: <ErrorReporter>[mockReporter1],
      );

      when(mockReporter1.reportError(any)).thenAnswer((_) async {});

      await singleReporter.reportError(testErrorInfo);

      verify(mockReporter1.reportError(testErrorInfo)).called(1);
    });

    test('should maintain immutability of reporters list', () {
      final List<ErrorReporter> reporters = compositeReporter.reporters;

      expect(() => reporters.add(mockReporter3), throwsUnsupportedError);
    });
  });
}
