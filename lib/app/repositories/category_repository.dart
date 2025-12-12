import '../models/category.dart';
import '../services/storage_service.dart';

class CategoryRepository {
  // Get all categories with error handling
  List<Category> getAllCategories() {
    try {
      return StorageService.getAllCategories();
    } catch (e) {
      print('CategoryRepository: Error getting all categories: $e');
      return Category.getDefaultCategories();
    }
  }

  // Get category by ID with validation
  Category? getCategoryById(String id) {
    try {
      if (id.trim().isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }
      return StorageService.categoryBox.get(id);
    } catch (e) {
      print('CategoryRepository: Error getting category by ID: $e');
      return null;
    }
  }

  // Create new category with validation
  Future<bool> createCategory(Category category) async {
    try {
      // Validate category data
      final validationErrors = category.validate();
      if (validationErrors.isNotEmpty) {
        throw ArgumentError('Invalid category data: ${validationErrors.join(', ')}');
      }

      // Check if category with same ID already exists
      if (getCategoryById(category.id) != null) {
        throw ArgumentError('Category with ID ${category.id} already exists');
      }

      // Check if category with same name already exists
      final existingCategories = getAllCategories();
      if (existingCategories.any((cat) => cat.name.toLowerCase() == category.name.toLowerCase())) {
        throw ArgumentError('Category with name "${category.name}" already exists');
      }

      await StorageService.saveCategory(category);
      return true;
    } catch (e) {
      print('CategoryRepository: Error creating category: $e');
      return false;
    }
  }

  // Update existing category with validation
  Future<bool> updateCategory(Category category) async {
    try {
      // Validate category data
      final validationErrors = category.validate();
      if (validationErrors.isNotEmpty) {
        throw ArgumentError('Invalid category data: ${validationErrors.join(', ')}');
      }

      // Check if category exists
      if (getCategoryById(category.id) == null) {
        throw ArgumentError('Category with ID ${category.id} does not exist');
      }

      await StorageService.saveCategory(category);
      return true;
    } catch (e) {
      print('CategoryRepository: Error updating category: $e');
      return false;
    }
  }

  // Delete category with validation
  Future<bool> deleteCategory(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }

      final category = getCategoryById(id);
      if (category == null) {
        throw ArgumentError('Category with ID $id does not exist');
      }

      // Don't allow deletion of default categories
      if (category.isDefault) {
        throw ArgumentError('Cannot delete default category');
      }

      // Check if category has associated todos
      final todos = StorageService.getAllTodos();
      final hasAssociatedTodos = todos.any((todo) => todo.categoryId == id);
      if (hasAssociatedTodos) {
        throw ArgumentError('Cannot delete category with associated todos');
      }

