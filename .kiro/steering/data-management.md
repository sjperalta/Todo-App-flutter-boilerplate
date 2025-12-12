---
inclusion: always
---

# Data Management Guidelines

## Storage Architecture

### Hive Integration
- Use Hive for local data persistence with offline-first approach
- All models must include proper type adapters for Hive serialization
- Initialize Hive boxes in bootstrap process before app starts

### Repository Pattern
```dart
// Repository interface for consistent data access
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
}
```

### Model Requirements
```dart
// All models must extend HiveObject and include:
@HiveType(typeId: uniqueId)
class ModelName extends HiveObject {
  @HiveField(0)
  String id;
  
  // Nylo compatibility methods
  Map<String, dynamic> toJson();
  static ModelName fromJson(Map<String, dynamic> json);
}
```

## Data Flow Patterns

### Controller → Repository → Storage
1. Controllers handle business logic and UI state
2. Repositories abstract data access and caching
3. Storage services manage Hive operations and error handling

### State Management
- Controllers maintain UI state and trigger updates
- Use `setState()` in pages to refresh UI after data changes
- Implement loading states for async operations

### Error Handling
```dart
// Consistent error handling pattern
try {
  final result = await repository.operation();
  // Handle success
} on StorageException catch (e) {
  // Handle storage-specific errors
} catch (e) {
  // Handle general errors
  showErrorMessage(context, 'Operation failed');
}
```

## Data Validation

### Input Validation
- Validate all user inputs before saving to storage
- Use Nylo form validation patterns for consistent UX
- Sanitize text inputs to prevent data corruption

### Business Rules
```dart
// Example validation rules
class TodoValidation {
  static bool isValidTitle(String title) {
    return title.trim().isNotEmpty && title.length <= 100;
  }
  
  static bool isValidPriority(int priority) {
    return priority >= 1 && priority <= 3;
  }
}
```

### Data Integrity
- Ensure referential integrity between todos and categories
- Validate date ranges and constraints
- Handle orphaned data gracefully

## Performance Considerations

### Efficient Queries
- Use Hive's built-in indexing for frequently queried fields
- Implement pagination for large datasets
- Cache frequently accessed data in memory

### Memory Management
```dart
// Proper resource disposal
class TodoRepository {
  Box<Todo>? _todoBox;
  
  Future<void> dispose() async {
    await _todoBox?.close();
  }
}
```

### Background Operations
- Perform heavy data operations off the main thread when possible
- Use isolates for complex data processing
- Implement proper loading indicators for long operations

## Data Migration

### Schema Changes
```dart
// Handle model evolution gracefully
class TodoMigration {
  static Future<void> migrateToV2() async {
    // Migration logic for schema changes
  }
}
```

### Backup and Recovery
- Implement data export functionality
- Provide data recovery mechanisms
- Handle corrupted data gracefully

## Testing Strategy

### Repository Testing
- Mock Hive boxes for unit testing
- Test CRUD operations independently
- Verify error handling scenarios

### Data Integrity Testing
- Test constraint validation
- Verify referential integrity
- Test edge cases and boundary conditions

This data management approach ensures reliable, performant, and maintainable data handling throughout the TaskFlow application.