import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/category.dart';
import '../models/task_statistics.dart';
import '../repositories/todo_repository.dart';
import '../repositories/category_repository.dart';
import 'controller.dart';

class StatisticsController extends Controller {
  final TodoRepository _todoRepository = TodoRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  
  TaskStatistics _statistics = TaskStatistics.empty();
  List<Todo> _todos = [];
  List<Category> _categories = [];
  
  // Getters
  TaskStatistics get statistics => _statistics;
  int get totalTasks => _statistics.totalTasks;
  int get completedTasks => _statistics.completedTasks;
  int get pendingTasks => _statistics.pendingTasks;
  double get completionPercentage => _statistics.completionPercentage;
  Map<String, int> get weeklyProgress => _statistics.weeklyProgress;
  Map<String, int> get categoryBreakdown => _statistics.categoryBreakdown;
  
  // Load and calculate all statistics
  Future<void> loadStatistics() async {
    try {
      _todos = _todoRepository.getAllTodos();
      _categories = _categoryRepository.getAllCategories();
      _calculateStats();
    } catch (e) {
      print('StatisticsController: Error loading statistics: $e');
      _statistics = TaskStatistics.empty();
    }
  }

  // Calculate statistics from current data
  void _calculateStats() {
    _statistics = TaskStatistics.fromTodos(_todos);
  }

  // Get completion percentage as formatted string
  String getCompletionPercentageText() {
    return '${completionPercentage.toStringAsFixed(1)}%';
  }

  // Get weekly progress data for charts
  List<MapEntry<String, int>> getWeeklyProgressList() {
    return weeklyProgress.entries.toList();
  }

  // Get category breakdown with names and colors
  List<Map<String, dynamic>> getCategoryBreakdownWithDetails() {
    return categoryBreakdown.entries.map((entry) {
      final category = _categories.firstWhere(
        (cat) => cat.id == entry.key,
        orElse: () => Category.create(
          id: entry.key,
          name: 'Unknown',
          color: const Color(0xFF32C7AE),
          icon: Icons.category,
        ),
      );
      
      return {
        'id': entry.key,
        'name': category.name,
        'count': entry.value,
        'color': category.color,
        'icon': category.icon,
        'percentage': totalTasks > 0 ? (entry.value / totalTasks) * 100 : 0.0,
      };
    }).toList();
  }

  // Get today's statistics
  Map<String, int> getTodayStatistics() {
    final todayTodos = _todos.where((todo) => todo.isDueToday).toList();
    
    return {
      'due_today': todayTodos.length,
      'completed_today': todayTodos.where((todo) => todo.isCompleted).length,
      'pending_today': todayTodos.where((todo) => !todo.isCompleted).length,
    };
  }

