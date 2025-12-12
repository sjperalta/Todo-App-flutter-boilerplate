---
inclusion: always
---

# Flutter Nylo Framework Development Guidelines

## Project Overview

This is a TaskFlow todo application built with Flutter using the Nylo micro-framework. Nylo provides MVC architecture, routing, state management, and UI components following Laravel-inspired patterns.

## Framework-Specific Patterns

### Nylo MVC Structure

**Controllers**: Extend `Controller` class and handle business logic
```dart
class TodoController extends Controller {
  @override
  construct(BuildContext context) {
    // Initialize services and dependencies
  }
}
```

**Pages**: Extend `NyStatefulWidget` with typed controller
```dart
class HomePage extends NyStatefulWidget<HomeController> {
  static RouteView path = ("/home", (_) => HomePage());
  HomePage() : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> {
  @override
  get init => () async {
    // Page initialization logic
  };
}
```

**Forms**: Extend `NyFormData` for form handling
```dart
class NewTaskForm extends NyFormData {
  NewTaskForm({required BuildContext context}) : super(context);
  
  // Form fields and validation
}
```

### Data Access Patterns

**Accessing Controller Data**:
- Use `widget.controller` to access controller methods
- Use `data()` or `widget.data()` to get route data
- Use `queryParameters()` for URL parameters

**Navigation**:
- Use `routeTo(PageName.path)` for navigation
- Use `pop()` to go back
- Pass data with `routeTo(PageName.path, data: object)`

### Storage Integration

**Hive Setup**: Models must extend appropriate base classes and include type adapters
```dart
@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String id;
  
  // Include toJson/fromJson for Nylo compatibility
}
```

## Code Organization

### Directory Structure
- `lib/app/controllers/` - Business logic controllers
- `lib/app/models/` - Data models with Hive adapters
- `lib/app/services/` - Shared services (storage, validation, etc.)
- `lib/app/repositories/` - Data access layer
- `lib/resources/pages/` - UI pages extending NyStatefulWidget
- `lib/resources/widgets/` - Reusable UI components
- `lib/routes/` - Route definitions

### Import Conventions
- Use relative imports for project files: `import '/app/models/todo.dart'`
- Prefix Nylo imports: `import 'package:nylo_framework/nylo_framework.dart'`
- Group imports: Flutter SDK, packages, project files

## Development Best Practices

### State Management
- Use Nylo's built-in state management through controllers
- Access controller state via `widget.controller`
- Update UI by calling `setState()` in page classes

### Error Handling
- Implement try-catch blocks in controller methods
- Use Nylo's error handling patterns
- Provide user-friendly error messages

### Performance
- Use `NyPage` lifecycle methods appropriately
- Dispose of resources in controller `dealloc()` method
- Implement efficient list rendering for large datasets

### Testing
- Test controllers independently of UI
- Use Nylo's testing utilities
- Mock services and repositories for unit tests

## Common Patterns

### Loading States
```dart
bool _isLoading = false;

void _loadData() async {
  setState(() => _isLoading = true);
  try {
    await widget.controller.loadTodos();
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### Form Validation
```dart
class TaskForm extends NyFormData {
  validate() => {
    "title": "required|min:1",
    "category": "required",
  };
}
```

### Modal Sheets
```dart
void _showModal() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => NewTaskModal(),
  );
}
```

This steering document ensures consistent Nylo framework usage throughout the TaskFlow application development.