import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  String categoryId;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  int priority; // 1=Low, 2=Medium, 3=High

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.categoryId = 'personal',
    this.isCompleted = false,
    this.priority = 2, // Default to Medium
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Factory constructor for creating new todos
  factory Todo.create({
    required String title,
    String? description,
    DateTime? dueDate,
    String categoryId = 'personal',
    int priority = 2,
  }) {
    return Todo(
      id: generateId(),
      title: title,
      description: description,
      dueDate: dueDate,
      categoryId: categoryId,
      priority: priority,
    );
  }

  // Update the todo
  Todo copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? categoryId,
    bool? isCompleted,
    int? priority,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return taskDate.isAtSameMomentAs(today);
  }

  // Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return taskDate.isBefore(today);
  }

  // Get priority text
  String get priorityText {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      default:
        return 'Medium';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'categoryId': categoryId,
      'isCompleted': isCompleted,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Todo fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      categoryId: json['categoryId'] ?? 'personal',
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 2,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Validation methods
  bool get isValid {
    return title.trim().isNotEmpty && 
           priority >= 1 && 
           priority <= 3 &&
           categoryId.isNotEmpty;
  }

  String? validateTitle() {
    if (title.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    if (title.length > 100) {
      return 'Title cannot exceed 100 characters';
    }
    return null;
  }

  String? validatePriority() {
    if (priority < 1 || priority > 3) {
      return 'Priority must be between 1 (Low) and 3 (High)';
    }
    return null;
  }

  String? validateCategory() {
    if (categoryId.trim().isEmpty) {
      return 'Category cannot be empty';
    }
    return null;
  }

  String? validateDescription() {
    if (description != null && description!.length > 500) {
      return 'Description cannot exceed 500 characters';
    }
    return null;
  }

  List<String> validate() {
    final errors = <String>[];
    
    final titleError = validateTitle();
    if (titleError != null) errors.add(titleError);
    
    final priorityError = validatePriority();
    if (priorityError != null) errors.add(priorityError);
    
    final categoryError = validateCategory();
    if (categoryError != null) errors.add(categoryError);
    
    final descriptionError = validateDescription();
    if (descriptionError != null) errors.add(descriptionError);
    
    return errors;
  }
}