import '../models/todo.dart';
import '../models/task_statistics.dart';
import '../repositories/todo_repository.dart';
import '../repositories/category_repository.dart';
import '../services/error_handling_service.dart';
import '../services/performance_service.dart';
import '../services/search_optimization_service.dart';
import '../services/performance_test_service.dart';
import 'controller.dart';

enum TabType { all, today, completed }

class TodoController extends Controller {
  final TodoRepository _todoRepository = TodoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final SearchOptimizationService _searchService = SearchOptimizationService();
  final PerformanceService _performanceService = PerformanceService();
  
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  String? _selectedCategoryId;
  TabType _selectedTab = TabType.all;
  String _searchQuery = '';
  
  // Getters
  List<Todo> get todos => List.unmodifiable(_filteredTodos);
  String? get selectedCategoryId => _selectedCategoryId;
  TabType get selectedTab => _selectedTab;
  String get searchQuery => _searchQuery;
  int get todoCount => _filteredTodos.length;
  
  // Load all todos from repository with enhanced error handling and performance monitoring
  Future<void> loadTodos() async {
    await _performanceService.measureOperation(
      'TodoController.loadTodos',
      () async {
        try {
          _todos = _todoRepository.getAllTodos();
          await _applyFilters();
          print('TodoController: Loaded ${_todos.length} todos successfully');
        } catch (e) {
          print('TodoController: Error loading todos: $e');
          _todos = [];
          _filteredTodos = [];
          
          // If it's a storage error, we might want to attempt recovery
          if (e is StorageException) {
            throw e; // Re-throw storage exceptions for higher-level handling
          }
        }
      },
    );
  }

  // Create new todo with enhanced validation and error handling
  Future<bool> createTodo(Todo todo) async {
    try {
      // Pre-validate the todo
      final validationErrors = todo.validate();
      if (validationErrors.isNotEmpty) {
        throw ValidationException('Invalid todo data: ${validationErrors.join(', ')}');
      }

      // Check for duplicate titles (optional business rule)
      final existingTodos = _todos.where((t) => 
        t.title.toLowerCase().trim() == todo.title.toLowerCase().trim() && 
        !t.isCompleted
      ).toList();
      
      if (existingTodos.isNotEmpty) {
        print('TodoController: Warning - Similar task already exists: ${todo.title}');
        // Don't prevent creation, just log the warning
      }

      final success = await _todoRepository.createTodo(todo);
      if (success) {
        _invalidateCache(); // Clear caches before refresh
        await loadTodos(); // Refresh the list
        await _categoryRepository.refreshTaskCounts(); // Update category counts
        print('TodoController: Successfully created todo: ${todo.title}');
      } else {
        throw Exception('Repository failed to create todo');
      }
      return success;
    } catch (e) {
      print('TodoController: Error creating todo: $e');
      
      // Re-throw specific exceptions for better error handling
      if (e is ValidationException || e is StorageException) {
        throw e;
      }
      
      return false;
    }
  }

  // Update existing todo with validation
  Future<bool> updateTodo(Todo todo) async {
    try {
      final success = await _todoRepository.updateTodo(todo);
      if (success) {
        _invalidateCache(); // Clear caches before refresh
        await loadTodos(); // Refresh the list
        await _categoryRepository.refreshTaskCounts(); // Update category counts
      }
      return success;
    } catch (e) {
      print('TodoController: Error updating todo: $e');
      return false;
    }
  }

  // Delete todo with validation
  Future<bool> deleteTodo(String id) async {
    try {
      final success = await _todoRepository.deleteTodo(id);
      if (success) {
        _invalidateCache(); // Clear caches before refresh
        await loadTodos(); // Refresh the list
        await _categoryRepository.refreshTaskCounts(); // Update category counts
      }
      return success;
    } catch (e) {
      print('TodoController: Error deleting todo: $e');
      return false;
    }
  }

