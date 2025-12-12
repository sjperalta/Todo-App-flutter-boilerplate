# TaskFlow Todo App Design Document

## Overview

TaskFlow is a modern Flutter todo application built using the Nylo framework that provides users with an intuitive task management experience. The application features a clean, rounded UI design with mint green accents, category-based task organization, and comprehensive progress tracking. The design emphasizes visual hierarchy, smooth interactions, and data persistence through local storage.

## Architecture

The application follows Nylo's MVC architecture pattern with clear separation of concerns:

### Core Architecture Components

- **Models**: Data structures for Todo, Category, and Statistics
- **Controllers**: Business logic for task management, filtering, and statistics
- **Views**: Nylo pages for main interface, statistics, and modals
- **Storage Layer**: Hive database integration for local persistence
- **Routing**: Nylo routing system for navigation between screens

### Framework Integration

- **Nylo Framework**: Provides MVC structure, routing, state management, and UI components
- **Hive Storage**: Local database for offline-first task persistence
- **Flutter Material Design**: Base UI components with custom theming

## Components and Interfaces

### 1. Core Models

#### Todo Model
```dart
class Todo {
  String id;
  String title;
  String? description;
  DateTime? dueDate;
  String categoryId;
  bool isCompleted;
  int priority; // 1=Low, 2=Medium, 3=High
  DateTime createdAt;
  DateTime updatedAt;
}
```

#### Category Model
```dart
class Category {
  String id;
  String name;
  Color color;
  IconData icon;
  bool isDefault;
}
```

### 2. Controllers

#### TodoController
- `loadTodos()`: Fetch all tasks from storage
- `createTodo(Todo todo)`: Create new task
- `updateTodo(Todo todo)`: Update existing task
- `deleteTodo(String id)`: Remove task
- `toggleComplete(String id)`: Toggle completion status
- `filterByTab(TabType tab)`: Filter tasks by time period
- `filterByCategory(String categoryId)`: Filter by category

#### CategoryController
- `loadCategories()`: Load available categories
- `createCategory(Category category)`: Add new category
- `updateCategory(Category category)`: Modify category
- `deleteCategory(String id)`: Remove category
- `getCategoryColor(String id)`: Get category color

#### StatisticsController
- `calculateStats()`: Compute task statistics
- `getWeeklyProgress()`: Generate weekly completion data
- `getCompletionPercentage()`: Calculate overall progress

### 3. Pages (Nylo Pages)

#### HomePage
- Main task list interface
- Tab navigation (All, Today, Completed)
- Category filter chips
- Empty state display
- Floating action button

#### StatisticsPage
- Progress overview with circular indicator
- Task count metrics (Total, Done, Pending)
- Weekly progress bar chart
- Navigation back to main view

#### NewTaskModal (NyModal)
- Task creation form
- Input validation
- Category and priority selection
- Date picker integration

### 4. Widgets

#### TaskListTile
- Task display with checkbox
- Category indicator
- Priority visual cues
- Swipe actions for edit/delete

#### CategoryChip
- Rounded chip with category color
- Selection state management
- Tap handling for filtering

#### TaskEmptyState
- Centered icon and message
- Matches screenshot design exactly

#### ProgressChart
- Weekly bar chart component
- Animated progress indicators
- Responsive design

## Data Models

### Task Data Structure
```dart
class Todo extends NyModel {
  String id = generateId();
  String title = '';
  String? description;
  DateTime? dueDate;
  String categoryId = 'personal';
  bool isCompleted = false;
  int priority = 2; // Default to Medium
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  
  // Hive type adapter methods
  Map<String, dynamic> toJson();
  static Todo fromJson(Map<String, dynamic> json);
}
```

### Category Data Structure
```dart
class Category extends NyModel {
  String id;
  String name;
  Color color;
  IconData icon;
  bool isDefault;
  int taskCount = 0;
  
  static List<Category> getDefaultCategories() {
    return [
      Category(id: 'all', name: 'All', color: Color(0xFF32C7AE)),
      Category(id: 'personal', name: 'Personal', color: Color(0xFF32C7AE)),
      Category(id: 'work', name: 'Work', color: Color(0xFF8B5CF6)),
      Category(id: 'shopping', name: 'Shopping', color: Color(0xFFF97316)),
      Category(id: 'health', name: 'Health', color: Color(0xFF10B981)),
    ];
  }
}
```

