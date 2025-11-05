// Simple error display widget for basic error information.

import 'package:flutter/material.dart';

/// A simple error display widget for basic error information.
class ErrorDisplay extends StatelessWidget {
  /// Creates a simple error display widget.
  const ErrorDisplay({
    required this.message,
    super.key,
    this.icon = Icons.error_outline,
    this.color,
  });

  /// The error message to display.
  final String message;

  /// The icon to display with the error.
  final IconData icon;

  /// The color for the icon and text.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color errorColor = color ?? Colors.red[400] ?? Colors.red;

    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 48, color: errorColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: errorColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