  // Toggle todo completion status
  Future<bool> toggleComplete(String id) async {
    try {
      final success = await _todoRepository.toggleTodoCompletion(id);
      if (success) {
        _invalidateCache(); // Clear caches before refresh
        await loadTodos(); // Refresh the list
        await _categoryRepository.refreshTaskCounts(); // Update category counts
      }
      return success;
    } catch (e) {
      print('TodoController: Error toggling todo completion: $e');
      return false;
    }
  }

  // Filter todos by tab (All, Today, Completed)
  Future<void> filterByTab(TabType tab) async {
    _selectedTab = tab;
    await _applyFilters();
  }

  // Filter todos by category
  Future<void> filterByCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;
    await _applyFilters();
  }

  // Search todos by query with optimization
  Future<void> searchTodos(String query) async {
    _searchQuery = query.trim();
    await _applyFilters();
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _selectedCategoryId = null;
    _selectedTab = TabType.all;
    _searchQuery = '';
    await _applyFilters();
  }

  // Clear category filter only (maintain tab and search)
  Future<void> clearCategoryFilter() async {
    _selectedCategoryId = null;
    await _applyFilters();
  }

  // Clear search filter only (maintain tab and category)
  Future<void> clearSearchFilter() async {
    _searchQuery = '';
    await _applyFilters();
  }

  // Reset to show all tasks (clear all filters)
  Future<void> showAllTasks() async {
    await clearFilters();
  }

  // Apply all active filters with enhanced logic and performance optimization
  Future<void> _applyFilters() async {
    await _performanceService.measureOperation(
      'TodoController.applyFilters',
      () async {
        var filtered = List<Todo>.from(_todos);

        // Apply search filter first if query exists
        if (_searchQuery.isNotEmpty) {
          filtered = await _searchService.searchTodos(
            todos: filtered,
            query: _searchQuery,
            categories: _categoryRepository.getAllCategories(),
          );
        }

        // Apply filters using optimized service
        bool? completionFilter;
        bool todayOnly = false;
        bool includeOverdue = false;

        switch (_selectedTab) {
          case TabType.today:
            todayOnly = true;
            includeOverdue = true; // Include overdue tasks for better UX
            completionFilter = false; // Only show incomplete tasks
            break;
          case TabType.completed:
            completionFilter = true; // Only show completed tasks
            break;
          case TabType.all:
            // No completion filter
            break;
        }

        filtered = await _searchService.filterTodos(
          todos: filtered,
          categoryId: _selectedCategoryId,
          isCompleted: completionFilter,
          todayOnly: todayOnly,
          includeOverdue: includeOverdue,
        );

        // Apply optimized sorting
        filtered = _searchService.optimizedSort(
          filtered,
          byPriority: true,
          byCompletion: _selectedTab != TabType.completed,
          byCreatedDate: true,
        );

        _filteredTodos = filtered;
      },
    );
  }

  // Get todos by specific criteria
  List<Todo> getTodosByCategory(String categoryId) {
    return _todoRepository.getTodosByCategory(categoryId);
  }

  List<Todo> getCompletedTodos() {
    return _todoRepository.getCompletedTodos();
  }

  List<Todo> getPendingTodos() {
    return _todoRepository.getPendingTodos();
  }

  List<Todo> getTodayTodos() {
    return _todoRepository.getTodayTodos();
  }

  // Get todo by ID
  Todo? getTodoById(String id) {
    return _todoRepository.getTodoById(id);
  }

  // Batch operations
  Future<bool> createMultipleTodos(List<Todo> todos) async {
    try {
      final success = await _todoRepository.createMultipleTodos(todos);
      if (success) {
        await loadTodos();
        await _categoryRepository.refreshTaskCounts();
      }
      return success;
    } catch (e) {
      print('TodoController: Error creating multiple todos: $e');
      return false;
    }
  }

  Future<bool> deleteMultipleTodos(List<String> ids) async {
    try {
      final success = await _todoRepository.deleteMultipleTodos(ids);
      if (success) {
        await loadTodos();
        await _categoryRepository.refreshTaskCounts();
      }
      return success;
    } catch (e) {
      print('TodoController: Error deleting multiple todos: $e');
      return false;
    }
  }

  // Mark all todos as completed
  Future<bool> markAllCompleted() async {
    try {
      final pendingTodos = getPendingTodos();
      for (final todo in pendingTodos) {
        final updatedTodo = todo.copyWith(isCompleted: true);
        await _todoRepository.updateTodo(updatedTodo);
      }
      await loadTodos();
      await _categoryRepository.refreshTaskCounts();
      return true;
    } catch (e) {
      print('TodoController: Error marking all todos as completed: $e');
      return false;
    }
  }

  // Delete all completed todos
  Future<bool> deleteAllCompleted() async {
    try {
      final completedTodos = getCompletedTodos();
      final ids = completedTodos.map((todo) => todo.id).toList();
      return await deleteMultipleTodos(ids);
    } catch (e) {
      print('TodoController: Error deleting all completed todos: $e');
      return false;
    }
  }

  // Get statistics for current filtered todos
  TaskStatistics getFilteredStatistics() {
    return TaskStatistics.fromTodos(_filteredTodos);
  }

  // Get overall statistics
  TaskStatistics getOverallStatistics() {
    return TaskStatistics.fromTodos(_todos);
  }

  // Validation methods
  bool isValidTodo(Todo todo) {
    return todo.isValid;
  }

  List<String> validateTodo(Todo todo) {
    return todo.validate();
  }

  // Check if there are any todos
  bool get hasTodos => _todos.isNotEmpty;
  bool get hasFilteredTodos => _filteredTodos.isNotEmpty;

  // Check if filters are active
  bool get hasActiveFilters => 
      _selectedCategoryId != null || 
      _selectedTab != TabType.all || 
      _searchQuery.isNotEmpty;

  // Check if category filter is active
  bool get hasCategoryFilter => _selectedCategoryId != null && _selectedCategoryId!.isNotEmpty;

  // Check if tab filter is active (not showing all)
  bool get hasTabFilter => _selectedTab != TabType.all;

  // Check if search filter is active
  bool get hasSearchFilter => _searchQuery.isNotEmpty;

  // Get filter description for UI
  String getFilterDescription() {
    final filters = <String>[];
    
    if (_selectedTab != TabType.all) {
      switch (_selectedTab) {
        case TabType.today:
          filters.add('Due Today');
          break;
        case TabType.completed:
          filters.add('Completed');
          break;
        case TabType.all:
          break;
      }
    }
    
    if (_selectedCategoryId != null) {
      final category = _categoryRepository.getCategoryById(_selectedCategoryId!);
      if (category != null) {
        filters.add(category.name);
      }
    }
    
    if (_searchQuery.isNotEmpty) {
      filters.add('Search: "$_searchQuery"');
    }
    
    return filters.isEmpty ? 'All Tasks' : filters.join(' • ');
  }

  // Refresh data from storage
  Future<void> refresh() async {
    await loadTodos();
  }

  // Initialize controller with performance monitoring
  Future<void> initialize() async {
    _performanceService.initialize();
    await loadTodos();
  }

  // Clean up any resources if needed
  void dispose() {
    _performanceService.dispose();
    _searchService.clearCache();
  }

  // Performance testing methods
  Future<Map<String, dynamic>> runPerformanceTests() async {
    final testService = PerformanceTestService();
    return await testService.runPerformanceTests();
  }

  Future<Map<String, dynamic>> runStressTest() async {
    final testService = PerformanceTestService();
    return await testService.runStressTest();
  }

  Map<String, dynamic> getPerformanceStats() {
    return _performanceService.getPerformanceStats();
  }

  List<String> getPerformanceRecommendations() {
    return _performanceService.getPerformanceRecommendations();
  }

  // Invalidate caches when data changes
  void _invalidateCache() {
    _searchService.invalidateCache();
  }
}