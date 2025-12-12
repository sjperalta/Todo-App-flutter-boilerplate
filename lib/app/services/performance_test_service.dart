import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../models/category.dart' as app_category;
import 'performance_service.dart';
import 'search_optimization_service.dart';


/// Service for performance testing with large datasets
class PerformanceTestService {
  static final PerformanceTestService _instance = PerformanceTestService._internal();
  factory PerformanceTestService() => _instance;
  PerformanceTestService._internal();

  final Random _random = Random();
  final List<String> _sampleTitles = [
    'Complete project proposal',
    'Review quarterly reports',
    'Schedule team meeting',
    'Update documentation',
    'Fix critical bug',
    'Implement new feature',
    'Conduct user research',
    'Optimize database queries',
    'Deploy to production',
    'Write unit tests',
    'Refactor legacy code',
    'Design user interface',
    'Analyze performance metrics',
    'Create backup strategy',
    'Update dependencies',
    'Configure monitoring',
    'Review security audit',
    'Plan sprint activities',
    'Conduct code review',
    'Update API documentation',
  ];

  final List<String> _sampleDescriptions = [
    'This task requires careful attention to detail and coordination with multiple stakeholders.',
    'High priority item that needs to be completed by end of week.',
    'Regular maintenance task that should be done monthly.',
    'Important for compliance and regulatory requirements.',
    'Customer-facing feature that will improve user experience.',
    'Technical debt that needs to be addressed soon.',
    'Research task to gather insights for future development.',
    'Performance optimization to improve system efficiency.',
    'Security-related task to protect user data.',
    'Documentation update to keep information current.',
  ];

  /// Generate test todos for performance testing
  List<Todo> generateTestTodos(int count) {
    return PerformanceService().measureSync(
      'PerformanceTest.generateTodos',
      () => _generateTodos(count),
    );
  }

  List<Todo> _generateTodos(int count) {
    final todos = <Todo>[];
    final categories = app_category.Category.getDefaultCategories();
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final todo = Todo(
        id: 'test_todo_$i',
        title: '${_sampleTitles[_random.nextInt(_sampleTitles.length)]} #$i',
        description: _random.nextBool() 
            ? _sampleDescriptions[_random.nextInt(_sampleDescriptions.length)]
            : null,
        categoryId: categories[_random.nextInt(categories.length)].id,
        priority: _random.nextInt(3) + 1, // 1-3
        isCompleted: _random.nextDouble() < 0.3, // 30% completed
        dueDate: _random.nextBool() 
            ? now.add(Duration(days: _random.nextInt(30) - 15)) // ±15 days
            : null,
        createdAt: now.subtract(Duration(days: _random.nextInt(365))), // Up to 1 year ago
      );
      todos.add(todo);
    }

