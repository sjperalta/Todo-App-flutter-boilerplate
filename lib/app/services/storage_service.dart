import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';
import '../models/category.dart';


class StorageService {
  static const String _todoBoxName = 'todos';
  static const String _categoryBoxName = 'categories';
  static const String _settingsBoxName = 'settings';
  static const String _versionKey = 'storage_version';
  static const int _currentVersion = 1;

  static Box<Todo>? _todoBox;
  static Box<Category>? _categoryBox;
  static Box? _settingsBox;
  static bool _isInitialized = false;

  // Initialize Hive and open boxes
  static Future<void> initialize() async {
    if (_isInitialized) return;

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        // Initialize Hive
        await Hive.initFlutter();

        // Register adapters
        await _registerAdapters();

        // Open boxes with error handling
        await _openBoxes();

        // Perform data migration if needed
        await _performMigration();

        // Initialize default categories if none exist
        await _initializeDefaultCategories();

        // Validate storage integrity
        await _validateStorageIntegrity();

        _isInitialized = true;
        print('Storage initialized successfully');
        return;
      } catch (e) {
        retryCount++;
        print('Error initializing storage (attempt $retryCount/$maxRetries): $e');
        
        if (retryCount >= maxRetries) {
          // Final attempt - try recovery
          try {
            await _attemptRecovery();
            _isInitialized = true;
            print('Storage recovery successful');
            return;
          } catch (recoveryError) {
            print('Storage recovery failed: $recoveryError');
            throw StorageException('Failed to initialize storage after $maxRetries attempts: $e');
          }
        } else {
          // Wait before retry
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }
    }
  }

  // Register Hive type adapters
  static Future<void> _registerAdapters() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
  }

  // Open Hive boxes with error handling
  static Future<void> _openBoxes() async {
    try {
      _todoBox = await Hive.openBox<Todo>(_todoBoxName);
      _categoryBox = await Hive.openBox<Category>(_categoryBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
    } catch (e) {
      // If boxes are corrupted, delete and recreate them
      print('Error opening boxes: $e');
      await _deleteCorruptedBoxes();
      
      // Retry opening boxes
      _todoBox = await Hive.openBox<Todo>(_todoBoxName);
      _categoryBox = await Hive.openBox<Category>(_categoryBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
    }
  }

  // Delete corrupted boxes
  static Future<void> _deleteCorruptedBoxes() async {
    try {
      await Hive.deleteBoxFromDisk(_todoBoxName);
      await Hive.deleteBoxFromDisk(_categoryBoxName);
      await Hive.deleteBoxFromDisk(_settingsBoxName);
    } catch (e) {
      print('Error deleting corrupted boxes: $e');
    }
  }

  // Perform data migration
  static Future<void> _performMigration() async {
    try {
      final currentVersion = _settingsBox!.get(_versionKey, defaultValue: 0);
      
      if (currentVersion < _currentVersion) {
        await _migrateData(currentVersion, _currentVersion);
        await _settingsBox!.put(_versionKey, _currentVersion);
      }
    } catch (e) {
      print('Error during migration: $e');
      // Continue without migration if it fails
    }
  }

  // Migrate data between versions
  static Future<void> _migrateData(int fromVersion, int toVersion) async {
    print('Migrating data from version $fromVersion to $toVersion');
    
    // Add migration logic here for future versions
    switch (fromVersion) {
      case 0:
        // Initial version - no migration needed
        break;
      default:
        // Unknown version - skip migration
        break;
    }
  }

  // Attempt recovery from initialization failure
  static Future<void> _attemptRecovery() async {
    try {
      print('Attempting storage recovery...');
      
      // Step 1: Close any open boxes
      try {
        await _todoBox?.close();
        await _categoryBox?.close();
        await _settingsBox?.close();
      } catch (e) {
        print('Error closing boxes during recovery: $e');
      }
      
      // Step 2: Clear corrupted data
      await _deleteCorruptedBoxes();
      
      // Step 3: Wait a moment for file system
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Step 4: Re-register adapters (in case they were cleared)
      await _registerAdapters();
      
      // Step 5: Reinitialize boxes
      await _openBoxes();
      
      // Step 6: Restore default data
      await _initializeDefaultCategories();
      
      // Step 7: Validate recovery
      await _validateStorageIntegrity();
      
      _isInitialized = true;
      print('Storage recovery completed successfully');
    } catch (e) {
      print('Storage recovery failed: $e');
      throw StorageException('Recovery failed: $e');
    }
  }

  // Initialize default categories
  static Future<void> _initializeDefaultCategories() async {
    try {
      if (_categoryBox!.isEmpty) {
        final defaultCategories = Category.getDefaultCategories();
        for (final category in defaultCategories) {
          await _categoryBox!.put(category.id, category);
        }
        print('Default categories initialized');
      }
    } catch (e) {
      print('Error initializing default categories: $e');
      rethrow;
    }
  }

  // Check if storage is initialized
  static bool get isInitialized => _isInitialized;

  // Todo box getter with validation
  static Box<Todo> get todoBox {
    _validateInitialization();
    if (_todoBox == null || !_todoBox!.isOpen) {
      throw StorageException('Todo box is not available');
    }
    return _todoBox!;
  }

  // Category box getter with validation
  static Box<Category> get categoryBox {
    _validateInitialization();
    if (_categoryBox == null || !_categoryBox!.isOpen) {
      throw StorageException('Category box is not available');
    }
    return _categoryBox!;
  }

  // Settings box getter with validation
  static Box get settingsBox {
    _validateInitialization();
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw StorageException('Settings box is not available');
    }
    return _settingsBox!;
  }

  // Validate that storage is initialized
  static void _validateInitialization() {
    if (!_isInitialized) {
      throw StorageException('Storage is not initialized. Call StorageService.initialize() first.');
    }
  }

  // Close all boxes
  static Future<void> close() async {
    try {
      await _todoBox?.close();
      await _categoryBox?.close();
      await _settingsBox?.close();
      _isInitialized = false;
    } catch (e) {
      print('Error closing storage: $e');
    }
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAll() async {
    try {
      _validateInitialization();
      
      await _todoBox?.clear();
      await _categoryBox?.clear();
      await _settingsBox?.clear();
      
      // Re-initialize default categories
      await _initializeDefaultCategories();
    } catch (e) {
      print('Error clearing storage: $e');
      rethrow;
    }
  }

  // Backup data to JSON
  static Future<Map<String, dynamic>> backupData() async {
    try {
      _validateInitialization();
      
      final todos = getAllTodos().map((todo) => todo.toJson()).toList();
      final categories = getAllCategories().map((category) => category.toJson()).toList();
      final settings = Map<String, dynamic>.from(settingsBox.toMap());
      
      return {
        'version': _currentVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'todos': todos,
        'categories': categories,
        'settings': settings,
      };
    } catch (e) {
      print('Error backing up data: $e');
      rethrow;
    }
  }

  // Restore data from JSON backup
  static Future<void> restoreData(Map<String, dynamic> backup) async {
    try {
      _validateInitialization();
      
      // Clear existing data
      await clearAll();
      
      // Restore todos
      if (backup['todos'] != null) {
        for (final todoJson in backup['todos']) {
          final todo = Todo.fromJson(todoJson);
          await saveTodo(todo);
        }
      }
      
      // Restore categories
      if (backup['categories'] != null) {
        for (final categoryJson in backup['categories']) {
          final category = Category.fromJson(categoryJson);
          await saveCategory(category);
        }
      }
      
      // Restore settings
      if (backup['settings'] != null) {
        for (final entry in backup['settings'].entries) {
          await saveSetting(entry.key, entry.value);
        }
      }
    } catch (e) {
      print('Error restoring data: $e');
      rethrow;
    }
  }

  // Get all todos with error handling
  static List<Todo> getAllTodos() {
    try {
      return todoBox.values.toList();
    } catch (e) {
      print('Error getting todos: $e');
      return [];
    }
  }

  // Get all categories with error handling
  static List<Category> getAllCategories() {
    try {
      return categoryBox.values.toList();
    } catch (e) {
      print('Error getting categories: $e');
      return Category.getDefaultCategories();
    }
  }

  // Save todo with validation and error handling
  static Future<void> saveTodo(Todo todo) async {
    try {
      // Validate todo before saving
      final validationErrors = todo.validate();
      if (validationErrors.isNotEmpty) {
        throw StorageException('Invalid todo data: ${validationErrors.join(', ')}');
      }
      
      await todoBox.put(todo.id, todo);
    } catch (e) {
      print('Error saving todo: $e');
      rethrow;
    }
  }

  // Delete todo with error handling
  static Future<void> deleteTodo(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw StorageException('Todo ID cannot be empty');
      }
      
      await todoBox.delete(id);
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  // Save category with validation and error handling
  static Future<void> saveCategory(Category category) async {
    try {
      // Validate category before saving
      final validationErrors = category.validate();
      if (validationErrors.isNotEmpty) {
        throw StorageException('Invalid category data: ${validationErrors.join(', ')}');
      }
      
      await categoryBox.put(category.id, category);
    } catch (e) {
      print('Error saving category: $e');
      rethrow;
    }
  }

  // Delete category with error handling
  static Future<void> deleteCategory(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw StorageException('Category ID cannot be empty');
      }
      
      await categoryBox.delete(id);
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // Get setting with error handling
  static T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      if (key.trim().isEmpty) {
        throw StorageException('Setting key cannot be empty');
      }
      
      return settingsBox.get(key, defaultValue: defaultValue);
    } catch (e) {
      print('Error getting setting: $e');
      return defaultValue;
    }
  }

  // Save setting with error handling
  static Future<void> saveSetting(String key, dynamic value) async {
    try {
      if (key.trim().isEmpty) {
        throw StorageException('Setting key cannot be empty');
      }
      
      await settingsBox.put(key, value);
    } catch (e) {
      print('Error saving setting: $e');
      rethrow;
    }
  }

  // Get storage statistics
  static Map<String, int> getStorageStats() {
    try {
      return {
        'todos': todoBox.length,
        'categories': categoryBox.length,
        'settings': settingsBox.length,
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {'todos': 0, 'categories': 0, 'settings': 0};
    }
  }

  // Compact storage (optimize disk usage)
  static Future<void> compactStorage() async {
    try {
      await todoBox.compact();
      await categoryBox.compact();
      await settingsBox.compact();
      print('Storage compacted successfully');
    } catch (e) {
      print('Error compacting storage: $e');
      throw StorageException('Failed to compact storage: $e');
    }
  }

  // Validate storage integrity
  static Future<void> _validateStorageIntegrity() async {
    try {
      // Check if boxes are accessible
      final todoCount = todoBox.length;
      final categoryCount = categoryBox.length;
      final settingsCount = settingsBox.length;
      
      print('Storage validation: $todoCount todos, $categoryCount categories, $settingsCount settings');
      
      // Validate todos
      final todos = getAllTodos();
      for (final todo in todos) {
        final validationErrors = todo.validate();
        if (validationErrors.isNotEmpty) {
          print('Invalid todo found: ${todo.id} - ${validationErrors.join(', ')}');
          // Optionally remove invalid todos
          await deleteTodo(todo.id);
        }
      }
      
      // Validate categories
      final categories = getAllCategories();
      for (final category in categories) {
        final validationErrors = category.validate();
        if (validationErrors.isNotEmpty) {
          print('Invalid category found: ${category.id} - ${validationErrors.join(', ')}');
          // Optionally remove invalid categories (but keep defaults)
          if (!category.isDefault) {
            await deleteCategory(category.id);
          }
        }
      }
      
      // Ensure we have default categories
      if (categories.isEmpty) {
        await _initializeDefaultCategories();
      }
      
      print('Storage integrity validation completed');
    } catch (e) {
      print('Storage integrity validation failed: $e');
      // Don't throw here as this is a validation step
    }
  }

  // Check storage health
  static Future<Map<String, dynamic>> checkStorageHealth() async {
    try {
      _validateInitialization();
      
      final health = <String, dynamic>{
        'isInitialized': _isInitialized,
        'todoBoxOpen': _todoBox?.isOpen ?? false,
        'categoryBoxOpen': _categoryBox?.isOpen ?? false,
        'settingsBoxOpen': _settingsBox?.isOpen ?? false,
        'todoCount': todoBox.length,
        'categoryCount': categoryBox.length,
        'settingsCount': settingsBox.length,
        'lastCheck': DateTime.now().toIso8601String(),
      };
      
      // Check for data corruption
      try {
        final todos = getAllTodos();
        final categories = getAllCategories();
        
        health['validTodos'] = todos.where((todo) => todo.validate().isEmpty).length;
        health['invalidTodos'] = todos.where((todo) => todo.validate().isNotEmpty).length;
        health['validCategories'] = categories.where((cat) => cat.validate().isEmpty).length;
        health['invalidCategories'] = categories.where((cat) => cat.validate().isNotEmpty).length;
        health['hasDefaultCategories'] = categories.any((cat) => cat.isDefault);
        
      } catch (e) {
        health['dataError'] = e.toString();
      }
      
      return health;
    } catch (e) {
      return {
        'error': e.toString(),
        'isInitialized': false,
        'lastCheck': DateTime.now().toIso8601String(),
      };
    }
  }

  // Repair storage issues
  static Future<bool> repairStorage() async {
    try {
      print('Starting storage repair...');
      
      // Remove invalid todos
      final todos = getAllTodos();
      int removedTodos = 0;
      for (final todo in todos) {
        final validationErrors = todo.validate();
        if (validationErrors.isNotEmpty) {
          await deleteTodo(todo.id);
          removedTodos++;
        }
      }
      
      // Remove invalid categories (except defaults)
      final categories = getAllCategories();
      int removedCategories = 0;
      for (final category in categories) {
        final validationErrors = category.validate();
        if (validationErrors.isNotEmpty && !category.isDefault) {
          await deleteCategory(category.id);
          removedCategories++;
        }
      }
      
      // Ensure default categories exist
      final remainingCategories = getAllCategories();
      if (remainingCategories.isEmpty || !remainingCategories.any((cat) => cat.isDefault)) {
        await _initializeDefaultCategories();
      }
      
      // Compact storage
      await compactStorage();
      
      print('Storage repair completed: removed $removedTodos invalid todos, $removedCategories invalid categories');
      return true;
    } catch (e) {
      print('Storage repair failed: $e');
      return false;
    }
  }
}

// Custom exception for storage errors
class StorageException implements Exception {
  final String message;
  
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}