import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

void main() {
  // Set up global error handling to catch build-time errors
  // Note: This is a global handler and will catch all Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // In a real app, you might want to report these to your error tracking service
    developer.log(
      'Flutter error caught: ${details.exception}',
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Customize ErrorWidget to show a nicer error UI instead of the red screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              details.exception.toString(),
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  };

  runApp(const MyApp());
}

/// Custom error handler that uses console reporting
class ConsoleErrorHandler extends DefaultErrorHandler {
  final ConsoleErrorReporter _reporter = ConsoleErrorReporter();

  ConsoleErrorHandler() : super(reportAllErrors: true);

  @override
  Future<bool> handleError(ErrorInfo errorInfo) async {
    await _reporter.reportError(errorInfo);
    return await super.handleError(errorInfo);
  }
}

/// Simple console-based error reporter for demonstration
class ConsoleErrorReporter implements ErrorReporter {
  @override
  Future<void> reportError(ErrorInfo errorInfo) async {
    developer.log(
      'Error reported: ${errorInfo.error}',
      name: 'ErrorBoundary',
      error: errorInfo.error,
      stackTrace: errorInfo.stackTrace,
    );
    developer.log(
      '📊 Error Report:\n  Type: ${errorInfo.type.name}\n  Severity: ${errorInfo.severity.name}\n  Source: ${errorInfo.errorSource ?? "Unknown"}\n  Context: ${errorInfo.context}',
      name: 'ErrorReporter',
    );
  }

  @override
  Future<void> reportErrorWithContext(
    ErrorInfo errorInfo,
    Map<String, dynamic> context,
  ) async {
    final Map<String, dynamic> combinedContext = {
      ...?errorInfo.context,
      ...context,
    };
    developer.log(
      'Error reported with context: ${errorInfo.error}',
      name: 'ErrorBoundary',
      error: errorInfo.error,
      stackTrace: errorInfo.stackTrace,
    );
    developer.log(
      '📊 Error Report (with context):\n  Type: ${errorInfo.type.name}\n  Severity: ${errorInfo.severity.name}\n  Context: $combinedContext',
      name: 'ErrorReporter',
    );
  }

  @override
  void setUserIdentifier(String userId) {
    developer.log('👤 User ID set: $userId', name: 'ErrorReporter');
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    developer.log('👤 User properties set: $properties', name: 'ErrorReporter');
  }

