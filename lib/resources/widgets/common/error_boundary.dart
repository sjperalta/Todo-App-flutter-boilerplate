import 'package:flutter/material.dart';

import '/bootstrap/extensions.dart';

/// Error boundary widget that catches and handles errors in child widgets
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? errorTitle;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final Widget? fallbackWidget;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorTitle,
    this.errorMessage,
    this.onRetry,
    this.showRetryButton = true,
    this.fallbackWidget,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Set up error handling for the current zone
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
          _hasError = true;
        });
      }
      
      // Log the error
      print('ErrorBoundary caught error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallbackWidget ?? _buildErrorWidget(context);
    }

    return widget.child;
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Error title
              Text(
                widget.errorTitle ?? 'Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.color.content,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Error message
              Text(
                widget.errorMessage ?? 
                'An unexpected error occurred. Please try again or restart the app.',
                style: TextStyle(
                  fontSize: 16,
                  color: context.color.content.withValues(alpha: 0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.showRetryButton) ...[
                    ElevatedButton.icon(
                      onPressed: _handleRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.color.primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  
                  TextButton.icon(
                    onPressed: _showErrorDetails,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: context.color.content.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRetry() {
    setState(() {
      _error = null;
      _stackTrace = null;
      _hasError = false;
    });
    
    widget.onRetry?.call();
  }

  void _showErrorDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.color.content,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error?.toString() ?? 'Unknown error',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: context.color.content.withValues(alpha: 0.8),
                ),
              ),
              if (_stackTrace != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Stack Trace:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.color.content,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _stackTrace.toString(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: context.color.content.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Reset the error state
  void reset() {
    if (mounted) {
      setState(() {
        _error = null;
        _stackTrace = null;
        _hasError = false;
      });
    }
  }

  /// Check if there's an active error
  bool get hasError => _hasError;

  /// Get the current error
  Object? get error => _error;
}

/// Wrapper widget for handling async errors
class AsyncErrorBoundary extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onRetry;
  final String? errorTitle;
  final String? errorMessage;

  const AsyncErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.errorTitle,
    this.errorMessage,
  });

  @override
  State<AsyncErrorBoundary> createState() => _AsyncErrorBoundaryState();
}

class _AsyncErrorBoundaryState extends State<AsyncErrorBoundary> {
  bool _isLoading = false;
  bool _hasError = false;
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_hasError && !_isLoading) {
      return ErrorStateWidget(
        title: widget.errorTitle ?? 'Something went wrong',
        message: widget.errorMessage ?? 
          'An error occurred while loading data. Please try again.',
        onRetry: widget.onRetry != null ? _handleRetry : null,
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return widget.child;
  }

  Future<void> _handleRetry() async {
    if (widget.onRetry == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _error = null;
    });

    try {
      await widget.onRetry!();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _error = e;
        });
      }
    }
  }

  /// Trigger an error state
  void setError(Object error) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  /// Reset the error state
  void reset() {
    if (mounted) {
      setState(() {
        _hasError = false;
        _isLoading = false;
      });
    }
  }
}

/// Error state widget for displaying errors with retry option
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.color.content,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: context.color.content.withValues(alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}