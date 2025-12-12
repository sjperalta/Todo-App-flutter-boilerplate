import 'package:flutter/material.dart';
import '/bootstrap/extensions.dart';

class TaskEmptyState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onActionTap;
  final String? actionText;

  const TaskEmptyState({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.onActionTap,
    this.actionText,
  });

  // Factory constructors for different empty states
  factory TaskEmptyState.noTasks({VoidCallback? onAddTask}) {
    return TaskEmptyState(
      title: 'No tasks yet',
      subtitle: 'Tap the + button to add your first task',
      icon: Icons.task_alt,
      onActionTap: onAddTask,
      actionText: 'Add Task',
    );
  }

  factory TaskEmptyState.noTasksToday({VoidCallback? onAddTask}) {
    return TaskEmptyState(
      title: 'No tasks for today',
      subtitle: 'You\'re all caught up! Enjoy your day.',
      icon: Icons.today,
      onActionTap: onAddTask,
      actionText: 'Add Task',
    );
  }

  factory TaskEmptyState.noCompletedTasks() {
    return const TaskEmptyState(
      title: 'No completed tasks',
      subtitle: 'Complete some tasks to see them here',
      icon: Icons.check_circle_outline,
    );
  }

  factory TaskEmptyState.noCategoryTasks({
    required String categoryName,
    VoidCallback? onAddTask,
  }) {
    return TaskEmptyState(
      title: 'No $categoryName tasks',
      subtitle: 'Add some tasks to this category',
      icon: Icons.category,
      onActionTap: onAddTask,
      actionText: 'Add Task',
    );
  }

  factory TaskEmptyState.noSearchResults({
    required String searchQuery,
    VoidCallback? onClearSearch,
  }) {
    return TaskEmptyState(
      title: 'No results found',
      subtitle: 'No tasks match "$searchQuery"',
      icon: Icons.search_off,
      onActionTap: onClearSearch,
      actionText: 'Clear Search',
    );
  }

  factory TaskEmptyState.noFilteredTasks({
    required String filterDescription,
    VoidCallback? onClearFilters,
  }) {
    return TaskEmptyState(
      title: 'No tasks found',
      subtitle: 'No tasks match the current filters: $filterDescription',
      icon: Icons.filter_list_off,
      onActionTap: onClearFilters,
      actionText: 'Clear Filters',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.color.primaryAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.task_alt,
                size: 40,
                color: context.color.primaryAccent.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title ?? 'No tasks yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.color.content.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              subtitle ?? 'Tap the + button to add your first task',
              style: TextStyle(
                fontSize: 16,
                color: context.color.content.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button (optional)
            if (onActionTap != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}