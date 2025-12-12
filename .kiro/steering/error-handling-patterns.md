---
inclusion: always
---

# Error Handling and Recovery Patterns

## Error Handling Philosophy

### Graceful Degradation
- App should never crash from recoverable errors
- Provide meaningful feedback to users
- Implement fallback mechanisms for critical operations
- Maintain app functionality even when some features fail

### User Experience Focus
- Show user-friendly error messages, not technical details
- Provide clear recovery actions when possible
- Use loading states to prevent user confusion
- Implement retry mechanisms for transient failures

## Error Categories and Handling

### Storage Errors
```dart
// Handle Hive storage failures gracefully
class StorageErrorHandler {
  static Future<T?> handleStorageOperation<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      return await operation();
    } on HiveError catch (e) {
      print('Hive error in $operationName: ${e.message}');
      // Attempt recovery or fallback to in-memory storage
      return null;
    } on FileSystemException catch (e) {
      print('File system error in $operationName: ${e.message}');
      // Handle disk space or permission issues
      return null;
    } catch (e) {
      print('Unexpected error in $operationName: $e');
      return null;
    }
  }
}
```

### Form Validation Errors
```dart
// Consistent form error handling
class FormErrorHandler {
  static void showValidationErrors(
    BuildContext context,
    Map<String, String> errors,
  ) {
    final errorMessage = errors.values.first;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }
}
```

### Network and Connectivity Errors
```dart
// Handle offline scenarios gracefully
class ConnectivityErrorHandler {
  static void handleOfflineOperation(
    BuildContext context,
    VoidCallback retryCallback,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connection Issue'),
        content: Text('This feature requires an internet connection. Please check your connection and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              retryCallback();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

## Error Boundaries and Recovery

### Widget Error Boundaries
```dart
// Wrap critical UI sections with error boundaries
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final Function(Object error, StackTrace stackTrace)? onError;
  
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.fallback,
    this.onError,
  }) : super(key: key);
  
  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  Object? error;
  
  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return widget.fallback ?? _buildDefaultErrorWidget();
    }
    
    return widget.child;
  }
  
  Widget _buildDefaultErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          SizedBox(height: 16),
          Text('Something went wrong'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() => hasError = false),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
```

### Controller Error Handling
```dart
// Standardized error handling in controllers
abstract class BaseController extends Controller {
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      _setLoading(true);
      _clearError();
      
      final result = await operation();
      return result;
    } catch (e) {
      _setError('Failed to $operationName. Please try again.');
      print('Error in $operationName: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    // Trigger UI update through Nylo's state management
  }
  
  void _setError(String message) {
    _errorMessage = message;
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}
```

## Specific Error Scenarios

### Data Corruption Recovery
```dart
// Handle corrupted data gracefully
class DataRecoveryService {
  static Future<List<Todo>> recoverTodos() async {
    try {
      final todos = await TodoRepository().getAll();
      return _validateAndCleanTodos(todos);
    } catch (e) {
      print('Data recovery needed: $e');
      return _createDefaultTodos();
    }
  }
  
  static List<Todo> _validateAndCleanTodos(List<Todo> todos) {
    return todos.where((todo) {
      // Validate each todo and filter out corrupted ones
      return todo.id.isNotEmpty && 
             todo.title.isNotEmpty &&
             todo.priority >= 1 && todo.priority <= 3;
    }).toList();
  }
  
  static List<Todo> _createDefaultTodos() {
    return [
      Todo(
        id: 'welcome-1',
        title: 'Welcome to TaskFlow!',
        description: 'This is your first task. Tap to mark it complete.',
        categoryId: 'personal',
        priority: 2,
      ),
    ];
  }
}
```

### Memory Pressure Handling
```dart
// Handle low memory situations
class MemoryPressureHandler {
  static void handleMemoryWarning() {
    // Clear caches
    FilterCache.instance.clear();
    SearchIndex.instance.clear();
    
    // Reduce image cache size
    PaintingBinding.instance.imageCache.clear();
    
    // Force garbage collection
    // Note: This is generally not recommended in production
    // but can be useful in extreme low-memory situations
  }
}
```

### Validation Error Patterns
```dart
// Comprehensive input validation
class ValidationService {
  static ValidationResult validateTodo(Todo todo) {
    final errors = <String>[];
    
    if (todo.title.trim().isEmpty) {
      errors.add('Title is required');
    }
    
    if (todo.title.length > 100) {
      errors.add('Title must be less than 100 characters');
    }
    
    if (todo.priority < 1 || todo.priority > 3) {
      errors.add('Priority must be between 1 and 3');
    }
    
    if (todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      errors.add('Due date cannot be in the past');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  
  ValidationResult({required this.isValid, required this.errors});
  
  String get firstError => errors.isNotEmpty ? errors.first : '';
}
```

## User Feedback Patterns

### Toast Messages
```dart
// Consistent toast messaging
class ToastService {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF32C7AE),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
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
}
```

### Loading States with Error Recovery
```dart
// Loading overlay with error handling
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget child;
  
  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF32C7AE)),
              ),
            ),
          ),
        if (errorMessage != null)
          Container(
            color: Colors.black26,
            child: Center(
              child: Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(errorMessage!),
                      if (onRetry != null) ...[
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: onRetry,
                          child: Text('Try Again'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

This error handling approach ensures the TaskFlow application provides a robust, user-friendly experience even when things go wrong.