### Statistics Data Structure
```dart
class TaskStatistics {
  int totalTasks;
  int completedTasks;
  int pendingTasks;
  double completionPercentage;
  Map<String, int> weeklyProgress;
  Map<String, int> categoryBreakdown;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, several properties can be consolidated to eliminate redundancy:
- Tab filtering properties (7.1, 7.2, 7.3) can be combined into a single comprehensive filtering property
- Task persistence properties (8.1, 8.3, 8.4) can be unified into a general persistence property
- Task display properties can be grouped by functionality

### Core Properties

**Property 1: Task list display consistency**
*For any* set of tasks, when displaying the task list, all tasks should appear with their checkbox, category indicator, and priority visual cues
**Validates: Requirements 1.4, 5.1**

**Property 2: Task creation validation**
*For any* task creation attempt, if the title field is empty or contains only whitespace, the system should reject the creation and maintain the current state
**Validates: Requirements 2.5**

**Property 3: Task creation completeness**
*For any* valid task data (non-empty title), when creating a task through the modal, the task should be added to the list and the modal should close
**Validates: Requirements 2.3**

**Property 4: Category filtering consistency**
*For any* selected category filter, all displayed tasks should belong to that category, and no tasks from other categories should be visible
**Validates: Requirements 3.3**

**Property 5: Tab filtering behavior**
*For any* tab selection (All, Today, Completed), only tasks matching the tab criteria should be displayed
**Validates: Requirements 7.1, 7.2, 7.3**

**Property 6: Task completion toggle**
*For any* task, when the checkbox is tapped, the completion status should toggle and the visual appearance should update accordingly
**Validates: Requirements 5.2, 5.3**

**Property 7: Statistics calculation accuracy**
*For any* set of tasks, the calculated statistics (total, completed, pending, percentage) should accurately reflect the current task states
**Validates: Requirements 6.4**

**Property 8: Data persistence round-trip**
*For any* task operation (create, update, delete), the changes should be immediately persisted to Hive storage and retrievable on app restart
**Validates: Requirements 8.1, 8.3, 8.4, 8.5**

**Property 9: Priority sorting consistency**
*For any* list of tasks with different priorities, when sorting is applied, higher priority tasks should appear before lower priority tasks
**Validates: Requirements 4.4**

**Property 10: Task editing preservation**
*For any* task being edited, when the edit modal opens, all original task data should be pre-filled and modifiable
**Validates: Requirements 10.2, 10.4**

**Property 11: Filter state persistence**
*For any* active category filter, when switching between tabs, the category filter selection should remain active
**Validates: Requirements 7.4**

**Property 12: Empty state display**
*For any* filter combination that results in zero tasks, the appropriate empty state should be displayed
**Validates: Requirements 7.5**

## Error Handling

### Input Validation
- **Empty Task Titles**: Prevent task creation with empty or whitespace-only titles
- **Invalid Dates**: Handle malformed date inputs gracefully
- **Category Validation**: Ensure selected categories exist in the system
- **Priority Bounds**: Validate priority values are within acceptable range (1-3)

### Storage Error Handling
- **Hive Initialization Failures**: Graceful fallback to in-memory storage
- **Disk Space Issues**: Alert user when storage operations fail
- **Data Corruption**: Implement data validation and recovery mechanisms
- **Migration Errors**: Handle schema changes between app versions

### UI Error States
- **Network Unavailable**: Show offline indicators (future enhancement)
- **Loading Failures**: Display retry options for failed operations
- **Form Validation**: Clear, contextual error messages for invalid inputs
- **Modal Dismissal**: Prevent accidental data loss with confirmation dialogs

### Performance Considerations
- **Large Task Lists**: Implement virtual scrolling for 1000+ tasks
- **Search Performance**: Debounce search inputs to prevent excessive filtering
- **Animation Performance**: Ensure 60fps animations on lower-end devices
- **Memory Management**: Proper disposal of controllers and listeners

## Testing Strategy

### Dual Testing Approach

The testing strategy combines unit testing and property-based testing to ensure comprehensive coverage:

**Unit Tests** verify specific examples, edge cases, and integration points:
- Modal opening/closing behavior
- Empty state display conditions
- Default category and priority values
- Specific UI element presence
- Button tap responses

**Property-Based Tests** verify universal properties across all inputs:
- Task filtering logic with random task sets
- Data persistence round-trips with generated task data
- Statistics calculations with varying task states
- Sorting behavior with random priority assignments
- Validation logic with generated input strings

### Property-Based Testing Configuration

- **Framework**: Use `test` package with `fake` for data generation
- **Iterations**: Minimum 100 iterations per property test
- **Test Tagging**: Each property test tagged with format: `**Feature: taskflow-todo-app, Property {number}: {property_text}**`
- **Data Generators**: Smart generators for valid/invalid task data, date ranges, and category combinations

### Testing Requirements

- Unit tests focus on specific examples and UI interactions
- Property tests validate universal behaviors across all valid inputs
- Integration tests verify end-to-end user workflows
- Widget tests ensure UI components render correctly
- Performance tests validate smooth operation with large datasets

Each correctness property must be implemented by a single property-based test, with tests placed as close to implementation as possible to catch errors early.