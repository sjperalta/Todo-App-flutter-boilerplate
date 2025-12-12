import 'package:flutter_test/flutter_test.dart';
import '../lib/app/controllers/todo_controller.dart';
import '../lib/app/models/todo.dart';

void main() {
  group('TodoController Filtering Logic Tests', () {
    test('should validate TabType enum values', () {
      expect(TabType.values.length, 3);
      expect(TabType.values, contains(TabType.all));
      expect(TabType.values, contains(TabType.today));
      expect(TabType.values, contains(TabType.completed));
    });

    test('should create TodoController with default values', () {
      final controller = TodoController();
      
      expect(controller.selectedTab, TabType.all);
      expect(controller.selectedCategoryId, null);
      expect(controller.searchQuery, '');
      expect(controller.todoCount, 0);
      expect(controller.hasActiveFilters, false);
    });

    test('should handle filter state correctly', () {
      final controller = TodoController();
      
      // Test initial state
      expect(controller.hasActiveFilters, false);
      expect(controller.hasCategoryFilter, false);
      expect(controller.hasTabFilter, false);
      expect(controller.hasSearchFilter, false);
      
      // Test filter description
      expect(controller.getFilterDescription(), 'All Tasks');
    });

    test('should validate Todo model properties for filtering', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Test todo due today
      final todoToday = Todo.create(
        title: 'Test Task',
        dueDate: today,
      );
      expect(todoToday.isDueToday, true);
      
      // Test todo not due today
      final todoTomorrow = Todo.create(
        title: 'Test Task',
        dueDate: today.add(const Duration(days: 1)),
      );
      expect(todoTomorrow.isDueToday, false);
      
      // Test todo with no due date
      final todoNoDueDate = Todo.create(
        title: 'Test Task',
      );
      expect(todoNoDueDate.isDueToday, false);
    });

    test('should validate priority values', () {
      final lowPriorityTodo = Todo.create(title: 'Low', priority: 1);
      final mediumPriorityTodo = Todo.create(title: 'Medium', priority: 2);
      final highPriorityTodo = Todo.create(title: 'High', priority: 3);
      
      expect(lowPriorityTodo.priority, 1);
      expect(lowPriorityTodo.priorityText, 'Low');
      
      expect(mediumPriorityTodo.priority, 2);
      expect(mediumPriorityTodo.priorityText, 'Medium');
      
      expect(highPriorityTodo.priority, 3);
      expect(highPriorityTodo.priorityText, 'High');
    });

    test('should validate completion status', () {
      final todo = Todo.create(title: 'Test Task');
      
      expect(todo.isCompleted, false);
      
      final completedTodo = todo.copyWith(isCompleted: true);
      expect(completedTodo.isCompleted, true);
    });

    test('should validate category assignment', () {
      final personalTodo = Todo.create(title: 'Personal Task', categoryId: 'personal');
      final workTodo = Todo.create(title: 'Work Task', categoryId: 'work');
      
      expect(personalTodo.categoryId, 'personal');
      expect(workTodo.categoryId, 'work');
    });
  });
}