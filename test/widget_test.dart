import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/models/todo.dart';
import 'package:flutter_app/app/models/category.dart';

void main() {
  group('Todo Model Tests', () {
    test('creates todo with valid data', () {
      final todo = Todo.create(
        title: 'Test Task',
        description: 'Test Description',
        priority: 2,
      );

      expect(todo.title, equals('Test Task'));
      expect(todo.description, equals('Test Description'));
      expect(todo.priority, equals(2));
      expect(todo.isCompleted, isFalse);
      expect(todo.categoryId, equals('personal'));
    });

    test('validates todo correctly', () {
      final validTodo = Todo.create(title: 'Valid Task');
      expect(validTodo.isValid, isTrue);

      final invalidTodo = Todo.create(title: '');
      expect(invalidTodo.isValid, isFalse);
    });

    test('toggles completion status', () {
      final todo = Todo.create(title: 'Test Task');
      expect(todo.isCompleted, isFalse);

      final completedTodo = todo.copyWith(isCompleted: true);
      expect(completedTodo.isCompleted, isTrue);
    });

    test('checks if task is due today', () {
      final today = DateTime.now();
      final todoToday = Todo.create(
        title: 'Today Task',
        dueDate: today,
      );
      expect(todoToday.isDueToday, isTrue);

      final tomorrow = today.add(const Duration(days: 1));
      final todoTomorrow = Todo.create(
        title: 'Tomorrow Task',
        dueDate: tomorrow,
      );
      expect(todoTomorrow.isDueToday, isFalse);
    });
  });

  group('Category Model Tests', () {
    test('creates category with valid data', () {
      final category = Category.create(
        id: 'test',
        name: 'Test Category',
        color: Colors.blue,
        icon: Icons.category,
      );

      expect(category.id, equals('test'));
      expect(category.name, equals('Test Category'));
      expect(category.color.value, equals(Colors.blue.value));
      expect(category.icon.codePoint, equals(Icons.category.codePoint));
    });

    test('validates category correctly', () {
      final validCategory = Category.create(
        id: 'valid',
        name: 'Valid Category',
        color: Colors.blue,
        icon: Icons.category,
      );
      expect(validCategory.isValid, isTrue);

      final invalidCategory = Category.create(
        id: '',
        name: 'Invalid Category',
        color: Colors.blue,
        icon: Icons.category,
      );
      expect(invalidCategory.isValid, isFalse);
    });

    test('creates default categories', () {
      final categories = Category.getDefaultCategories();
      expect(categories.length, equals(4));
      expect(categories.map((c) => c.name), contains('Personal'));
      expect(categories.map((c) => c.name), contains('Work'));
      expect(categories.map((c) => c.name), contains('Shopping'));
      expect(categories.map((c) => c.name), contains('Health'));
    });
  });
}
