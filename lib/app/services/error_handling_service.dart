import 'package:flutter/material.dart';


/// Centralized error handling service for the TaskFlow application
class ErrorHandlingService {
  static const String _logTag = 'ErrorHandlingService';
  
  /// Show user-friendly error message based on error type
  static void showError(BuildContext context, dynamic error, {String? customMessage}) {
    final message = _getErrorMessage(error, customMessage);
    _showErrorSnackBar(context, message);
    _logError(error, customMessage);
  }

  /// Show success message to user
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message to user
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show confirmation dialog for destructive actions
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isDangerous ? Colors.red : Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? 
                  (isDangerous ? Colors.red : Theme.of(context).primaryColor),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                confirmText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Handle async operations with error handling
  static Future<T?> handleAsyncOperation<T>(
    BuildContext context,
    Future<T> operation, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
    bool showLoading = false,
  }) async {
    try {
      if (showLoading) {
        showLoadingDialog(context, message: loadingMessage);
      }

      final result = await operation;

      if (showLoading) {
        hideLoadingDialog(context);
      }

      if (successMessage != null) {
        showSuccess(context, successMessage);
      }

      return result;
    } catch (error) {
      if (showLoading) {
        hideLoadingDialog(context);
      }

      showError(context, error, customMessage: errorMessage);
      return null;
    }
  }

  /// Validate input and show errors
  static bool validateInput(
    BuildContext context,
    Map<String, dynamic> validations,
  ) {
    final errors = <String>[];

    validations.forEach((field, validation) {
      if (validation is String && validation.isNotEmpty) {
        errors.add(validation);
      } else if (validation is List<String> && validation.isNotEmpty) {
        errors.addAll(validation);
      }
    });

    if (errors.isNotEmpty) {
      showError(context, ValidationException(errors.first));
      return false;
    }

    return true;
  }

  /// Handle network connectivity errors
  static void handleNetworkError(BuildContext context) {
    showError(
      context,
      NetworkException('No internet connection'),
      customMessage: 'Please check your internet connection and try again',
    );
  }

  /// Handle storage errors with recovery options
  static Future<void> handleStorageError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    VoidCallback? onReset,
  }) async {
    final shouldRetry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.storage, color: Colors.orange, size: 24),
              SizedBox(width: 12),
              Text('Storage Error'),
            ],
          ),
          content: const Text(
            'There was a problem accessing your data. Would you like to try again or reset the app data?',
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          actions: [
            if (onReset != null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(
                  'Reset Data',
                  style: TextStyle(color: Colors.red[600]),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );

    if (shouldRetry == true && onRetry != null) {
      onRetry();
    } else if (shouldRetry == null && onReset != null) {
      final confirmReset = await showConfirmationDialog(
        context,
        title: 'Reset App Data',
        message: 'This will delete all your tasks and settings. This action cannot be undone.',
        confirmText: 'Reset',
        cancelText: 'Cancel',
        isDangerous: true,
        icon: Icons.warning,
      );

      if (confirmReset) {
        onReset();
      }
    }
  }

  /// Get user-friendly error message
  static String _getErrorMessage(dynamic error, String? customMessage) {
    if (customMessage != null) {
      return customMessage;
    }

    if (error is ValidationException) {
      return error.message;
    } else if (error is StorageException) {
      return 'Storage error: ${error.message}';
    } else if (error is NetworkException) {
      return 'Network error: ${error.message}';
    } else if (error is ArgumentError) {
      return 'Invalid input: ${error.message}';
    } else if (error is FormatException) {
      return 'Data format error: ${error.message}';
    } else if (error is Exception) {
      return 'An error occurred: ${error.toString()}';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Log error for debugging
  static void _logError(dynamic error, String? customMessage) {
    final message = customMessage ?? error.toString();
    print('$_logTag: $message');
    
    // In production, you might want to send this to a crash reporting service
    // like Firebase Crashlytics or Sentry
  }
}

/// Custom exception classes for better error handling
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}