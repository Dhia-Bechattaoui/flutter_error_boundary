// Error fallback widget that displays error information and provides recovery options.

import 'package:flutter/material.dart';
import '../error_types.dart';

/// A widget that displays error information and provides options for recovery.
class ErrorFallback extends StatelessWidget {
  /// Creates an error fallback widget.
  const ErrorFallback({
    super.key,
    required this.errorInfo,
    this.onRetry,
    this.onReport,
    this.showDetails = false,
  });

  /// Information about the error that occurred.
  final ErrorInfo errorInfo;

  /// Callback function called when the user wants to retry.
  final VoidCallback? onRetry;

  /// Callback function called when the user wants to report the error.
  final VoidCallback? onReport;

  /// Whether to show detailed error information.
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildErrorIcon(),
            const SizedBox(height: 16.0),
            _buildErrorMessage(),
            const SizedBox(height: 16.0),
            _buildErrorDetails(),
            const SizedBox(height: 24.0),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Icon(
      Icons.error_outline,
      size: 64.0,
      color: Colors.red[400],
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      'Something went wrong',
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorDetails() {
    if (!showDetails) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error Details:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Type: ${errorInfo.type.name}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            'Severity: ${errorInfo.severity.name}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (errorInfo.errorSource != null)
            Text(
              'Source: ${errorInfo.errorSource}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          if (errorInfo.timestamp != null)
            Text(
              'Time: ${errorInfo.timestamp!.toLocal()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onRetry != null) ...[
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
          const SizedBox(width: 16.0),
        ],
        if (onReport != null)
          OutlinedButton(
            onPressed: onReport,
            child: const Text('Report'),
          ),
      ],
    );
  }
}
