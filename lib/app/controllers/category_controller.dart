import 'package:flutter/material.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';
import 'controller.dart';

class CategoryController extends Controller {
  final CategoryRepository _categoryRepository = CategoryRepository();
  
  List<Category> _categories = [];
  String? _selectedCategoryId;
  
  // Getters
  List<Category> get categories => List.unmodifiable(_categories);
  String? get selectedCategoryId => _selectedCategoryId;
  bool get hasCategories => _categories.isNotEmpty;
  
  // Load all categories from repository
  Future<void> loadCategories() async {
    try {
      _categories = _categoryRepository.getCategoriesWithTaskCounts();
    } catch (e) {
      print('CategoryController: Error loading categories: $e');
      _categories = Category.getDefaultCategories();
    }
  }

  // Create new category with validation
  Future<bool> createCategory(Category category) async {
    try {
      final success = await _categoryRepository.createCategory(category);
      if (success) {
        await loadCategories(); // Refresh the list
      }
      return success;
    } catch (e) {
      print('CategoryController: Error creating category: $e');
      return false;
    }
  }

  // Update existing category with validation
  Future<bool> updateCategory(Category category) async {
    try {
      final success = await _categoryRepository.updateCategory(category);
      if (success) {
        await loadCategories(); // Refresh the list
      }
      return success;
    } catch (e) {
      print('CategoryController: Error updating category: $e');
      return false;
    }
  }

  // Delete category with validation
  Future<bool> deleteCategory(String id) async {
    try {
      final success = await _categoryRepository.deleteCategory(id);
      if (success) {
        // If the deleted category was selected, clear selection
        if (_selectedCategoryId == id) {
          _selectedCategoryId = null;
        }
        await loadCategories(); // Refresh the list
      }
      return success;
    } catch (e) {
      print('CategoryController: Error deleting category: $e');
      return false;
    }
  }

