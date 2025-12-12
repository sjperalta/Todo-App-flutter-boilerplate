import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/models/todo.dart';
import 'package:flutter_app/app/models/category.dart';
import 'package:flutter_app/app/services/performance_service.dart';
import 'package:flutter_app/app/services/search_optimization_service.dart';
import 'package:flutter_app/app/services/performance_test_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Performance Optimization Tests', () {
    late PerformanceService performanceService;
    late SearchOptimizationService searchService;
    late PerformanceTestService testService;

    setUp(() {
      performanceService = PerformanceService();
      searchService = SearchOptimizationService();
      testService = PerformanceTestService();
      
      performanceService.initialize();
    });

    tearDown(() {
      performanceService.dispose();
      searchService.clearCache();
      testService.cleanup();
    });

    group('PerformanceService Tests', () {
      test('should measure operation performance', () async {
        final result = await performanceService.measureOperation(
          'test_operation',
          () async {
            await Future.delayed(const Duration(milliseconds: 10));
            return 'test_result';
          },
        );

        expect(result, equals('test_result'));
        
        final stats = performanceService.getPerformanceStats();
        expect(stats['operations'], isNotNull);
        expect(stats['operations']['test_operation'], isNotNull);
      });

      test('should measure synchronous operations', () {
        final result = performanceService.measureSync(
          'sync_test',
          () => 'sync_result',
        );

        expect(result, equals('sync_result'));
        
        final stats = performanceService.getPerformanceStats();
        expect(stats['operations']['sync_test'], isNotNull);
      });

      test('should provide performance recommendations', () {
        // Simulate some operations
        performanceService.measureSync('fast_op', () => 'fast');
        
        final recommendations = performanceService.getPerformanceRecommendations();
        expect(recommendations, isNotEmpty);
      });

      test('should clear performance history', () {
        performanceService.measureSync('test_op', () => 'test');
        
        var stats = performanceService.getPerformanceStats();
        expect(stats['operations'], isNotEmpty);
        
        performanceService.clearHistory();
        
        stats = performanceService.getPerformanceStats();
        expect(stats['operations'], isEmpty);
      });
    });

    group('SearchOptimizationService Tests', () {
      late List<Todo> testTodos;
      late List<Category> testCategories;

      setUp(() {
        testCategories = Category.getDefaultCategories();
        testTodos = _generateTestTodos(100);
      });

      test('should filter todos efficiently', () async {
        final filtered = await searchService.filterTodos(
          todos: testTodos,
          categoryId: testCategories.first.id,
        );

        expect(filtered.length, lessThanOrEqualTo(testTodos.length));
        expect(
          filtered.every((todo) => todo.categoryId == testCategories.first.id),
          isTrue,
        );
      });

      test('should search todos with caching', () async {
        // First search
        final result1 = await searchService.searchTodos(
          todos: testTodos,
          query: 'test',
        );

        // Second search (should use cache)
        final result2 = await searchService.searchTodos(
          todos: testTodos,
          query: 'test',
        );

        expect(result1.length, equals(result2.length));
        
        final cacheStats = searchService.getCacheStats();
        expect(cacheStats['searchCacheSize'], greaterThan(0));
      });

      test('should sort todos optimally', () {
        // Create specific test data with known priorities
        final specificTodos = [
          Todo(id: '1', title: 'Low Priority', priority: 1, categoryId: 'test'),
          Todo(id: '2', title: 'High Priority', priority: 3, categoryId: 'test'),
          Todo(id: '3', title: 'Medium Priority', priority: 2, categoryId: 'test'),
        ];
        
        final sorted = searchService.optimizedSort(
          specificTodos,
          byPriority: true,
        );

        expect(sorted.length, equals(specificTodos.length));
        
        // Check if sorted by priority (high to low)
        expect(sorted[0].priority, equals(3)); // High priority first
        expect(sorted[1].priority, equals(2)); // Medium priority second
        expect(sorted[2].priority, equals(1)); // Low priority last
      });

      test('should handle large datasets efficiently', () async {
        final largeTodos = _generateTestTodos(1000);
        
        final stopwatch = Stopwatch()..start();
        
        final filtered = await searchService.filterTodos(
          todos: largeTodos,
          isCompleted: false,
        );
        
        stopwatch.stop();
        
        expect(filtered.length, lessThanOrEqualTo(largeTodos.length));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
      });

      test('should cache filter results', () async {
        // First filter
        await searchService.filterTodos(
          todos: testTodos,
          categoryId: testCategories.first.id,
        );

        final cacheStats = searchService.getCacheStats();
        expect(cacheStats['filterCacheSize'], greaterThan(0));
      });

      test('should invalidate cache correctly', () async {
        // Create cache entries
        await searchService.filterTodos(todos: testTodos, isCompleted: false);
        await searchService.searchTodos(todos: testTodos, query: 'test');

        var cacheStats = searchService.getCacheStats();
        expect(cacheStats['totalCacheEntries'], greaterThan(0));

        // Clear cache
        searchService.clearCache();

        cacheStats = searchService.getCacheStats();
        expect(cacheStats['totalCacheEntries'], equals(0));
      });
    });

    group('PerformanceTestService Tests', () {
      test('should generate test todos', () {
        final todos = testService.generateTestTodos(50);
        
        expect(todos.length, equals(50));
        expect(todos.every((todo) => todo.id.startsWith('test_todo_')), isTrue);
        expect(todos.every((todo) => todo.title.isNotEmpty), isTrue);
      });

      test('should run performance tests', () async {
        final results = await testService.runPerformanceTests(
          smallDatasetSize: 10,
          mediumDatasetSize: 50,
          largeDatasetSize: 100,
        );

        expect(results['tests'], isNotNull);
        expect(results['summary'], isNotNull);
        expect(results['recommendations'], isNotNull);
        
        final tests = results['tests'] as Map<String, dynamic>;
        expect(tests.keys, contains('dataset_10'));
        expect(tests.keys, contains('dataset_50'));
        expect(tests.keys, contains('dataset_100'));
      });

      test('should run stress test', () async {
        final results = await testService.runStressTest(
          maxTodos: 500,
          iterations: 2,
        );

        expect(results['maxTodos'], equals(500));
        expect(results['iterations'], equals(2));
        expect(results['results'], isNotNull);
        
        final testResults = results['results'] as Map<String, dynamic>;
        expect(testResults.keys, contains('iteration_1'));
        expect(testResults.keys, contains('iteration_2'));
      });
    });

    group('Integration Tests', () {
      test('should handle complete workflow efficiently', () async {
        final todos = testService.generateTestTodos(500);
        
        // Measure complete workflow
        final result = await performanceService.measureOperation(
          'complete_workflow',
          () async {
            // Filter
            final filtered = await searchService.filterTodos(
              todos: todos,
              isCompleted: false,
            );
            
            // Search
            final searched = await searchService.searchTodos(
              todos: filtered,
              query: 'test',
            );
            
            // Sort
            return searchService.optimizedSort(searched, byPriority: true);
          },
        );

        expect(result, isNotNull);
        expect(result.length, lessThanOrEqualTo(todos.length));
        
        final stats = performanceService.getPerformanceStats();
        expect(stats['operations']['complete_workflow'], isNotNull);
      });

      test('should maintain performance with repeated operations', () async {
        final todos = testService.generateTestTodos(200);
        final times = <Duration>[];

        // Run same operation multiple times
        for (int i = 0; i < 5; i++) {
          final stopwatch = Stopwatch()..start();
          
          await searchService.filterTodos(
            todos: todos,
            categoryId: Category.getDefaultCategories().first.id,
          );
          
          stopwatch.stop();
          times.add(stopwatch.elapsed);
        }

        // Performance should improve or stay consistent due to caching
        final firstTime = times.first.inMilliseconds;
        final lastTime = times.last.inMilliseconds;
        
        expect(lastTime, lessThanOrEqualTo(firstTime * 2)); // Allow some variance
      });
    });
  });
}

/// Helper function to generate test todos
List<Todo> _generateTestTodos(int count) {
  final todos = <Todo>[];
  final categories = Category.getDefaultCategories();
  final now = DateTime.now();

  for (int i = 0; i < count; i++) {
    final todo = Todo(
      id: 'test_todo_$i',
      title: 'Test Todo $i',
      description: i % 3 == 0 ? 'Test description for todo $i' : null,
      categoryId: categories[i % categories.length].id,
      priority: (i % 3) + 1,
      isCompleted: i % 4 == 0,
      dueDate: i % 5 == 0 ? now.add(Duration(days: i % 10)) : null,
      createdAt: now.subtract(Duration(days: i % 30)),
    );
    todos.add(todo);
  }

  return todos;
}