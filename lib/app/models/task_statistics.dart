class TaskStatistics {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionPercentage;
  final Map<String, int> weeklyProgress;
  final Map<String, int> categoryBreakdown;

  TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionPercentage,
    required this.weeklyProgress,
    required this.categoryBreakdown,
  });

  // Factory constructor for empty statistics
  factory TaskStatistics.empty() {
    return TaskStatistics(
      totalTasks: 0,
      completedTasks: 0,
      pendingTasks: 0,
      completionPercentage: 0.0,
      weeklyProgress: {},
      categoryBreakdown: {},
    );
  }

  // Calculate statistics from a list of todos
  factory TaskStatistics.fromTodos(List todos) {
    final total = todos.length;
    final completed = todos.where((todo) => todo.isCompleted).length;
    final pending = total - completed;
    final percentage = total > 0 ? (completed / total) * 100 : 0.0;

    // Calculate weekly progress (last 7 days)
    final weeklyProgress = <String, int>{};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayName = _getDayName(date.weekday);
      
      final completedOnDay = todos.where((todo) {
        if (!todo.isCompleted) return false;
        final updatedDate = todo.updatedAt;
        final updatedDateKey = '${updatedDate.year}-${updatedDate.month.toString().padLeft(2, '0')}-${updatedDate.day.toString().padLeft(2, '0')}';
        return updatedDateKey == dateKey;
      }).length;
      
      weeklyProgress[dayName] = completedOnDay;
    }

    // Calculate category breakdown
    final categoryBreakdown = <String, int>{};
    for (final todo in todos) {
      final categoryId = todo.categoryId;
      categoryBreakdown[categoryId] = (categoryBreakdown[categoryId] ?? 0) + 1;
    }

    return TaskStatistics(
      totalTasks: total,
      completedTasks: completed,
      pendingTasks: pending,
      completionPercentage: percentage,
      weeklyProgress: weeklyProgress,
      categoryBreakdown: categoryBreakdown,
    );
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Unknown';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'completionPercentage': completionPercentage,
      'weeklyProgress': weeklyProgress,
      'categoryBreakdown': categoryBreakdown,
    };
  }

  static TaskStatistics fromJson(Map<String, dynamic> json) {
    return TaskStatistics(
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? 0,
      completionPercentage: (json['completionPercentage'] ?? 0.0).toDouble(),
      weeklyProgress: Map<String, int>.from(json['weeklyProgress'] ?? {}),
      categoryBreakdown: Map<String, int>.from(json['categoryBreakdown'] ?? {}),
    );
  }

  // Validation methods
  bool get isValid {
    return totalTasks >= 0 && 
           completedTasks >= 0 && 
           pendingTasks >= 0 &&
           completionPercentage >= 0.0 && 
           completionPercentage <= 100.0 &&
           (completedTasks + pendingTasks) == totalTasks;
  }

  String? validateTaskCounts() {
    if (totalTasks < 0) {
      return 'Total tasks cannot be negative';
    }
    if (completedTasks < 0) {
      return 'Completed tasks cannot be negative';
    }
    if (pendingTasks < 0) {
      return 'Pending tasks cannot be negative';
    }
    if ((completedTasks + pendingTasks) != totalTasks) {
      return 'Completed + Pending tasks must equal Total tasks';
    }
    return null;
  }

  String? validateCompletionPercentage() {
    if (completionPercentage < 0.0 || completionPercentage > 100.0) {
      return 'Completion percentage must be between 0 and 100';
    }
    if (totalTasks > 0) {
      final expectedPercentage = (completedTasks / totalTasks) * 100;
      if ((completionPercentage - expectedPercentage).abs() > 0.1) {
        return 'Completion percentage does not match calculated value';
      }
    }
    return null;
  }

  String? validateWeeklyProgress() {
    for (final entry in weeklyProgress.entries) {
      if (entry.value < 0) {
        return 'Weekly progress values cannot be negative';
      }
    }
    return null;
  }

  String? validateCategoryBreakdown() {
    for (final entry in categoryBreakdown.entries) {
      if (entry.value < 0) {
        return 'Category breakdown values cannot be negative';
      }
    }
    // Only validate category breakdown total if it's not empty
    if (categoryBreakdown.isNotEmpty) {
      final categoryTotal = categoryBreakdown.values.fold(0, (sum, count) => sum + count);
      if (categoryTotal != totalTasks) {
        return 'Category breakdown total does not match total tasks';
      }
    }
    return null;
  }

  List<String> validate() {
    final errors = <String>[];
    
    final taskCountError = validateTaskCounts();
    if (taskCountError != null) errors.add(taskCountError);
    
    final percentageError = validateCompletionPercentage();
    if (percentageError != null) errors.add(percentageError);
    
    final weeklyError = validateWeeklyProgress();
    if (weeklyError != null) errors.add(weeklyError);
    
    final categoryError = validateCategoryBreakdown();
    if (categoryError != null) errors.add(categoryError);
    
    return errors;
  }
}