  // Select a category for filtering
  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
  }

  // Clear category selection
  void clearSelection() {
    _selectedCategoryId = null;
  }

  // Get category by ID
  Category? getCategoryById(String id) {
    return _categoryRepository.getCategoryById(id);
  }

  // Get default categories
  List<Category> getDefaultCategories() {
    return _categories.where((category) => category.isDefault).toList();
  }

  // Get custom categories
  List<Category> getCustomCategories() {
    return _categories.where((category) => !category.isDefault).toList();
  }

  // Get category color by ID
  Color getCategoryColor(String id) {
    final category = getCategoryById(id);
    return category?.color ?? const Color(0xFF32C7AE); // Default mint green
  }

  // Get category name by ID
  String getCategoryName(String id) {
    final category = getCategoryById(id);
    return category?.name ?? 'Unknown';
  }

  // Get category icon by ID
  IconData getCategoryIcon(String id) {
    final category = getCategoryById(id);
    return category?.icon ?? Icons.category;
  }

  // Update task count for a specific category
  Future<bool> updateTaskCount(String categoryId, int count) async {
    try {
      final success = await _categoryRepository.updateTaskCount(categoryId, count);
      if (success) {
        await loadCategories();
      }
      return success;
    } catch (e) {
      print('CategoryController: Error updating task count: $e');
      return false;
    }
  }

  // Refresh task counts for all categories
  Future<bool> refreshTaskCounts() async {
    try {
      final success = await _categoryRepository.refreshTaskCounts();
      if (success) {
        await loadCategories();
      }
      return success;
    } catch (e) {
      print('CategoryController: Error refreshing task counts: $e');
      return false;
    }
  }

  // Move todos from one category to another
  Future<bool> moveTodosToCategory(String fromCategoryId, String toCategoryId) async {
    try {
      final success = await _categoryRepository.moveTodosToCategory(fromCategoryId, toCategoryId);
      if (success) {
        await refreshTaskCounts();
      }
      return success;
    } catch (e) {
      print('CategoryController: Error moving todos: $e');
      return false;
    }
  }

  // Get categories sorted by task count (descending)
  List<Category> getCategoriesByTaskCount() {
    final sortedCategories = List<Category>.from(_categories);
    sortedCategories.sort((a, b) => b.taskCount.compareTo(a.taskCount));
    return sortedCategories;
  }

  // Get categories sorted by name
  List<Category> getCategoriesByName() {
    final sortedCategories = List<Category>.from(_categories);
    sortedCategories.sort((a, b) => a.name.compareTo(b.name));
    return sortedCategories;
  }

  // Check if category exists
  bool categoryExists(String id) {
    return getCategoryById(id) != null;
  }

  // Check if category name is unique
  bool isCategoryNameUnique(String name, {String? excludeId}) {
    return !_categories.any((category) => 
        category.name.toLowerCase() == name.toLowerCase() && 
        category.id != excludeId);
  }

  // Get category statistics
  Map<String, dynamic> getCategoryStatistics() {
    try {
      final stats = _categoryRepository.getStatistics();
      return {
        ...stats,
        'categories_with_tasks': _categories.where((cat) => cat.taskCount > 0).length,
        'empty_categories': _categories.where((cat) => cat.taskCount == 0).length,
        'most_used_category': _getMostUsedCategory()?.name ?? 'None',
        'least_used_category': _getLeastUsedCategory()?.name ?? 'None',
      };
    } catch (e) {
      print('CategoryController: Error getting statistics: $e');
      return {};
    }
  }

  // Get most used category
  Category? _getMostUsedCategory() {
    if (_categories.isEmpty) return null;
    return _categories.reduce((a, b) => a.taskCount > b.taskCount ? a : b);
  }

  // Get least used category
  Category? _getLeastUsedCategory() {
    if (_categories.isEmpty) return null;
    return _categories.reduce((a, b) => a.taskCount < b.taskCount ? a : b);
  }

  // Validation methods
  bool isValidCategory(Category category) {
    return category.isValid;
  }

  List<String> validateCategory(Category category) {
    return category.validate();
  }

  // Create a new category with smart defaults
  Future<bool> createCategoryWithDefaults({
    required String name,
    Color? color,
    IconData? icon,
  }) async {
    try {
      // Generate unique ID
      final id = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      
      // Use provided color or generate a random one
      final categoryColor = color ?? _generateRandomColor();
      
      // Use provided icon or default
      final categoryIcon = icon ?? Icons.category;
      
      final category = Category.create(
        id: id,
        name: name,
        color: categoryColor,
        icon: categoryIcon,
        isDefault: false,
      );
      
      return await createCategory(category);
    } catch (e) {
      print('CategoryController: Error creating category with defaults: $e');
      return false;
    }
  }

  // Generate a random color for new categories
  Color _generateRandomColor() {
    final colors = [
      const Color(0xFF32C7AE), // Mint green
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF97316), // Orange
      const Color(0xFF10B981), // Green
      const Color(0xFFEF4444), // Red
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFFEC4899), // Pink
    ];
    
    // Find colors not already used
    final usedColors = _categories.map((cat) => cat.colorValue).toSet();
    final availableColors = colors.where((color) => !usedColors.contains(color.toARGB32())).toList();
    
    if (availableColors.isNotEmpty) {
      return availableColors.first;
    }
    
    // If all colors are used, return a default
    return colors.first;
  }

  // Reset to default categories (for recovery)
  Future<bool> resetToDefaults() async {
    try {
      final success = await _categoryRepository.resetToDefaults();
      if (success) {
        _selectedCategoryId = null;
        await loadCategories();
      }
      return success;
    } catch (e) {
      print('CategoryController: Error resetting to defaults: $e');
      return false;
    }
  }

  // Validate repository integrity
  Future<List<String>> validateIntegrity() async {
    return await _categoryRepository.validateIntegrity();
  }

  // Check if category can be deleted
  bool canDeleteCategory(String id) {
    final category = getCategoryById(id);
    if (category == null) return false;
    if (category.isDefault) return false;
    return category.taskCount == 0;
  }

  // Get deletion warning message
  String? getDeletionWarning(String id) {
    final category = getCategoryById(id);
    if (category == null) return 'Category not found';
    if (category.isDefault) return 'Cannot delete default categories';
    if (category.taskCount > 0) {
      return 'This category has ${category.taskCount} task(s). Move or delete them first.';
    }
    return null;
  }

  // Initialize controller with default categories
  Future<void> initialize() async {
    await loadCategories();
    
    // Ensure default categories exist
    final defaultCategories = Category.getDefaultCategories();
    for (final defaultCategory in defaultCategories) {
      if (!categoryExists(defaultCategory.id)) {
        await createCategory(defaultCategory);
      }
    }
    
    await refreshTaskCounts();
  }

  // Refresh data from storage
  Future<void> refresh() async {
    await loadCategories();
  }

  // Clean up any resources if needed
  void dispose() {
    // Clean up any resources if needed
  }
}