      await StorageService.deleteCategory(id);
      return true;
    } catch (e) {
      print('CategoryRepository: Error deleting category: $e');
      return false;
    }
  }

  // Get default categories
  List<Category> getDefaultCategories() {
    return getAllCategories().where((category) => category.isDefault).toList();
  }

  // Get custom categories
  List<Category> getCustomCategories() {
    return getAllCategories().where((category) => !category.isDefault).toList();
  }

  // Update task count for a category with validation
  Future<bool> updateTaskCount(String categoryId, int count) async {
    try {
      if (count < 0) {
        throw ArgumentError('Task count cannot be negative');
      }

      final category = getCategoryById(categoryId);
      if (category == null) {
        throw ArgumentError('Category with ID $categoryId does not exist');
      }

      final updatedCategory = category.copyWith(taskCount: count);
      return await updateCategory(updatedCategory);
    } catch (e) {
      print('CategoryRepository: Error updating task count: $e');
      return false;
    }
  }

  // Refresh task counts for all categories
  Future<bool> refreshTaskCounts() async {
    try {
      final todos = StorageService.getAllTodos();
      final categories = getAllCategories();
      
      for (final category in categories) {
        final taskCount = todos.where((todo) => todo.categoryId == category.id).length;
        final success = await updateTaskCount(category.id, taskCount);
        if (!success) {
          throw Exception('Failed to update task count for category: ${category.name}');
        }
      }
      
      return true;
    } catch (e) {
      print('CategoryRepository: Error refreshing task counts: $e');
      return false;
    }
  }

  // Get categories with task counts
  List<Category> getCategoriesWithTaskCounts() {
    try {
      final todos = StorageService.getAllTodos();
      final categories = getAllCategories();
      
      return categories.map((category) {
        final taskCount = todos.where((todo) => todo.categoryId == category.id).length;
        return category.copyWith(taskCount: taskCount);
      }).toList();
    } catch (e) {
      print('CategoryRepository: Error getting categories with task counts: $e');
      return getAllCategories();
    }
  }

  // Move todos from one category to another
  Future<bool> moveTodosToCategory(String fromCategoryId, String toCategoryId) async {
    try {
      if (fromCategoryId.trim().isEmpty || toCategoryId.trim().isEmpty) {
        throw ArgumentError('Category IDs cannot be empty');
      }

      if (fromCategoryId == toCategoryId) {
        return true; // No operation needed
      }

      // Validate both categories exist
      if (getCategoryById(fromCategoryId) == null) {
        throw ArgumentError('Source category does not exist');
      }
      if (getCategoryById(toCategoryId) == null) {
        throw ArgumentError('Target category does not exist');
      }

      final todos = StorageService.getAllTodos();
      final todosToMove = todos.where((todo) => todo.categoryId == fromCategoryId).toList();

      for (final todo in todosToMove) {
        final updatedTodo = todo.copyWith(categoryId: toCategoryId);
        await StorageService.saveTodo(updatedTodo);
      }

      return true;
    } catch (e) {
      print('CategoryRepository: Error moving todos: $e');
      return false;
    }
  }

  // Get repository statistics
  Map<String, dynamic> getStatistics() {
    try {
      final categories = getAllCategories();
      final todos = StorageService.getAllTodos();
      
      final categoryStats = <String, int>{};
      for (final category in categories) {
        categoryStats[category.name] = todos.where((todo) => todo.categoryId == category.id).length;
      }

      return {
        'total_categories': categories.length,
        'default_categories': categories.where((cat) => cat.isDefault).length,
        'custom_categories': categories.where((cat) => !cat.isDefault).length,
        'category_breakdown': categoryStats,
      };
    } catch (e) {
      print('CategoryRepository: Error getting statistics: $e');
      return {};
    }
  }

  // Validate repository integrity
  Future<List<String>> validateIntegrity() async {
    final issues = <String>[];
    
    try {
      final categories = getAllCategories();
      final todos = StorageService.getAllTodos();
      
      // Validate each category
      for (final category in categories) {
        final validationErrors = category.validate();
        if (validationErrors.isNotEmpty) {
          issues.add('Category ${category.id}: ${validationErrors.join(', ')}');
        }
      }
      
      // Check for duplicate IDs
      final ids = categories.map((cat) => cat.id).toList();
      final uniqueIds = ids.toSet();
      if (ids.length != uniqueIds.length) {
        issues.add('Duplicate category IDs found');
      }
      
      // Check for duplicate names
      final names = categories.map((cat) => cat.name.toLowerCase()).toList();
      final uniqueNames = names.toSet();
      if (names.length != uniqueNames.length) {
        issues.add('Duplicate category names found');
      }
      
      // Check for orphaned todos (todos with non-existent categories)
      final categoryIds = categories.map((cat) => cat.id).toSet();
      final orphanedTodos = todos.where((todo) => !categoryIds.contains(todo.categoryId)).toList();
      if (orphanedTodos.isNotEmpty) {
        issues.add('Found ${orphanedTodos.length} todos with non-existent categories');
      }
      
      // Ensure default categories exist
      final defaultCategoryIds = Category.getDefaultCategories().map((cat) => cat.id).toSet();
      final existingCategoryIds = categories.map((cat) => cat.id).toSet();
      final missingDefaults = defaultCategoryIds.difference(existingCategoryIds);
      if (missingDefaults.isNotEmpty) {
        issues.add('Missing default categories: ${missingDefaults.join(', ')}');
      }
      
    } catch (e) {
      issues.add('Error validating repository: $e');
    }
    
    return issues;
  }

  // Reset to default categories (for recovery)
  Future<bool> resetToDefaults() async {
    try {
      // Clear all categories
      final categories = getAllCategories();
      for (final category in categories) {
        if (!category.isDefault) {
          await StorageService.deleteCategory(category.id);
        }
      }
      
      // Ensure default categories exist
      final defaultCategories = Category.getDefaultCategories();
      for (final category in defaultCategories) {
        if (getCategoryById(category.id) == null) {
          await StorageService.saveCategory(category);
        }
      }
      
      // Move orphaned todos to 'personal' category
      final todos = StorageService.getAllTodos();
      final validCategoryIds = defaultCategories.map((cat) => cat.id).toSet();
      
      for (final todo in todos) {
        if (!validCategoryIds.contains(todo.categoryId)) {
          final updatedTodo = todo.copyWith(categoryId: 'personal');
          await StorageService.saveTodo(updatedTodo);
        }
      }
      
      return true;
    } catch (e) {
      print('CategoryRepository: Error resetting to defaults: $e');
      return false;
    }
  }
}