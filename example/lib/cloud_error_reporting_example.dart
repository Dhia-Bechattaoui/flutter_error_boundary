import 'package:flutter/material.dart';
import 'package:flutter_error_boundary/flutter_error_boundary.dart';

/// Example demonstrating cloud error reporting capabilities.
class CloudErrorReportingExample extends StatelessWidget {
  const CloudErrorReportingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Error Reporting Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This example demonstrates how to configure and use cloud error reporting services.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Production Configuration
            _buildSection(
              title: 'Production Environment',
              description:
                  'Sends errors to both Sentry and Firebase Crashlytics',
              child: _buildProductionExample(),
            ),

            const SizedBox(height: 24),

            // Development Configuration
            _buildSection(
              title: 'Development Environment',
              description:
                  'Logs to console and optionally sends to HTTP endpoint',
              child: _buildDevelopmentExample(),
            ),

            const SizedBox(height: 24),

            // Staging Configuration
            _buildSection(
              title: 'Staging Environment',
              description: 'Sends to Sentry and custom HTTP endpoint',
              child: _buildStagingExample(),
            ),

            const SizedBox(height: 24),

            // Custom Configuration
            _buildSection(
              title: 'Custom Configuration',
              description: 'Manually configure individual reporters',
              child: _buildCustomExample(),
            ),

            const SizedBox(height: 24),

            // Test Error Button
            _buildSection(
              title: 'Test Error Reporting',
              description: 'Trigger an error to test the configured reporters',
              child: _buildTestErrorButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildProductionExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configuration:'),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''final productionReporter = CloudErrorReporterConfig.createProductionReporter(
  sentryDsn: 'https://your-sentry-dsn@sentry.io/project-id',
  sentryProjectId: 'your-sentry-project-id',
  firebaseProjectId: 'your-firebase-project-id',
  firebaseApiKey: 'your-firebase-api-key',
  environment: 'production',
  release: '1.0.0',
);''',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '• Sends errors to both Sentry and Firebase Crashlytics\n'
          '• Parallel reporting for better performance\n'
          '• Continues reporting if one service fails\n'
          '• Includes environment and release information',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDevelopmentExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configuration:'),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''final devReporter = CloudErrorReporterConfig.createDevelopmentReporter(
  httpEndpoint: 'http://localhost:3000/errors',
  includeConsole: true,
);''',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '• Logs errors to console for debugging\n'
          '• Optionally sends to local HTTP endpoint\n'
          '• Sequential reporting for easier debugging\n'
          '• Fewer retry attempts in development',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStagingExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configuration:'),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''final stagingReporter = CloudErrorReporterConfig.createStagingReporter(
  sentryDsn: 'https://your-sentry-dsn@sentry.io/project-id',
  sentryProjectId: 'your-sentry-project-id',
  httpEndpoint: 'https://staging-api.example.com/errors',
  environment: 'staging',
);''',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '• Sends errors to Sentry for monitoring\n'
          '• Also sends to staging API endpoint\n'
          '• Parallel reporting for performance\n'
          '• Environment-specific configuration',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCustomExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configuration:'),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '''final sentryReporter = SentryErrorReporter(
  dsn: 'https://key:secret@sentry.io/project-id',
  projectId: 'project-id',
  environment: 'production',
);

final httpReporter = HttpErrorReporter(
  endpoint: 'https://api.example.com/errors',
  method: 'POST',
  headers: {'Authorization': 'Bearer token'},
  retryAttempts: 5,
);

final customReporter = CompositeErrorReporter(
  reporters: [sentryReporter, httpReporter],
  continueOnFailure: true,
  parallelReporting: true,
);''',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '• Full control over individual reporters\n'
          '• Custom HTTP endpoints and methods\n'
          '• Configurable retry logic\n'
          '• Flexible composite reporting options',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTestErrorButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Click the button below to trigger an error and test your configured error reporters:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // This will trigger an error that gets caught by the error boundary
            throw Exception('Test error for cloud reporting demo');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Trigger Test Error'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Note: Make sure you have configured your error reporters with valid credentials before testing.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// Example app that demonstrates cloud error reporting.
class CloudErrorReportingApp extends StatelessWidget {
  const CloudErrorReportingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Example: Production configuration
    // In a real app, you would load this from environment variables
    final errorReporter = CloudErrorReporterConfig.createProductionReporter(
      sentryDsn: 'https://example:key@sentry.io/project-id',
      sentryProjectId: 'project-id',
      firebaseProjectId: 'firebase-project-id',
      firebaseApiKey: 'firebase-api-key',
      environment: 'production',
      release: '1.0.0',
    );

    // Set user information (in a real app, this would come from authentication)
    errorReporter.setUserIdentifier('demo-user-123');
    errorReporter.setUserProperties({
      'email': 'demo@example.com',
      'plan': 'demo',
      'source': 'cloud_error_reporting_example',
    });

    return MaterialApp(
      title: 'Cloud Error Reporting Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ErrorBoundary(
        fallbackBuilder: (errorInfo) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error Occurred'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'An error occurred and has been reported to your configured cloud services.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Details:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorInfo.error.toString(),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              const CloudErrorReportingExample(),
                        ),
                      );
                    },
                    child: const Text('Return to Example'),
                  ),
                ],
              ),
            ),
          );
        },
        child: const CloudErrorReportingExample(),
      ),
    );
  }
}
