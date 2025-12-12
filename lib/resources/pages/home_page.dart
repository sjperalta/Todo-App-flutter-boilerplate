import '/bootstrap/extensions.dart';
import '/resources/widgets/safearea_widget.dart';

import '/resources/widgets/tasks/task_empty_state.dart';
import '/resources/widgets/tasks/optimized_task_list.dart';
import '/app/services/navigation_service.dart';
import '/app/services/error_handling_service.dart';
import '/app/controllers/home_controller.dart';
import '/app/controllers/todo_controller.dart';
import '/app/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HomePage extends NyStatefulWidget<HomeController> {
  static RouteView path = ("/home", (context) {
    // Extract query parameters from the current route
    final route = ModalRoute.of(context);
    final settings = route?.settings;
    final uri = settings?.name != null ? Uri.tryParse(settings!.name!) : null;
    
    return HomePage(
      initialTab: uri?.queryParameters['tab'],
      initialCategory: uri?.queryParameters['category'],
    );
  });

  final String? initialTab;
  final String? initialCategory;

  HomePage({
    super.key,
    this.initialTab,
    this.initialCategory,
  }) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> {
  @override
  get init => () async {
    // Initialize controllers and handle deep linking
    await widget.controller.initializeWithDeepLink(
      initialTab: widget.initialTab,
      initialCategory: widget.initialCategory,
    );
  };

  @override
  LoadingStyle get loadingStyle => LoadingStyle.normal();

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.background,
      floatingActionButton: FloatingActionButton(
        onPressed: widget.controller.onAddTaskTap,
        backgroundColor: context.color.primaryAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeAreaWidget(
        child: Column(
          children: [
            // Header with logo, title and task count
            _buildHeader(context),
            
            // Tab navigation
            _buildTabNavigation(context),
            
            // Category filter chips
            _buildCategoryFilters(context),
            
            // Task list or empty state
            Expanded(
              child: _buildTaskList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // App logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.color.primaryAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Title and task count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TaskFlow',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.color.content,
                  ),
                ),
                Text(
                  '${widget.controller.taskCount} tasks',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.color.content.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistics button
          IconButton(
            onPressed: widget.controller.onStatisticsTap,
            icon: Icon(
              Icons.bar_chart,
              color: context.color.content.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: TabType.values.map((tab) {
          final isSelected = widget.controller.isTabSelected(tab);
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.controller.onTabSelected(tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? context.color.primaryAccent.withValues(alpha: 0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected 
                    ? Border.all(color: context.color.primaryAccent, width: 1)
                    : null,
                ),
                child: Text(
                  widget.controller.getTabTitle(tab),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected 
                      ? context.color.primaryAccent
                      : context.color.content.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    final categories = widget.controller.categoryController.categories;
    
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1, // +1 for "All" chip
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" chip
            final isSelected = widget.controller.isCategorySelected(null);
            return _buildCategoryChip(
              context,
              'All',
              context.color.primaryAccent,
              Icons.apps,
              isSelected,
              () => widget.controller.onCategorySelected(null),
            );
          }
          
          final category = categories[index - 1];
          final isSelected = widget.controller.isCategorySelected(category.id);
          return _buildCategoryChip(
            context,
            category.name,
            category.color,
            category.icon,
            isSelected,
            () => widget.controller.onCategorySelected(category.id),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String name,
    Color color,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : color.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final todos = widget.controller.todoController.todos;
    final categories = widget.controller.categoryController.categories;
    final selectedTab = widget.controller.selectedTab;
    final selectedCategoryId = widget.controller.selectedCategoryId;
    
    if (todos.isEmpty) {
      return _buildEmptyState(context, selectedTab, selectedCategoryId);
    }
    
    // Use optimized task list for better performance
    return OptimizedTaskList(
      todos: todos,
      categories: categories,
      onToggleComplete: (todo) async {
        await widget.controller.todoController.toggleComplete(todo.id);
        setState(() {});
      },
      onEdit: _handleEditTask,
      onDelete: _handleDeleteTask,
      onAddTask: widget.controller.onAddTaskTap,
    );
  }

  Widget _buildEmptyState(BuildContext context, TabType selectedTab, String? selectedCategoryId) {
    // Check if we have any tasks at all
    final hasAnyTasks = widget.controller.todoController.hasTodos;
    
    // Handle combined filters (category + tab)
    if (selectedCategoryId != null && selectedTab != TabType.all) {
      final category = widget.controller.categoryController.getCategoryById(selectedCategoryId);
      final categoryName = category?.name ?? 'Category';
      
      switch (selectedTab) {
        case TabType.today:
          return TaskEmptyState(
            title: 'No $categoryName tasks for today',
            subtitle: hasAnyTasks 
              ? 'You have no $categoryName tasks due today'
              : 'Add some $categoryName tasks to see them here',
            icon: Icons.today,
            onActionTap: widget.controller.onAddTaskTap,
            actionText: 'Add Task',
          );
        case TabType.completed:
          return TaskEmptyState(
            title: 'No completed $categoryName tasks',
            subtitle: 'Complete some $categoryName tasks to see them here',
            icon: Icons.check_circle_outline,
          );
        case TabType.all:
          break;
      }
    }
    
    // Handle category filter only
    if (selectedCategoryId != null) {
      final category = widget.controller.categoryController.getCategoryById(selectedCategoryId);
      return TaskEmptyState.noCategoryTasks(
        categoryName: category?.name ?? 'Category',
        onAddTask: widget.controller.onAddTaskTap,
      );
    }
    
    // Handle tab filter only
    switch (selectedTab) {
      case TabType.today:
        return TaskEmptyState.noTasksToday(
          onAddTask: widget.controller.onAddTaskTap,
        );
      case TabType.completed:
        return TaskEmptyState.noCompletedTasks();
      case TabType.all:
        return TaskEmptyState.noTasks(
          onAddTask: widget.controller.onAddTaskTap,
        );
    }
  }

  // Handle task editing with enhanced error handling
  void _handleEditTask(Todo todo) {
    try {
      NavigationService.showEditTaskModal(
        context,
        todo: todo,
        categories: widget.controller.categoryController.categories,
        onTaskUpdated: (updatedTodo) async {
          try {
            Navigator.of(context).pop();
            
            // Show loading state
            ErrorHandlingService.showLoadingDialog(context, message: 'Updating task...');
            
            final success = await widget.controller.todoController.updateTodo(updatedTodo);
            
            // Hide loading dialog
            ErrorHandlingService.hideLoadingDialog(context);
            
            if (success) {
              setState(() {});
              ErrorHandlingService.showSuccess(
                context,
                'Task "${updatedTodo.title}" updated successfully',
              );
            } else {
              ErrorHandlingService.showError(
                context,
                Exception('Update operation failed'),
                customMessage: 'Failed to update task. Please try again.',
              );
            }
          } catch (e) {
            // Hide loading dialog if it's showing
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            
            ErrorHandlingService.showError(
              context,
              e,
              customMessage: 'An error occurred while updating the task.',
            );
          }
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      ErrorHandlingService.showError(
        context,
        e,
        customMessage: 'Failed to open edit dialog.',
      );
    }
  }

  // Handle task deletion with enhanced error handling
  void _handleDeleteTask(Todo todo) async {
    try {
      final confirmed = await ErrorHandlingService.showConfirmationDialog(
        context,
        title: 'Delete Task',
        message: 'Are you sure you want to delete "${todo.title}"? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        confirmColor: Colors.red,
        icon: Icons.delete_outline,
        isDangerous: true,
      );

      if (confirmed) {
        // Show loading state
        ErrorHandlingService.showLoadingDialog(context, message: 'Deleting task...');
        
        final success = await widget.controller.todoController.deleteTodo(todo.id);
        
        // Hide loading dialog
        ErrorHandlingService.hideLoadingDialog(context);
        
        if (success) {
          setState(() {});
          ErrorHandlingService.showSuccess(
            context,
            'Task "${todo.title}" deleted successfully',
          );
        } else {
          ErrorHandlingService.showError(
            context,
            Exception('Delete operation failed'),
            customMessage: 'Failed to delete task. Please try again.',
          );
        }
      }
    } catch (e) {
      // Hide loading dialog if it's showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ErrorHandlingService.showError(
        context,
        e,
        customMessage: 'An error occurred while deleting the task.',
      );
    }
  }
}
