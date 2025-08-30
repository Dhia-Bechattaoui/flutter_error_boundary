import 'package:flutter/material.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

void main() {
  runApp(const MyApp());
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
  int _counter = 0;
  bool _showErrorWidget = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _toggleErrorWidget() {
    setState(() {
      _showErrorWidget = !_showErrorWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'This app demonstrates error boundaries in action:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _toggleErrorWidget,
              child: Text(
                  _showErrorWidget ? 'Hide Error Widget' : 'Show Error Widget'),
            ),
            const SizedBox(height: 20),
            if (_showErrorWidget) ...[
              const Text(
                'Error Widget (Protected by Error Boundary):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Example 1: Simple error boundary
              ErrorBoundary(
                child: _ErrorThrowingWidget(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Error Widget with Custom Fallback:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Example 2: Custom fallback
              ErrorBoundary(
                child: _ErrorThrowingWidget(),
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
                'Error Widget with Builder Pattern:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Example 3: Using builder pattern
              ErrorBoundaryBuilder().wrap(
                child: _ErrorThrowingWidget(),
                errorSource: 'ExampleWidget',
                context: {'screen': 'home', 'user': 'example'},
              ),
              const SizedBox(height: 20),
              const Text(
                'Error Widget with Extension Method:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Example 4: Using extension methods
              _ErrorThrowingWidget().withSimpleErrorBoundary(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ErrorThrowingWidget extends StatefulWidget {
  @override
  State<_ErrorThrowingWidget> createState() => _ErrorThrowingWidgetState();
}

class _ErrorThrowingWidgetState extends State<_ErrorThrowingWidget> {
  bool _shouldThrow = false;

  @override
  Widget build(BuildContext context) {
    if (_shouldThrow) {
      throw Exception('This is a simulated error for demonstration purposes');
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
            'This widget is working normally',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _shouldThrow = true;
              });
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
