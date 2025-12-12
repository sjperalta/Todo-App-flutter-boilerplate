import '../models/todo.dart';
import '../services/storage_service.dart';

class TodoRepository {
  // Get all todos with error handling
  List<Todo> getAllTodos() {
    try {
      return StorageService.getAllTodos();
    } catch (e) {
      print('TodoRepository: Error getting all todos: $e');
      return [];
    }
  }

  // Get todo by ID with validation
  Todo? getTodoById(String id) {
    try {
      if (id.trim().isEmpty) {
        throw ArgumentError('Todo ID cannot be empty');
      }
      return StorageService.todoBox.get(id);
    } catch (e) {
      print('TodoRepository: Error getting todo by ID: $e');
      return null;
    }
  }

  // Create new todo with validation
  Future<bool> createTodo(Todo todo) async {
    try {
      // Validate todo data
      final validationErrors = todo.validate();
      if (validationErrors.isNotEmpty) {
        throw ArgumentError('Invalid todo data: ${validationErrors.join(', ')}');
      }

      // Check if todo with same ID already exists
      if (getTodoById(todo.id) != null) {
        throw ArgumentError('Todo with ID ${todo.id} already exists');
      }

      await StorageService.saveTodo(todo);
      return true;
    } catch (e) {
      print('TodoRepository: Error creating todo: $e');
      return false;
    }
  }

  // Update existing todo with validation
  Future<bool> updateTodo(Todo todo) async {
    try {
      // Validate todo data
      final validationErrors = todo.validate();
      if (validationErrors.isNotEmpty) {
        throw ArgumentError('Invalid todo data: ${validationErrors.join(', ')}');
      }

      // Check if todo exists
      if (getTodoById(todo.id) == null) {
        throw ArgumentError('Todo with ID ${todo.id} does not exist');
      }

      // Update the updatedAt timestamp
      final updatedTodo = todo.copyWith();
      await StorageService.saveTodo(updatedTodo);
      return true;
    } catch (e) {
      print('TodoRepository: Error updating todo: $e');
      return false;
    }
  }

  // Delete todo with validation
  Future<bool> deleteTodo(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw ArgumentError('Todo ID cannot be empty');
      }

      // Check if todo exists
      if (getTodoById(id) == null) {
        throw ArgumentError('Todo with ID $id does not exist');
      }

      await StorageService.deleteTodo(id);
      return true;
    } catch (e) {
      print('TodoRepository: Error deleting todo: $e');
      return false;
    }
  }

  // Get todos by category
  List<Todo> getTodosByCategory(String categoryId) {
    return getAllTodos().where((todo) => todo.categoryId == categoryId).toList();
  }

  // Get completed todos
  List<Todo> getCompletedTodos() {
    return getAllTodos().where((todo) => todo.isCompleted).toList();
  }

  // Get pending todos
  List<Todo> getPendingTodos() {
    return getAllTodos().where((todo) => !todo.isCompleted).toList();
  }

  // Get todos due today
  List<Todo> getTodayTodos() {
    return getAllTodos().where((todo) => todo.isDueToday).toList();
  }

  // Toggle todo completion with validation
  Future<bool> toggleTodoCompletion(String id) async {
    try {
      final todo = getTodoById(id);
      if (todo == null) {
        throw ArgumentError('Todo with ID $id not found');
      }

      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      return await updateTodo(updatedTodo);
    } catch (e) {
      print('TodoRepository: Error toggling todo completion: $e');
      return false;
    }
  }

  // Get todos sorted by priority
  List<Todo> getTodosSortedByPriority() {
    final todos = getAllTodos();
    todos.sort((a, b) => b.priority.compareTo(a.priority)); // High to Low
    return todos;
  }

  // Search todos by title with enhanced search
  List<Todo> searchTodos(String query) {
    try {
      if (query.trim().isEmpty) return getAllTodos();
      
      final normalizedQuery = query.toLowerCase().trim();
      
      return getAllTodos().where((todo) {
        return todo.title.toLowerCase().contains(normalizedQuery) ||
               (todo.description?.toLowerCase().contains(normalizedQuery) ?? false);
      }).toList();
    } catch (e) {
      print('TodoRepository: Error searching todos: $e');
      return [];
    }
  }

  // Get todos by multiple filters
  List<Todo> getFilteredTodos({
    String? categoryId,
    bool? isCompleted,
    int? priority,
    DateTime? dueDate,
    bool todayOnly = false,
  }) {
    try {
      var todos = getAllTodos();

      if (categoryId != null && categoryId.isNotEmpty) {
        todos = todos.where((todo) => todo.categoryId == categoryId).toList();
      }

      if (isCompleted != null) {
        todos = todos.where((todo) => todo.isCompleted == isCompleted).toList();
      }

      if (priority != null) {
        todos = todos.where((todo) => todo.priority == priority).toList();
      }

      if (todayOnly) {
        todos = todos.where((todo) => todo.isDueToday).toList();
      } else if (dueDate != null) {
        todos = todos.where((todo) {
          if (todo.dueDate == null) return false;
          final todoDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
          final filterDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
          return todoDate.isAtSameMomentAs(filterDate);
        }).toList();
      }

      return todos;
    } catch (e) {
      print('TodoRepository: Error filtering todos: $e');
      return [];
    }
  }

  // Batch operations
  Future<bool> createMultipleTodos(List<Todo> todos) async {
    try {
      for (final todo in todos) {
        final success = await createTodo(todo);
        if (!success) {
          throw Exception('Failed to create todo: ${todo.title}');
        }
      }
      return true;
    } catch (e) {
      print('TodoRepository: Error creating multiple todos: $e');
      return false;
    }
  }

  Future<bool> deleteMultipleTodos(List<String> ids) async {
    try {
      for (final id in ids) {
        final success = await deleteTodo(id);
        if (!success) {
          throw Exception('Failed to delete todo with ID: $id');
        }
      }
      return true;
    } catch (e) {
      print('TodoRepository: Error deleting multiple todos: $e');
      return false;
    }
  }

  // Get repository statistics
  Map<String, int> getStatistics() {
    try {
      final todos = getAllTodos();
      return {
        'total': todos.length,
        'completed': todos.where((todo) => todo.isCompleted).length,
        'pending': todos.where((todo) => !todo.isCompleted).length,
        'high_priority': todos.where((todo) => todo.priority == 3).length,
        'medium_priority': todos.where((todo) => todo.priority == 2).length,
        'low_priority': todos.where((todo) => todo.priority == 1).length,
        'due_today': todos.where((todo) => todo.isDueToday).length,
      };
    } catch (e) {
      print('TodoRepository: Error getting statistics: $e');
      return {};
    }
  }

  // Validate repository integrity
  Future<List<String>> validateIntegrity() async {
    final issues = <String>[];
    
    try {
      final todos = getAllTodos();
      
      for (final todo in todos) {
        final validationErrors = todo.validate();
        if (validationErrors.isNotEmpty) {
          issues.add('Todo ${todo.id}: ${validationErrors.join(', ')}');
        }
      }
      
      // Check for duplicate IDs
      final ids = todos.map((todo) => todo.id).toList();
      final uniqueIds = ids.toSet();
      if (ids.length != uniqueIds.length) {
        issues.add('Duplicate todo IDs found');
      }
      
    } catch (e) {
      issues.add('Error validating repository: $e');
    }
    
    return issues;
  }
}