  @override
  void clearUserData() {
    developer.log('👤 User data cleared', name: 'ErrorReporter');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Error Boundary Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Error Boundary Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showErrorWidget = false;
  final ErrorBoundaryController _controller = ErrorBoundaryController();
  // Controllers for examples 1-6
  final ErrorBoundaryController _controller1 = ErrorBoundaryController();
  final ErrorBoundaryController _controller2 = ErrorBoundaryController();
  final ErrorBoundaryController _controller3 = ErrorBoundaryController();
  final ErrorBoundaryController _controller4 = ErrorBoundaryController();
  final ErrorBoundaryController _controller5 = ErrorBoundaryController();
  final ErrorBoundaryController _controller6 = ErrorBoundaryController();

  void _toggleErrorWidget() {
    setState(() {
      _showErrorWidget = !_showErrorWidget;
    });
  }

  void _reportErrorProgrammatically() {
    // Report error via controller - this will trigger the error boundary
    // The controller is attached to the ErrorBoundary in example 7
    developer.log('Reporting error programmatically...', name: 'Example');
    _controller.report(
      Exception('Programmatically reported error'),
      StackTrace.current,
    );
    developer.log('Error reported via controller', name: 'Example');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This app demonstrates error boundaries in action:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _toggleErrorWidget,
                child: Text(_showErrorWidget
                    ? 'Hide Error Examples'
                    : 'Show Error Examples'),
              ),
              const SizedBox(height: 20),
              if (_showErrorWidget) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Tap "Trigger Error" buttons to see error boundaries in action.\nNote: Build-time errors are caught by Flutter\'s framework first. The error boundary catches errors from async operations, callbacks, and programmatic reporting (see example 7).',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '1. Default Error Boundary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Example 1: Simple error boundary with default fallback
                ErrorBoundary(
                  controller: _controller1,
                  attemptRecovery:
                      false, // Disable auto-recovery so error UI is visible
                  child: _ErrorThrowingWidget(
                    key: const ValueKey('example1'),
                    controller: _controller1,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '2. Custom Fallback UI:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Example 2: Custom fallback
                ErrorBoundary(
                  controller: _controller2,
                  attemptRecovery:
                      false, // Disable auto-recovery so error UI is visible
                  child: _ErrorThrowingWidget(
                    key: const ValueKey('example2'),
                    controller: _controller2,
                  ),
                  fallbackBuilder: (errorInfo) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(height: 8),
                        Text(
                          'Custom Error: ${errorInfo.error}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Type: ${errorInfo.type.name}'),
                        Text('Severity: ${errorInfo.severity.name}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '3. Builder Pattern with Context:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Example 3: Using builder pattern
                ErrorBoundary(
                  controller: _controller3,
                  attemptRecovery:
                      false, // Disable auto-recovery so error UI is visible
                  errorSource: 'ExampleWidget',
                  context: {'screen': 'home', 'user': 'example'},
                  child: _ErrorThrowingWidget(
                    key: const ValueKey('example3'),
                    controller: _controller3,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '4. Extension Method:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Example 4: Using extension methods
                ErrorBoundary(
                  controller: _controller4,
                  attemptRecovery:
                      false, // Disable auto-recovery so error UI is visible
                  child: _ErrorThrowingWidget(
                    key: const ValueKey('example4'),
                    controller: _controller4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '5. Error Recovery with Retry:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Example 5: Error recovery enabled
                ErrorBoundary(
                  controller: _controller5,
                  attemptRecovery: true,
                  errorSource: 'RecoverableWidget',
                  child: _RecoverableErrorWidget(
                    key: const ValueKey('example5'),
                    controller: _controller5,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '6. Custom Error Reporter (Console):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Example 6: Custom error reporter (using custom error handler)
                ErrorBoundary(
                  controller: _controller6,
                  errorHandler: ConsoleErrorHandler(),
                  attemptRecovery:
                      false, // Disable auto-recovery so error UI is visible
                  errorSource: 'ReportedWidget',
                  context: {'feature': 'error_reporting'},
                  child: _ErrorThrowingWidget(
                    key: const ValueKey('example6'),
                    controller: _controller6,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '7. Programmatic Error Reporting:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Example 7: ErrorBoundaryController
                ErrorBoundary(
                  key: const ValueKey('example7'),
                  controller: _controller,
                  attemptRecovery:
                      false, // Disable auto-recovery so we can see the error UI
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.code, color: Colors.blue),
                        const SizedBox(height: 8),
                        const Text(
                          'Report errors programmatically',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _reportErrorProgrammatically,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Report Error via Controller'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorThrowingWidget extends StatefulWidget {
  const _ErrorThrowingWidget({super.key, this.controller});

  final ErrorBoundaryController? controller;

  @override
  State<_ErrorThrowingWidget> createState() => _ErrorThrowingWidgetState();
}

class _ErrorThrowingWidgetState extends State<_ErrorThrowingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(height: 8),
          const Text(
            'This widget is working normally',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Report error via controller instead of throwing in build
              // This allows the ErrorBoundary to catch it properly
              widget.controller?.report(
                Exception(
                    'This is a simulated error for demonstration purposes'),
                StackTrace.current,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Trigger Error'),
          ),
        ],
      ),
    );
  }
}

/// A widget that can recover from errors with retry functionality
class _RecoverableErrorWidget extends StatefulWidget {
  const _RecoverableErrorWidget({super.key, this.controller});

  final ErrorBoundaryController? controller;

  @override
  State<_RecoverableErrorWidget> createState() =>
      _RecoverableErrorWidgetState();
}

class _RecoverableErrorWidgetState extends State<_RecoverableErrorWidget> {
  int _attemptCount = 0;

  @override
  void initState() {
    super.initState();
    // Reset error state when widget is recreated (recovery)
    _attemptCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    // After 3 attempts, show success message
    if (_attemptCount >= 3) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.purple),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.purple),
            const SizedBox(height: 8),
            const Text(
              'Recovery successful!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Recovered after $_attemptCount attempts'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(height: 8),
          const Text(
            'Recoverable widget (working)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Report error via controller
              widget.controller?.report(
                Exception('Recoverable error (attempt ${_attemptCount + 1}/3)'),
                StackTrace.current,
              );
              setState(() {
                _attemptCount++;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Trigger Recoverable Error'),
          ),
        ],
      ),
    );
  }
}
