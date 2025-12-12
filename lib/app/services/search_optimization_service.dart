import 'dart:async';
import '../models/todo.dart';
import '../models/category.dart';
import 'performance_service.dart';

/// Optimized search and filtering service for large datasets
class SearchOptimizationService {
  static final SearchOptimizationService _instance = SearchOptimizationService._internal();
  factory SearchOptimizationService() => _instance;
  SearchOptimizationService._internal();

  // Caching for performance
  final Map<String, List<Todo>> _filterCache = {};
  final Map<String, List<Todo>> _searchCache = {};
  final Map<String, Map<String, Set<String>>> _searchIndexCache = {};
  
  // Debouncing for search
  Timer? _searchDebounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  
  // Cache management
  static const int _maxCacheSize = 50;
  static const Duration _cacheExpiry = Duration(minutes: 5);
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Clear all caches
  void clearCache() {
    _filterCache.clear();
    _searchCache.clear();
    _searchIndexCache.clear();
    _cacheTimestamps.clear();
  }

  /// Invalidate cache for specific operations
  void invalidateCache({String? prefix}) {
    if (prefix != null) {
      _filterCache.removeWhere((key, _) => key.startsWith(prefix));
      _searchCache.removeWhere((key, _) => key.startsWith(prefix));
      _searchIndexCache.removeWhere((key, _) => key.startsWith(prefix));
      _cacheTimestamps.removeWhere((key, _) => key.startsWith(prefix));
    } else {
      clearCache();
    }
  }

