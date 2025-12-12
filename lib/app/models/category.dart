import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue; // Store color as int for Hive

  @HiveField(3)
  int iconCodePoint; // Store icon as int for Hive

  @HiveField(4)
  bool isDefault;

  @HiveField(5)
  int taskCount;

  Category({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    this.isDefault = false,
    this.taskCount = 0,
  });

  // Named constructor for easier creation
  Category.create({
    required this.id,
    required this.name,
    required Color color,
    required IconData icon,
    this.isDefault = false,
    this.taskCount = 0,
  }) : colorValue = color.toARGB32(),
       iconCodePoint = icon.codePoint;

  // Get color from stored value
  Color get color => Color(colorValue);

  // Get icon from stored value
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  // Set color (updates stored value)
  set color(Color newColor) {
    colorValue = newColor.toARGB32();
  }

  // Set icon (updates stored value)
  set icon(IconData newIcon) {
    iconCodePoint = newIcon.codePoint;
  }

  // Default categories for the app
  static List<Category> getDefaultCategories() {
    return [
      Category.create(
        id: 'personal',
        name: 'Personal',
        color: const Color(0xFF32C7AE), // Mint green
        icon: Icons.person,
        isDefault: true,
      ),
      Category.create(
        id: 'work',
        name: 'Work',
        color: const Color(0xFF8B5CF6), // Purple
        icon: Icons.work,
        isDefault: true,
      ),
      Category.create(
        id: 'shopping',
        name: 'Shopping',
        color: const Color(0xFFF97316), // Orange
        icon: Icons.shopping_cart,
        isDefault: true,
      ),
      Category.create(
        id: 'health',
        name: 'Health',
        color: const Color(0xFF10B981), // Green
        icon: Icons.health_and_safety,
        isDefault: true,
      ),
    ];
  }

  // Create a copy with updated values
  Category copyWith({
    String? name,
    Color? color,
    IconData? icon,
    bool? isDefault,
    int? taskCount,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      colorValue: color?.toARGB32() ?? colorValue,
      iconCodePoint: icon?.codePoint ?? iconCodePoint,
      isDefault: isDefault ?? this.isDefault,
      taskCount: taskCount ?? this.taskCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'isDefault': isDefault,
      'taskCount': taskCount,
    };
  }

  static Category fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      colorValue: json['colorValue'],
      iconCodePoint: json['iconCodePoint'],
      isDefault: json['isDefault'] ?? false,
      taskCount: json['taskCount'] ?? 0,
    );
  }

  // Validation methods
  bool get isValid {
    return id.trim().isNotEmpty && 
           name.trim().isNotEmpty &&
           taskCount >= 0;
  }

  String? validateId() {
    if (id.trim().isEmpty) {
      return 'Category ID cannot be empty';
    }
    if (id.length > 50) {
      return 'Category ID cannot exceed 50 characters';
    }
    return null;
  }

  String? validateName() {
    if (name.trim().isEmpty) {
      return 'Category name cannot be empty';
    }
    if (name.length > 50) {
      return 'Category name cannot exceed 50 characters';
    }
    return null;
  }

  String? validateTaskCount() {
    if (taskCount < 0) {
      return 'Task count cannot be negative';
    }
    return null;
  }

  List<String> validate() {
    final errors = <String>[];
    
    final idError = validateId();
    if (idError != null) errors.add(idError);
    
    final nameError = validateName();
    if (nameError != null) errors.add(nameError);
    
    final taskCountError = validateTaskCount();
    if (taskCountError != null) errors.add(taskCountError);
    
    return errors;
  }
}