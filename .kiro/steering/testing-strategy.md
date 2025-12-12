---
inclusion: always
---

# Testing Strategy Guidelines

## Testing Philosophy

### Dual Testing Approach
- **Unit Tests**: Verify specific examples, edge cases, and integration points
- **Property-Based Tests**: Validate universal behaviors across all valid inputs
- **Integration Tests**: End-to-end workflow validation

### Test Organization
```dart
// Test file structure
test/
├── unit/
│   ├── models/
│   ├── controllers/
│   └── services/
├── integration/
│   └── workflows/
└── property/
    └── correctness/
```

## Property-Based Testing

### Framework Setup
```dart
import 'package:test/test.dart';
import 'package:fake/fake.dart';

// Property test template
void main() {
  group('Property Tests', () {
    test('**Feature: taskflow-todo-app, Property 1: Task list display consistency**', () {
      // Generate random task sets and verify display consistency
    });
  });
}
```

### Test Data Generation
```dart
// Smart generators for test data
class TodoGenerator {
  static Todo generateValidTodo() {
    return Todo(
      id: fake.guid.guid(),
      title: fake.lorem.sentence(),
      categoryId: fake.randomGenerator.element(['personal', 'work', 'shopping', 'health']),
      priority: fake.randomGenerator.integer(3, min: 1),
    );
  }
  
  static List<Todo> generateTodoList(int count) {
    return List.generate(count, (_) => generateValidTodo());
  }
}
```

### Property Test Requirements
- Minimum 100 iterations per property test
- Tag format: `**Feature: taskflow-todo-app, Property {number}: {property_text}**`
- Test universal behaviors, not specific examples

## Unit Testing Patterns

### Controller Testing
```dart
// Test controllers independently of UI
group('TodoController Tests', () {
  late TodoController controller;
  late MockTodoRepository mockRepository;
  
  setUp(() {
    mockRepository = MockTodoRepository();
    controller = TodoController();
    // Inject mock dependencies
  });
  
  test('should create todo with valid data', () async {
    // Test specific controller behavior
  });
});
```

### Widget Testing
```dart
// Test UI components in isolation
testWidgets('TaskListTile displays correctly', (tester) async {
  final todo = TodoGenerator.generateValidTodo();
  
  await tester.pumpWidget(
    MaterialApp(home: TaskListTile(todo: todo))
  );
  
  expect(find.text(todo.title), findsOneWidget);
  expect(find.byType(Checkbox), findsOneWidget);
});
```

### Service Testing
```dart
// Test services with mocked dependencies
group('StorageService Tests', () {
  test('should handle storage failures gracefully', () async {
    // Test error scenarios and recovery
  });
});
```

## Integration Testing

### End-to-End Workflows
```dart
// Test complete user journeys
testWidgets('Complete task creation workflow', (tester) async {
  await tester.pumpWidget(TaskFlowApp());
  
  // Navigate through complete workflow
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  
  await tester.enterText(find.byKey(Key('title_field')), 'Test Task');
  await tester.tap(find.text('Add Task'));
  await tester.pumpAndSettle();
  
  expect(find.text('Test Task'), findsOneWidget);
});
```

### Performance Testing
```dart
// Test app performance with large datasets
group('Performance Tests', () {
  test('should handle 1000+ tasks efficiently', () async {
    final largeTodoList = TodoGenerator.generateTodoList(1000);
    // Measure performance metrics
  });
});
```

## Test Coverage Requirements

### Critical Path Coverage
- All CRUD operations (Create, Read, Update, Delete)
- Data persistence and retrieval
- Form validation and error handling
- Filtering and sorting logic
- Statistics calculation accuracy

### Edge Case Testing
```dart
// Test boundary conditions and edge cases
group('Edge Cases', () {
  test('should handle empty task lists', () {
    // Test empty state behavior
  });
  
  test('should validate maximum title length', () {
    // Test input validation boundaries
  });
  
  test('should handle invalid date inputs', () {
    // Test malformed data handling
  });
});
```

### Error Scenario Testing
```dart
// Test error handling and recovery
group('Error Handling', () {
  test('should recover from storage failures', () {
    // Test storage error recovery
  });
  
  test('should handle network unavailable states', () {
    // Test offline functionality
  });
});
```

## Mock and Fake Strategies

### Repository Mocking
```dart
class MockTodoRepository extends Mock implements TodoRepository {
  @override
  Future<List<Todo>> getAll() async {
    return TodoGenerator.generateTodoList(5);
  }
}
```

### Service Mocking
```dart
class MockStorageService extends Mock implements StorageService {
  bool shouldFail = false;
  
  @override
  Future<void> save(String key, dynamic value) async {
    if (shouldFail) throw StorageException('Mock failure');
  }
}
```

## Test Execution Strategy

### Continuous Testing
- Run unit tests on every code change
- Execute integration tests before commits
- Run full test suite in CI/CD pipeline

### Test Reporting
- Maintain test coverage above 80%
- Track test execution time and performance
- Generate detailed test reports for analysis

### Test Maintenance
- Update tests when requirements change
- Refactor tests to maintain readability
- Remove obsolete tests and add new coverage

This testing strategy ensures comprehensive validation of the TaskFlow application's correctness, performance, and reliability.