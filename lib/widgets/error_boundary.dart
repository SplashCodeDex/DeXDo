import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();

    // Set up global error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _hasError = true;
            _errorDetails = details;
          });
        });
      }

      // Call custom error handler if provided
      widget.onError?.call(details);

      // Log error for debugging
      debugPrint('Error caught by ErrorBoundary: ${details.exception}');
      debugPrint('Stack trace: ${details.stack}');
    };
  }

  void _resetError() {
    setState(() {
      _hasError = false;
      _errorDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallback ?? _buildDefaultErrorWidget();
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF5F5DC).withOpacity(0.8),
              const Color(0xFFF5F5DC).withOpacity(0.9),
              const Color(0xFFF5F5DC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'The app encountered an unexpected error. Don\'t worry, your data is safe.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade300.withOpacity(0.8),
                        Colors.blue.shade300.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _resetError,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorDetails != null) ...[
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFFF5F5DC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Error Details',
                            style: TextStyle(
                              color: Color(0xFF4B4B4B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              _errorDetails!.exception.toString(),
                              style: const TextStyle(
                                color: Color(0xFF4B4B4B),
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Close',
                                style: TextStyle(color: Color(0xFF4B4B4B)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Show Details',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppErrorBoundary extends StatelessWidget {
  final Widget child;

  const AppErrorBoundary({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: (FlutterErrorDetails details) {
        // Log to crash reporting service in production
        debugPrint('App Error: ${details.exception}');
        debugPrint('Context: ${details.context}');
        debugPrint('Stack: ${details.stack}');
      },
      child: child,
    );
  }
}
