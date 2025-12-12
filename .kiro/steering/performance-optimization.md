---
inclusion: always
---

# Performance Optimization Guidelines

## Performance Targets

### Response Time Goals
- UI interactions: < 16ms (60fps)
- Data operations: < 100ms for local storage
- Search/filtering: < 300ms for complex queries
- App startup: < 2 seconds cold start

### Memory Management
- Maximum 50MB heap usage for normal operation
- Efficient garbage collection with minimal pauses
- Proper disposal of resources and listeners

## List Performance Optimization

### Large Dataset Handling
```dart
// Use ListView.builder for efficient rendering
ListView.builder(
  itemCount: todos.length,
  itemBuilder: (context, index) {
    return TaskListTile(todo: todos[index]);
  },
);

// Implement virtual scrolling for 1000+ items
class OptimizedTaskList extends StatelessWidget {
  final List<Todo> todos;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      cacheExtent: 500, // Pre-render items for smooth scrolling
      itemBuilder: (context, index) => TaskListTile(todo: todos[index]),
    );
  }
}
```

### Lazy Loading Strategies
```dart
// Implement pagination for large datasets
class PaginatedTodoList {
  static const int pageSize = 50;
  
  Future<List<Todo>> loadPage(int page) async {
    final offset = page * pageSize;
    return await todoRepository.getTodos(
      limit: pageSize,
      offset: offset,
    );
  }
}
```

## Search and Filtering Optimization

### Debounced Search
```dart
// Prevent excessive filtering during user input
class SearchController {
  Timer? _debounceTimer;
  
  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      performSearch(query);
    });
  }
  
  void dispose() {
    _debounceTimer?.cancel();
  }
}
```

### Efficient Filtering
```dart
// Cache filter results to avoid recomputation
class FilterCache {
  final Map<String, List<Todo>> _cache = {};
  
  List<Todo> getFilteredTodos(String filterKey, List<Todo> todos) {
    if (_cache.containsKey(filterKey)) {
      return _cache[filterKey]!;
    }
    
    final filtered = todos.where((todo) => matchesFilter(todo, filterKey)).toList();
    _cache[filterKey] = filtered;
    return filtered;
  }
  
  void invalidateCache() {
    _cache.clear();
  }
}
```

### Search Indexing
```dart
// Build search index for faster text searches
class SearchIndex {
  final Map<String, Set<String>> _wordToTodoIds = {};
  
  void buildIndex(List<Todo> todos) {
    _wordToTodoIds.clear();
    
    for (final todo in todos) {
      final words = todo.title.toLowerCase().split(' ');
      for (final word in words) {
        _wordToTodoIds.putIfAbsent(word, () => <String>{}).add(todo.id);
      }
    }
  }
  
  Set<String> search(String query) {
    final words = query.toLowerCase().split(' ');
    Set<String>? results;
    
    for (final word in words) {
      final wordResults = _wordToTodoIds[word] ?? <String>{};
      results = results?.intersection(wordResults) ?? wordResults;
    }
    
    return results ?? <String>{};
  }
}
```

## Memory Optimization

### Efficient Data Structures
```dart
// Use appropriate data structures for different use cases
class TodoManager {
  // Fast lookups by ID
  final Map<String, Todo> _todoMap = {};
  
  // Maintain sorted lists for display
  final List<Todo> _sortedTodos = [];
  
  // Category-based indexing
  final Map<String, List<Todo>> _todosByCategory = {};
  
  void addTodo(Todo todo) {
    _todoMap[todo.id] = todo;
    _insertSorted(todo);
    _addToCategory(todo);
  }
}
```

### Resource Disposal
```dart
// Proper cleanup in controllers
class TodoController extends Controller {
  StreamSubscription? _todoSubscription;
  Timer? _autoSaveTimer;
  
  @override
  void dealloc() {
    _todoSubscription?.cancel();
    _autoSaveTimer?.cancel();
    super.dealloc();
  }
}
```

## Animation Performance

### Efficient Animations
```dart
// Use Transform widgets for better performance
class AnimatedTaskTile extends StatelessWidget {
  final Animation<double> animation;
  final Todo todo;
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOut))
      ),
      child: TaskListTile(todo: todo),
    );
  }
}
```

### Animation Optimization
```dart
// Reduce animation complexity for better performance
class OptimizedAnimations {
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  
  static const Curve defaultCurve = Curves.easeInOut;
  
  // Use hardware acceleration when possible
  static Widget buildOptimizedTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - animation.value)),
        child: child,
      ),
    );
  }
}
```

## Storage Performance

### Batch Operations
```dart
// Batch multiple operations for better performance
class BatchedStorageService {
  final List<Todo> _pendingUpdates = [];
  Timer? _batchTimer;
  
  void scheduleSave(Todo todo) {
    _pendingUpdates.add(todo);
    
    _batchTimer?.cancel();
    _batchTimer = Timer(Duration(milliseconds: 100), () {
      _flushBatch();
    });
  }
  
  Future<void> _flushBatch() async {
    if (_pendingUpdates.isEmpty) return;
    
    await todoRepository.saveAll(_pendingUpdates);
    _pendingUpdates.clear();
  }
}
```

### Efficient Queries
```dart
// Optimize Hive queries for better performance
class OptimizedTodoRepository {
  Future<List<Todo>> getTodosByCategory(String categoryId) async {
    // Use Hive's built-in filtering when possible
    return todoBox.values
        .where((todo) => todo.categoryId == categoryId)
        .toList();
  }
  
  Future<List<Todo>> getTodosWithPagination(int offset, int limit) async {
    return todoBox.values
        .skip(offset)
        .take(limit)
        .toList();
  }
}
```

## Performance Monitoring

### Built-in Monitoring
```dart
// Monitor performance metrics in development
class PerformanceMonitor {
  static void measureOperation(String name, Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      await operation();
    } finally {
      stopwatch.stop();
      print('$name took ${stopwatch.elapsedMilliseconds}ms');
    }
  }
  
  static void trackMemoryUsage() {
    // Monitor memory usage in development builds
    if (kDebugMode) {
      final info = ProcessInfo.currentRss;
      print('Memory usage: ${info ~/ 1024 ~/ 1024}MB');
    }
  }
}
```

### Performance Testing
```dart
// Automated performance testing
group('Performance Tests', () {
  test('should filter 1000 todos in under 100ms', () async {
    final todos = generateLargeTodoList(1000);
    final stopwatch = Stopwatch()..start();
    
    final filtered = todos.where((todo) => todo.categoryId == 'work').toList();
    
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
});
```

This performance optimization approach ensures the TaskFlow application remains responsive and efficient even with large datasets and complex operations.