  // Get this week's statistics
  Map<String, int> getWeekStatistics() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weekTodos = _todos.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             todo.dueDate!.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    
    return {
      'due_this_week': weekTodos.length,
      'completed_this_week': weekTodos.where((todo) => todo.isCompleted).length,
      'pending_this_week': weekTodos.where((todo) => !todo.isCompleted).length,
    };
  }

  // Get priority breakdown
  Map<String, int> getPriorityBreakdown() {
    final breakdown = <String, int>{
      'High': 0,
      'Medium': 0,
      'Low': 0,
    };
    
    for (final todo in _todos) {
      switch (todo.priority) {
        case 3:
          breakdown['High'] = (breakdown['High'] ?? 0) + 1;
          break;
        case 2:
          breakdown['Medium'] = (breakdown['Medium'] ?? 0) + 1;
          break;
        case 1:
          breakdown['Low'] = (breakdown['Low'] ?? 0) + 1;
          break;
      }
    }
    
    return breakdown;
  }

  // Get completion trend (last 30 days)
  Map<String, int> getCompletionTrend() {
    final trend = <String, int>{};
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.month}/${date.day}';
      
      final completedOnDay = _todos.where((todo) {
        if (!todo.isCompleted) return false;
        final updatedDate = todo.updatedAt;
        return updatedDate.year == date.year &&
               updatedDate.month == date.month &&
               updatedDate.day == date.day;
      }).length;
      
      trend[dateKey] = completedOnDay;
    }
    
    return trend;
  }

  // Get productivity metrics
  Map<String, dynamic> getProductivityMetrics() {
    if (_todos.isEmpty) {
      return {
        'average_completion_time': 0.0,
        'tasks_per_day': 0.0,
        'completion_rate': 0.0,
        'most_productive_day': 'None',
        'streak_days': 0,
      };
    }
    
    // Calculate average completion time
    final completedTodos = _todos.where((todo) => todo.isCompleted).toList();
    double avgCompletionTime = 0.0;
    
    if (completedTodos.isNotEmpty) {
      final totalTime = completedTodos.fold<int>(0, (sum, todo) {
        return sum + todo.updatedAt.difference(todo.createdAt).inHours;
      });
      avgCompletionTime = totalTime / completedTodos.length;
    }
    
    // Calculate tasks per day (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentTodos = _todos.where((todo) => todo.createdAt.isAfter(thirtyDaysAgo)).length;
    final tasksPerDay = recentTodos / 30.0;
    
    // Calculate completion rate
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;
    
    // Find most productive day
    final dayStats = <String, int>{};
    for (final todo in completedTodos) {
      final dayName = _getDayName(todo.updatedAt.weekday);
      dayStats[dayName] = (dayStats[dayName] ?? 0) + 1;
    }
    
    final mostProductiveDay = dayStats.entries.isEmpty 
        ? 'None' 
        : dayStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    // Calculate current streak
    final streakDays = _calculateStreakDays();
    
    return {
      'average_completion_time': avgCompletionTime,
      'tasks_per_day': tasksPerDay,
      'completion_rate': completionRate,
      'most_productive_day': mostProductiveDay,
      'streak_days': streakDays,
    };
  }

  // Calculate current completion streak
  int _calculateStreakDays() {
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) { // Check up to a year
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final completedOnDay = _todos.where((todo) {
        if (!todo.isCompleted) return false;
        final updatedDate = todo.updatedAt;
        final updatedDateKey = '${updatedDate.year}-${updatedDate.month.toString().padLeft(2, '0')}-${updatedDate.day.toString().padLeft(2, '0')}';
        return updatedDateKey == dateKey;
      }).isNotEmpty;
      
      if (completedOnDay) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  // Get overdue tasks statistics
  Map<String, int> getOverdueStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final overdueTodos = _todos.where((todo) {
      if (todo.isCompleted || todo.dueDate == null) return false;
      final dueDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
      return dueDate.isBefore(today);
    }).toList();
    
    return {
      'overdue_total': overdueTodos.length,
      'overdue_high_priority': overdueTodos.where((todo) => todo.priority == 3).length,
      'overdue_medium_priority': overdueTodos.where((todo) => todo.priority == 2).length,
      'overdue_low_priority': overdueTodos.where((todo) => todo.priority == 1).length,
    };
  }

  // Get upcoming tasks statistics
  Map<String, int> getUpcomingStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));
    
    final upcomingTodos = _todos.where((todo) {
      if (todo.isCompleted || todo.dueDate == null) return false;
      final dueDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
      return dueDate.isAfter(today) && dueDate.isBefore(nextWeek.add(const Duration(days: 1)));
    }).toList();
    
    return {
      'upcoming_total': upcomingTodos.length,
      'upcoming_high_priority': upcomingTodos.where((todo) => todo.priority == 3).length,
      'upcoming_medium_priority': upcomingTodos.where((todo) => todo.priority == 2).length,
      'upcoming_low_priority': upcomingTodos.where((todo) => todo.priority == 1).length,
    };
  }

  // Get comprehensive statistics summary
  Map<String, dynamic> getComprehensiveStats() {
    return {
      'basic': {
        'total': totalTasks,
        'completed': completedTasks,
        'pending': pendingTasks,
        'completion_percentage': completionPercentage,
      },
      'today': getTodayStatistics(),
      'week': getWeekStatistics(),
      'priority': getPriorityBreakdown(),
      'category': getCategoryBreakdownWithDetails(),
      'productivity': getProductivityMetrics(),
      'overdue': getOverdueStatistics(),
      'upcoming': getUpcomingStatistics(),
      'weekly_progress': weeklyProgress,
    };
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }

  // Refresh statistics
  Future<void> refresh() async {
    await loadStatistics();
  }

  // Initialize controller
  Future<void> initialize() async {
    await loadStatistics();
  }

  // Initialize with deep linking period parameter
  Future<void> initializeWithPeriod(String? period) async {
    await initialize();
    
    // Handle period parameter for future filtering
    // This can be extended to filter statistics by specific periods
    if (period != null) {
      _handlePeriodFilter(period);
    }
  }

  // Handle period filter from deep link
  void _handlePeriodFilter(String period) {
    // This method can be extended to filter statistics by period
    // For now, we just log the period parameter
    print('StatisticsController: Filtering by period: $period');
    
    // Future implementation could filter data by:
    // - 'week' - show only this week's data
    // - 'month' - show only this month's data
    // - 'year' - show only this year's data
  }

  // Export statistics as JSON
  Map<String, dynamic> exportStatistics() {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'statistics': _statistics.toJson(),
      'comprehensive': getComprehensiveStats(),
    };
  }

  // Validate statistics integrity
  List<String> validateStatistics() {
    return _statistics.validate();
  }

  // Check if statistics are valid
  bool get isValid => _statistics.isValid;

  // Clean up any resources if needed
  void dispose() {
    // Clean up any resources if needed
  }
}