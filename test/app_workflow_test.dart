import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/models/todo.dart';
import 'package:flutter_app/app/models/category.dart';

void main() {
  group('TaskFlow App Workflow Tests', () {

    test('should create and validate Todo model', () {
      final todo = Todo(
        id: 'test-id',
        title: 'Test Todo',
        description: 'Test Description',
        categoryId: 'personal',
        priority: 2,
      );

      expect(todo.id, 'test-id');
      expect(todo.title, 'Test Todo');
      expect(todo.description, 'Test Description');
      expect(todo.categoryId, 'personal');
      expect(todo.priority, 2);
      expect(todo.isCompleted, false);
      expect(todo.createdAt, isA<DateTime>());
      expect(todo.updatedAt, isA<DateTime>());
    });

    test('should create and validate Category model', () {
      final categories = Category.getDefaultCategories();
      
      expect(categories.length, greaterThan(0));
      
      final personalCategory = categories.firstWhere(
        (c) => c.id == 'personal',
        orElse: () => throw Exception('Personal category not found'),
      );
      
      expect(personalCategory.name, 'Personal');
      expect(personalCategory.color, isA<Color>());
      expect(personalCategory.isDefault, true);
    });

    test('should handle Todo model serialization', () {
      final originalTodo = Todo(
        id: 'test-id',
        title: 'Test Todo',
        description: 'Test Description',
        categoryId: 'personal',
        priority: 2,
        isCompleted: true,
      );

      // Test toJson
      final json = originalTodo.toJson();
      expect(json['id'], 'test-id');
      expect(json['title'], 'Test Todo');
      expect(json['description'], 'Test Description');
      expect(json['categoryId'], 'personal');
      expect(json['priority'], 2);
      expect(json['isCompleted'], true);

      // Test fromJson
      final deserializedTodo = Todo.fromJson(json);
      expect(deserializedTodo.id, originalTodo.id);
      expect(deserializedTodo.title, originalTodo.title);
      expect(deserializedTodo.description, originalTodo.description);
      expect(deserializedTodo.categoryId, originalTodo.categoryId);
      expect(deserializedTodo.priority, originalTodo.priority);
      expect(deserializedTodo.isCompleted, originalTodo.isCompleted);
    });

    test('should handle Todo model copyWith', () {
      final originalTodo = Todo(
        id: 'test-id',
        title: 'Original Title',
        description: 'Original Description',
        categoryId: 'personal',
        priority: 1,
        isCompleted: false,
      );

      final updatedTodo = originalTodo.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      expect(updatedTodo.id, originalTodo.id);
      expect(updatedTodo.title, 'Updated Title');
      expect(updatedTodo.description, originalTodo.description);
      expect(updatedTodo.categoryId, originalTodo.categoryId);
      expect(updatedTodo.priority, originalTodo.priority);
      expect(updatedTodo.isCompleted, true);
    });

    test('should validate Todo model properties', () {
      final todo = Todo(
        id: 'test-id',
        title: 'Test Todo',
        categoryId: 'personal',
        priority: 2,
        dueDate: DateTime.now().add(Duration(days: 1)),
      );

      // Test computed properties
      expect(todo.isDueToday, false);
      expect(todo.isOverdue, false);
      
      // Test with today's date
      final todayTodo = todo.copyWith(
        dueDate: DateTime.now(),
      );
      expect(todayTodo.isDueToday, true);
      
      // Test with past date
      final overdueTodo = todo.copyWith(
        dueDate: DateTime.now().subtract(Duration(days: 1)),
      );
      expect(overdueTodo.isOverdue, true);
    });

    test('should handle Category model functionality', () {
      final categories = Category.getDefaultCategories();
      
      // Verify all default categories exist
      final categoryIds = categories.map((c) => c.id).toSet();
      expect(categoryIds.contains('personal'), true);
      expect(categoryIds.contains('work'), true);
      expect(categoryIds.contains('shopping'), true);
      expect(categoryIds.contains('health'), true);
      
      // Verify category colors are different
      final colors = categories.map((c) => c.color).toSet();
      expect(colors.length, greaterThan(1)); // Should have different colors
    });



    test('should validate model constraints', () {
      // Test valid priority range
      expect(() => Todo(
        id: 'test',
        title: 'Test',
        categoryId: 'personal',
        priority: 1,
      ), returnsNormally);
      
      expect(() => Todo(
        id: 'test',
        title: 'Test',
        categoryId: 'personal',
        priority: 3,
      ), returnsNormally);
      
      // Test edge cases
      final todo = Todo(
        id: 'test',
        title: 'Test',
        categoryId: 'personal',
        priority: 2,
      );
      
      expect(todo.title.isNotEmpty, true);
      expect(todo.categoryId.isNotEmpty, true);
      expect(todo.priority >= 1 && todo.priority <= 3, true);
    });
  });
}