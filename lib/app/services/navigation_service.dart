import 'package:flutter/material.dart';
import '/app/models/todo.dart';
import '/app/models/category.dart';
import '/app/services/error_handling_service.dart';
import '/resources/widgets/modals/new_task_modal.dart';
import '/resources/widgets/modals/edit_task_modal.dart';

/// Navigation service for handling modal navigation with proper animations
/// and consistent behavior across the TaskFlow application
class NavigationService {
  static const Duration _modalAnimationDuration = Duration(milliseconds: 300);
  static const Duration _pageTransitionDuration = Duration(milliseconds: 350);

  /// Show new task modal with slide-up animation
  static Future<T?> showNewTaskModal<T>(
    BuildContext context, {
    required List<Category> categories,
    required Function(Todo) onTaskCreated,
    required VoidCallback onCancel,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: _modalAnimationDuration,
        vsync: Navigator.of(context),
      ),
      builder: (context) => AnimatedContainer(
        duration: _modalAnimationDuration,
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: NewTaskModal(
            categories: categories,
            onTaskCreated: onTaskCreated,
            onCancel: onCancel,
          ),
        ),
      ),
    );
  }

  /// Show edit task modal with slide-up animation
  static Future<T?> showEditTaskModal<T>(
    BuildContext context, {
    required Todo todo,
    required List<Category> categories,
    required Function(Todo) onTaskUpdated,
    required VoidCallback onCancel,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: _modalAnimationDuration,
        vsync: Navigator.of(context),
      ),
      builder: (context) => AnimatedContainer(
        duration: _modalAnimationDuration,
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditTaskModal(
            todo: todo,
            categories: categories,
            onTaskUpdated: onTaskUpdated,
            onCancel: onCancel,
          ),
        ),
      ),
    );
  }

  /// Show confirmation dialog with fade animation (deprecated - use ErrorHandlingService)
  @Deprecated('Use ErrorHandlingService.showConfirmationDialog instead')
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    IconData? icon,
  }) {
    return ErrorHandlingService.showConfirmationDialog(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: confirmColor,
      icon: icon,
    );
  }

  /// Show error dialog with retry option
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String? retryText,
    IconData? icon,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              icon ?? Icons.error_outline,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(retryText ?? 'Retry'),
            ),
        ],
      ),
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// Navigate to page with custom transition
  static Future<T?> navigateWithTransition<T>(
    BuildContext context, {
    required Widget page,
    TransitionType transitionType = TransitionType.slideInFromRight,
    Duration? duration,
  }) {
    final route = PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? _pageTransitionDuration,
      reverseTransitionDuration: duration ?? _pageTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          animation,
          secondaryAnimation,
          child,
          transitionType,
        );
      },
    );

    return Navigator.of(context).push(route);
  }

  /// Navigate to named route with query parameters
  static Future<T?> navigateToNamed<T>(
    BuildContext context, {
    required String routeName,
    Map<String, String>? queryParameters,
    Object? arguments,
  }) {
    String route = routeName;
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      route = '$routeName?$queryString';
    }

    return Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  /// Replace current route with new route
  static Future<T?> replaceWithNamed<T>(
    BuildContext context, {
    required String routeName,
    Map<String, String>? queryParameters,
    Object? arguments,
  }) {
    String route = routeName;
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      route = '$routeName?$queryString';
    }

    return Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
  }

  /// Pop to root and navigate to new route
  static Future<T?> popToRootAndNavigate<T>(
    BuildContext context, {
    required String routeName,
    Map<String, String>? queryParameters,
    Object? arguments,
  }) {
    String route = routeName;
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      route = '$routeName?$queryString';
    }

    return Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Build transition animation based on type
  static Widget _buildTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    TransitionType transitionType,
  ) {
    switch (transitionType) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case TransitionType.slideInFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );

      case TransitionType.slideInFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );

      case TransitionType.slideInFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );

      case TransitionType.slideInFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: animation,
          child: child,
        );


    }
  }
}

/// Enum for different transition types
enum TransitionType {
  fade,
  slideInFromRight,
  slideInFromLeft,
  slideInFromBottom,
  slideInFromTop,
  scale,
  rotation,
}