  /// Clean expired cache entries
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > _cacheExpiry)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _filterCache.remove(key);
      _searchCache.remove(key);
      _searchIndexCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Manage cache size
  void _manageCacheSize() {
    if (_filterCache.length > _maxCacheSize) {
      // Remove oldest entries
      final sortedEntries = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      final toRemove = sortedEntries.take(_filterCache.length - _maxCacheSize);
      for (final entry in toRemove) {
        _filterCache.remove(entry.key);
        _searchCache.remove(entry.key);
        _searchIndexCache.remove(entry.key);
        _cacheTimestamps.remove(entry.key);
      }
    }
  }

  /// Build search index for fast text searching
  Set<String> _buildSearchIndex(Todo todo) {
    final index = <String>{};
    
    // Add title words
    index.addAll(_tokenize(todo.title));
    
    // Add description words
    if (todo.description != null && todo.description!.isNotEmpty) {
      index.addAll(_tokenize(todo.description!));
    }
    
    // Add category name if available
    // Note: This would need category lookup, simplified for now
    
    return index;
  }

  /// Tokenize text for searching
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty && token.length > 1)
        .toList();
  }

  /// Optimized filtering with caching
  Future<List<Todo>> filterTodos({
    required List<Todo> todos,
    String? categoryId,
    bool? isCompleted,
    int? priority,
    DateTime? dueDate,
    bool todayOnly = false,
    bool includeOverdue = false,
  }) async {
    return PerformanceService().measureOperation(
      'SearchOptimization.filterTodos',
      () => _performFiltering(
        todos: todos,
        categoryId: categoryId,
        isCompleted: isCompleted,
        priority: priority,
        dueDate: dueDate,
        todayOnly: todayOnly,
        includeOverdue: includeOverdue,
      ),
    );
  }

  Future<List<Todo>> _performFiltering({
    required List<Todo> todos,
    String? categoryId,
    bool? isCompleted,
    int? priority,
    DateTime? dueDate,
    bool todayOnly = false,
    bool includeOverdue = false,
  }) async {
    // Create cache key
    final cacheKey = _createFilterCacheKey(
      categoryId: categoryId,
      isCompleted: isCompleted,
      priority: priority,
      dueDate: dueDate,
      todayOnly: todayOnly,
      includeOverdue: includeOverdue,
      todosHash: todos.length.hashCode, // Simple hash based on count
    );

    // Check cache
    if (_filterCache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      return _filterCache[cacheKey]!;
    }

    // Clean cache periodically
    _cleanExpiredCache();
    _manageCacheSize();

    // Perform filtering
    List<Todo> filtered = todos;

    // Use different strategies based on data size
    if (todos.length > 1000) {
      filtered = await _performLargeDatasetFiltering(
        todos,
        categoryId: categoryId,
        isCompleted: isCompleted,
        priority: priority,
        dueDate: dueDate,
        todayOnly: todayOnly,
        includeOverdue: includeOverdue,
      );
    } else {
      filtered = _performStandardFiltering(
        todos,
        categoryId: categoryId,
        isCompleted: isCompleted,
        priority: priority,
        dueDate: dueDate,
        todayOnly: todayOnly,
        includeOverdue: includeOverdue,
      );
    }

    // Cache result
    _filterCache[cacheKey] = filtered;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return filtered;
  }

  /// Standard filtering for smaller datasets
  List<Todo> _performStandardFiltering(
    List<Todo> todos, {
    String? categoryId,
    bool? isCompleted,
    int? priority,
    DateTime? dueDate,
    bool todayOnly = false,
    bool includeOverdue = false,
  }) {
    return todos.where((todo) {
      // Category filter
      if (categoryId != null && categoryId.isNotEmpty && todo.categoryId != categoryId) {
        return false;
      }

      // Completion filter
      if (isCompleted != null && todo.isCompleted != isCompleted) {
        return false;
      }

      // Priority filter
      if (priority != null && todo.priority != priority) {
        return false;
      }

      // Date filters
      if (todayOnly) {
        if (!todo.isDueToday && !(includeOverdue && todo.isOverdue)) {
          return false;
        }
      } else if (dueDate != null) {
        if (todo.dueDate == null) return false;
        final todoDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
        final filterDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
        if (!todoDate.isAtSameMomentAs(filterDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Optimized filtering for large datasets using parallel processing
  Future<List<Todo>> _performLargeDatasetFiltering(
    List<Todo> todos, {
    String? categoryId,
    bool? isCompleted,
    int? priority,
    DateTime? dueDate,
    bool todayOnly = false,
    bool includeOverdue = false,
  }) async {
    // Split into chunks for parallel processing
    const chunkSize = 250;
    final chunks = <List<Todo>>[];
    
    for (int i = 0; i < todos.length; i += chunkSize) {
      final end = (i + chunkSize < todos.length) ? i + chunkSize : todos.length;
      chunks.add(todos.sublist(i, end));
    }

    // Process chunks in parallel
    final futures = chunks.map((chunk) => Future(() => _performStandardFiltering(
      chunk,
      categoryId: categoryId,
      isCompleted: isCompleted,
      priority: priority,
      dueDate: dueDate,
      todayOnly: todayOnly,
      includeOverdue: includeOverdue,
    )));

    final results = await Future.wait(futures);
    
    // Combine results
    final filtered = <Todo>[];
    for (final result in results) {
      filtered.addAll(result);
    }

    return filtered;
  }

  /// Debounced search with caching and indexing
  Future<List<Todo>> searchTodos({
    required List<Todo> todos,
    required String query,
    List<Category>? categories,
  }) async {
    if (query.trim().isEmpty) return todos;

    final completer = Completer<List<Todo>>();
    
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_debounceDelay, () async {
      try {
        final result = await _performSearch(todos, query, categories);
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    return completer.future;
  }

  /// Perform optimized search
  Future<List<Todo>> _performSearch(
    List<Todo> todos,
    String query,
    List<Category>? categories,
  ) async {
    return PerformanceService().measureOperation(
      'SearchOptimization.search',
      () => _executeSearch(todos, query, categories),
    );
  }

  Future<List<Todo>> _executeSearch(
    List<Todo> todos,
    String query,
    List<Category>? categories,
  ) async {
    final normalizedQuery = query.toLowerCase().trim();
    final cacheKey = 'search_${normalizedQuery}_${todos.length.hashCode}';

    // Check cache
    if (_searchCache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    // Clean cache
    _cleanExpiredCache();
    _manageCacheSize();

    List<Todo> results;

    if (todos.length > 500) {
      // Use indexed search for large datasets
      results = await _performIndexedSearch(todos, normalizedQuery, categories);
    } else {
      // Use simple search for smaller datasets
      results = _performSimpleSearch(todos, normalizedQuery, categories);
    }

    // Cache result
    _searchCache[cacheKey] = results;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return results;
  }

  /// Simple search for smaller datasets
  List<Todo> _performSimpleSearch(
    List<Todo> todos,
    String query,
    List<Category>? categories,
  ) {
    final queryTokens = _tokenize(query);
    if (queryTokens.isEmpty) return todos;

    return todos.where((todo) {
      // Search in title
      if (todo.title.toLowerCase().contains(query)) return true;
      
      // Search in description
      if (todo.description != null && 
          todo.description!.toLowerCase().contains(query)) return true;
      
      // Search in tokenized content
      final todoTokens = _buildSearchIndex(todo);
      return queryTokens.any((queryToken) => 
          todoTokens.any((todoToken) => todoToken.contains(queryToken)));
    }).toList();
  }

  /// Indexed search for large datasets
  Future<List<Todo>> _performIndexedSearch(
    List<Todo> todos,
    String query,
    List<Category>? categories,
  ) async {
    final queryTokens = _tokenize(query);
    if (queryTokens.isEmpty) return todos;

    // Build or retrieve search index
    final indexCacheKey = 'index_${todos.length.hashCode}';
    Map<String, Set<String>> searchIndex;
    
    if (_searchIndexCache.containsKey(indexCacheKey) && _isCacheValid(indexCacheKey)) {
      searchIndex = _searchIndexCache[indexCacheKey]!;
    } else {
      searchIndex = <String, Set<String>>{};
      for (final todo in todos) {
        searchIndex[todo.id] = _buildSearchIndex(todo);
      }
      _searchIndexCache[indexCacheKey] = searchIndex;
      _cacheTimestamps[indexCacheKey] = DateTime.now();
    }

    // Perform search using index
    final matchingIds = <String>{};
    
    for (final entry in searchIndex.entries) {
      final todoId = entry.key;
      final todoTokens = entry.value;
      
      // Check for exact query match first (higher relevance)
      final todo = todos.firstWhere((t) => t.id == todoId);
      if (todo.title.toLowerCase().contains(query) ||
          (todo.description?.toLowerCase().contains(query) ?? false)) {
        matchingIds.add(todoId);
        continue;
      }
      
      // Check for token matches
      if (queryTokens.any((queryToken) => 
          todoTokens.any((todoToken) => todoToken.contains(queryToken)))) {
        matchingIds.add(todoId);
      }
    }

    // Return matching todos in original order
    return todos.where((todo) => matchingIds.contains(todo.id)).toList();
  }

  /// Create cache key for filtering
  String _createFilterCacheKey({
    String? categoryId,
    bool? isCompleted,
    int? priority,
    DateTime? dueDate,
    bool todayOnly = false,
    bool includeOverdue = false,
    required int todosHash,
  }) {
    return 'filter_${categoryId ?? 'null'}_${isCompleted ?? 'null'}_'
           '${priority ?? 'null'}_${dueDate?.millisecondsSinceEpoch ?? 'null'}_'
           '${todayOnly}_${includeOverdue}_$todosHash';
  }

  /// Check if cache entry is valid
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'filterCacheSize': _filterCache.length,
      'searchCacheSize': _searchCache.length,
      'indexCacheSize': _searchIndexCache.length,
      'totalCacheEntries': _cacheTimestamps.length,
      'maxCacheSize': _maxCacheSize,
      'cacheExpiryMinutes': _cacheExpiry.inMinutes,
    };
  }

  /// Optimize sorting for large datasets
  List<Todo> optimizedSort(List<Todo> todos, {
    bool byPriority = true,
    bool byDueDate = false,
    bool byCreatedDate = false,
    bool byCompletion = true,
    bool ascending = false,
  }) {
    return PerformanceService().measureSync(
      'SearchOptimization.sort',
      () => _performOptimizedSort(
        todos,
        byPriority: byPriority,
        byDueDate: byDueDate,
        byCreatedDate: byCreatedDate,
        byCompletion: byCompletion,
        ascending: ascending,
      ),
    );
  }

  List<Todo> _performOptimizedSort(
    List<Todo> todos, {
    bool byPriority = true,
    bool byDueDate = false,
    bool byCreatedDate = false,
    bool byCompletion = true,
    bool ascending = false,
  }) {
    if (todos.length <= 1) return todos;

    // Use different sorting strategies based on size
    if (todos.length > 1000) {
      return _performMergeSort(todos, byPriority, byDueDate, byCreatedDate, byCompletion, ascending);
    } else {
      return _performQuickSort(todos, byPriority, byDueDate, byCreatedDate, byCompletion, ascending);
    }
  }

  /// Quick sort for medium datasets
  List<Todo> _performQuickSort(
    List<Todo> todos,
    bool byPriority,
    bool byDueDate,
    bool byCreatedDate,
    bool byCompletion,
    bool ascending,
  ) {
    final sorted = List<Todo>.from(todos);
    sorted.sort((a, b) => _compareTodos(a, b, byPriority, byDueDate, byCreatedDate, byCompletion, ascending));
    return sorted;
  }

  /// Merge sort for large datasets (more stable)
  List<Todo> _performMergeSort(
    List<Todo> todos,
    bool byPriority,
    bool byDueDate,
    bool byCreatedDate,
    bool byCompletion,
    bool ascending,
  ) {
    if (todos.length <= 1) return todos;

    final mid = todos.length ~/ 2;
    final left = _performMergeSort(
      todos.sublist(0, mid),
      byPriority, byDueDate, byCreatedDate, byCompletion, ascending,
    );
    final right = _performMergeSort(
      todos.sublist(mid),
      byPriority, byDueDate, byCreatedDate, byCompletion, ascending,
    );

    return _merge(left, right, byPriority, byDueDate, byCreatedDate, byCompletion, ascending);
  }

  /// Merge two sorted lists
  List<Todo> _merge(
    List<Todo> left,
    List<Todo> right,
    bool byPriority,
    bool byDueDate,
    bool byCreatedDate,
    bool byCompletion,
    bool ascending,
  ) {
    final result = <Todo>[];
    int i = 0, j = 0;

    while (i < left.length && j < right.length) {
      final comparison = _compareTodos(
        left[i], right[j],
        byPriority, byDueDate, byCreatedDate, byCompletion, ascending,
      );
      
      if (comparison <= 0) {
        result.add(left[i++]);
      } else {
        result.add(right[j++]);
      }
    }

    result.addAll(left.sublist(i));
    result.addAll(right.sublist(j));
    return result;
  }

  /// Compare two todos for sorting
  int _compareTodos(
    Todo a,
    Todo b,
    bool byPriority,
    bool byDueDate,
    bool byCreatedDate,
    bool byCompletion,
    bool ascending,
  ) {
    int result = 0;

    // First sort by completion status
    if (byCompletion && result == 0) {
      result = a.isCompleted.toString().compareTo(b.isCompleted.toString());
    }

    // Then by priority
    if (byPriority && result == 0) {
      result = b.priority.compareTo(a.priority); // Higher priority first
    }

    // Then by due date
    if (byDueDate && result == 0) {
      if (a.dueDate == null && b.dueDate == null) {
        result = 0;
      } else if (a.dueDate == null) {
        result = 1; // No due date goes last
      } else if (b.dueDate == null) {
        result = -1; // No due date goes last
      } else {
        result = a.dueDate!.compareTo(b.dueDate!);
      }
    }

    // Finally by created date
    if (byCreatedDate && result == 0) {
      result = b.createdAt.compareTo(a.createdAt); // Newer first
    }

    return result;
  }
}