    return todos;
  }

  /// Run comprehensive performance tests
  Future<Map<String, dynamic>> runPerformanceTests({
    int smallDatasetSize = 100,
    int mediumDatasetSize = 1000,
    int largeDatasetSize = 5000,
  }) async {
    if (kDebugMode) {
      print('Starting comprehensive performance tests...');
    }

    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, dynamic>{},
    };

    // Test with different dataset sizes
    for (final size in [smallDatasetSize, mediumDatasetSize, largeDatasetSize]) {
      if (kDebugMode) {
        print('Testing with $size todos...');
      }

      final testResults = await _runTestSuite(size);
      results['tests']['dataset_$size'] = testResults;
    }

    // Overall performance summary
    results['summary'] = PerformanceService().getPerformanceStats();
    results['recommendations'] = PerformanceService().getPerformanceRecommendations();

    if (kDebugMode) {
      print('Performance tests completed');
      _printTestResults(results);
    }

    return results;
  }

  /// Run test suite for specific dataset size
  Future<Map<String, dynamic>> _runTestSuite(int todoCount) async {
    final todos = generateTestTodos(todoCount);
    final categories = app_category.Category.getDefaultCategories();
    final searchService = SearchOptimizationService();
    
    final results = <String, dynamic>{
      'datasetSize': todoCount,
      'tests': <String, dynamic>{},
    };

    // Test 1: Filtering performance
    results['tests']['filtering'] = await _testFiltering(todos, searchService);

    // Test 2: Search performance
    results['tests']['search'] = await _testSearch(todos, searchService);

    // Test 3: Sorting performance
    results['tests']['sorting'] = await _testSorting(todos, searchService);

    // Test 4: Combined operations
    results['tests']['combined'] = await _testCombinedOperations(todos, searchService);

    // Test 5: Memory usage
    results['tests']['memory'] = await _testMemoryUsage(todos);

    return results;
  }

  /// Test filtering performance
  Future<Map<String, dynamic>> _testFiltering(
    List<Todo> todos,
    SearchOptimizationService searchService,
  ) async {
    final results = <String, dynamic>{};
    final categories = app_category.Category.getDefaultCategories();

    // Test category filtering
    final stopwatch1 = Stopwatch()..start();
    await searchService.filterTodos(
      todos: todos,
      categoryId: categories.first.id,
    );
    stopwatch1.stop();
    results['categoryFilter'] = stopwatch1.elapsedMilliseconds;

    // Test completion filtering
    final stopwatch2 = Stopwatch()..start();
    await searchService.filterTodos(
      todos: todos,
      isCompleted: false,
    );
    stopwatch2.stop();
    results['completionFilter'] = stopwatch2.elapsedMilliseconds;

    // Test priority filtering
    final stopwatch3 = Stopwatch()..start();
    await searchService.filterTodos(
      todos: todos,
      priority: 3,
    );
    stopwatch3.stop();
    results['priorityFilter'] = stopwatch3.elapsedMilliseconds;

    // Test today filtering
    final stopwatch4 = Stopwatch()..start();
    await searchService.filterTodos(
      todos: todos,
      todayOnly: true,
    );
    stopwatch4.stop();
    results['todayFilter'] = stopwatch4.elapsedMilliseconds;

    return results;
  }

  /// Test search performance
  Future<Map<String, dynamic>> _testSearch(
    List<Todo> todos,
    SearchOptimizationService searchService,
  ) async {
    final results = <String, dynamic>{};
    final searchQueries = ['project', 'meeting', 'bug', 'test', 'documentation'];

    for (final query in searchQueries) {
      final stopwatch = Stopwatch()..start();
      await searchService.searchTodos(todos: todos, query: query);
      stopwatch.stop();
      results['search_$query'] = stopwatch.elapsedMilliseconds;
    }

    // Test partial matches
    final stopwatch = Stopwatch()..start();
    await searchService.searchTodos(todos: todos, query: 'proj');
    stopwatch.stop();
    results['partialSearch'] = stopwatch.elapsedMilliseconds;

    return results;
  }

  /// Test sorting performance
  Future<Map<String, dynamic>> _testSorting(
    List<Todo> todos,
    SearchOptimizationService searchService,
  ) async {
    final results = <String, dynamic>{};

    // Test priority sorting
    final stopwatch1 = Stopwatch()..start();
    searchService.optimizedSort(todos, byPriority: true);
    stopwatch1.stop();
    results['prioritySort'] = stopwatch1.elapsedMilliseconds;

    // Test date sorting
    final stopwatch2 = Stopwatch()..start();
    searchService.optimizedSort(todos, byDueDate: true);
    stopwatch2.stop();
    results['dateSort'] = stopwatch2.elapsedMilliseconds;

    // Test combined sorting
    final stopwatch3 = Stopwatch()..start();
    searchService.optimizedSort(
      todos,
      byPriority: true,
      byDueDate: true,
      byCompletion: true,
    );
    stopwatch3.stop();
    results['combinedSort'] = stopwatch3.elapsedMilliseconds;

    return results;
  }

  /// Test combined operations
  Future<Map<String, dynamic>> _testCombinedOperations(
    List<Todo> todos,
    SearchOptimizationService searchService,
  ) async {
    final results = <String, dynamic>{};
    final categories = app_category.Category.getDefaultCategories();

    // Test filter + search + sort
    final stopwatch = Stopwatch()..start();
    // Filter by category
    final filtered = await searchService.filterTodos(
      todos: todos,
      categoryId: categories.first.id,
    );
    
    // Search within filtered results
    final searched = await searchService.searchTodos(
      todos: filtered,
      query: 'project',
    );
    
    // Sort the results
    searchService.optimizedSort(searched, byPriority: true);
    stopwatch.stop();
    results['filterSearchSort'] = stopwatch.elapsedMilliseconds;

    return results;
  }

  /// Test memory usage
  Future<Map<String, dynamic>> _testMemoryUsage(List<Todo> todos) async {
    final results = <String, dynamic>{};
    
    // This is a simplified memory test
    // In a real app, you'd use more sophisticated memory profiling
    results['todoCount'] = todos.length;
    results['estimatedMemoryMB'] = (todos.length * 1024) / (1024 * 1024); // Rough estimate
    
    return results;
  }

  /// Print test results in a readable format
  void _printTestResults(Map<String, dynamic> results) {
    print('\n=== Performance Test Results ===');
    
    final tests = results['tests'] as Map<String, dynamic>;
    
    for (final entry in tests.entries) {
      final datasetName = entry.key;
      final testData = entry.value as Map<String, dynamic>;
      
      print('\n$datasetName (${testData['datasetSize']} todos):');
      
      final testResults = testData['tests'] as Map<String, dynamic>;
      
      for (final testEntry in testResults.entries) {
        final testName = testEntry.key;
        final testValues = testEntry.value as Map<String, dynamic>;
        
        print('  $testName:');
        for (final valueEntry in testValues.entries) {
          print('    ${valueEntry.key}: ${valueEntry.value}ms');
        }
      }
    }
    
    print('\n=== Recommendations ===');
    final recommendations = results['recommendations'] as List<String>;
    for (final rec in recommendations) {
      print('- $rec');
    }
    
    print('===============================\n');
  }

  /// Run stress test with very large dataset
  Future<Map<String, dynamic>> runStressTest({
    int maxTodos = 10000,
    int iterations = 5,
  }) async {
    if (kDebugMode) {
      print('Starting stress test with up to $maxTodos todos...');
    }

    final results = <String, dynamic>{
      'maxTodos': maxTodos,
      'iterations': iterations,
      'results': <String, dynamic>{},
    };

    final searchService = SearchOptimizationService();
    
    for (int i = 1; i <= iterations; i++) {
      final todoCount = (maxTodos / iterations * i).round();
      final todos = generateTestTodos(todoCount);
      
      if (kDebugMode) {
        print('Stress test iteration $i: $todoCount todos');
      }

      final iterationResults = <String, dynamic>{};
      
      // Test critical operations
      final stopwatch1 = Stopwatch()..start();
      await searchService.filterTodos(todos: todos, isCompleted: false);
      stopwatch1.stop();
      iterationResults['filterMs'] = stopwatch1.elapsedMilliseconds;
      
      final stopwatch2 = Stopwatch()..start();
      await searchService.searchTodos(todos: todos, query: 'test');
      stopwatch2.stop();
      iterationResults['searchMs'] = stopwatch2.elapsedMilliseconds;
      
      final stopwatch3 = Stopwatch()..start();
      searchService.optimizedSort(todos, byPriority: true);
      stopwatch3.stop();
      iterationResults['sortMs'] = stopwatch3.elapsedMilliseconds;
      
      results['results']['iteration_$i'] = {
        'todoCount': todoCount,
        'performance': iterationResults,
      };
    }

    if (kDebugMode) {
      print('Stress test completed');
    }

    return results;
  }

  /// Clear test data and caches
  void cleanup() {
    SearchOptimizationService().clearCache();
    PerformanceService().clearHistory();
    
    if (kDebugMode) {
      print('Performance test cleanup completed');
    }
  }
}